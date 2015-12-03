WITH ca_d_n AS
(
	SELECT
		ca_d.date_value
		,	ca_d.schoolid
		,	ca_d.insession
		,	ca_d.bell_schedule_id
		,	ca_d.cycle_day_id
		,	ca_d.A
		,	ca_d.B
		,	ca_d.C
		,	ca_d.D
		,	ca_d.E
		,	ca_d.F
		,	ROW_NUMBER() OVER (PARTITION BY  ca_d.schoolid ORDER BY ca_d.date_value DESC) AS rn /*filter for 20 days in pam2 subquery */
	
	FROM		calendar_day	ca_d
	INNER JOIN	terms			ter
			ON		ter.schoolid	=	ca_d.schoolid
			AND		ter.firstday	<=	ca_d.date_value
			AND		ter.lastday		>=	ca_d.date_value
			AND		ter.isyearrec	=	1
	
	WHERE	ca_d.insession			=		1
		AND	ca_d.date_value			<=		'%param1%'
		AND	ter.yearid				=		%param2%
		AND	ca_d.schoolid			IN		(%param3%)
		AND	ca_d.schoolid			NOT IN	(45541,777777,999999,6666666,666666,11111)
)


SELECT
	s.dcid
	,	sch.name
	,	s.student_number
	,	COUNT (
			DISTINCT (
				CASE
					WHEN	(PSER.grade_level	<=	8
						AND	pam2.pres_count		>	0)
					THEN	pam2.date_value
					WHEN	(PSER.grade_level	>	8
						AND	pam2.pres_count		>	1)
					THEN	pam2.date_value
					ELSE	NULL
				END))				AS		ver_count
	,	COUNT( DISTINCT pam2.date_value)		AS		full_count
	,	CASE
			WHEN	COUNT( DISTINCT pam2.date_value) = 0	THEN	0.0
			ELSE	CAST(100*COUNT ( DISTINCT ( CASE WHEN (PSER.grade_level <= 8 AND pam2.pres_count  > 0) THEN pam2.date_value WHEN (PSER.grade_level > 8 AND pam2.pres_count  > 1) THEN pam2.date_value ELSE NULL END))/COUNT( DISTINCT pam2.date_value) AS DECIMAL (4,1))
			END||'%'		AS	ver_rate
	,	s.lastfirst
	,	PSER.grade_level
	,	(SELECT LISTAGG (tea.lastfirst, ', ') WITHIN GROUP (ORDER BY tea.lastfirst) FROM cc INNER JOIN teachers tea  ON tea.id = cc.teacherid WHERE cc.studentid = PSER.studentid AND cc.dateenrolled <= '%param1%' AND cc.dateleft > '%param1%' AND cc.course_number IN ('HRAM','EM72106TYR','HS22106TSA'))
	,	s.street
	,	s.city
	,	s.state
	,	s.zip
	,	s.home_phone
	,	ps_customfields.getStudentscf(s.id,'mother_home_phone')
	,	ps_customfields.getStudentscf(s.id,'motherdayphone')
	,	ps_customfields.getStudentscf(s.id,'father_home_phone')
	,	ps_customfields.getStudentscf(s.id,'fatherdayphone')
	,	ps_customfields.getStudentscf(s.id,'guardiandayphone')
	,	s.emerg_phone_1
	,	s.emerg_phone_2
	,	ps_customfields.getStudentscf(s.id,'emerg_3_phone')

FROM		ps_enrollment_reg		PSER

LEFT JOIN	students				s
	ON			s.id						=	PSER.studentid
LEFT JOIN	schools					sch
	ON			sch.School_Number			=	PSER.schoolid

LEFT JOIN (
	SELECT
		s.id	AS	studentid
		,	ca_d.date_value
		,	ca_d.schoolid
		,	count(*)	AS	no_periods
		,	SUM(CASE
					WHEN ac.presence_status_cd =	'Present' THEN 1
					ELSE	0
					END) AS pres_count
		,	SUM(CASE
					WHEN ac.presence_status_cd =	'Absent' THEN 1
					ELSE	0
					END) AS abs_count
		,	SUM(CASE
					WHEN ac.presence_status_cd IS NULL THEN 1
					ELSE	0
					END) AS blank_count

	FROM		ca_d_n			ca_d
	INNER JOIN	bell_schedule	bs
			ON		bs.id					=	ca_d.bell_schedule_id
			AND		ca_d.rn					<=	%param5%						/* Only include previous twenty days */
	INNER JOIN	bell_schedule_items bsi
			ON		bsi.bell_schedule_id	=	bs.id
	INNER JOIN	cycle_day		cy_d
			ON		cy_d.id				=	ca_d.cycle_day_id
			AND		cy_d.schoolid		=	ca_d.schoolid
	INNER JOIN	section_meeting	sm
			ON		sm.schoolid			=	ca_d.schoolid
			AND		sm.cycle_day_letter	=	cy_d.letter
			AND		sm.year_id			=	cy_d.year_id
	INNER JOIN	period			p
			ON		p.schoolid			=	ca_d.schoolid
			AND		p.year_id			=	cy_d.year_id
			AND		p.period_number		=	sm.period_number
			AND		p.id				=	bsi.period_id
	INNER JOIN	sections		sect
			ON		sect.id				=	sm.sectionid
	INNER JOIN	courses			c
			ON		c.course_number		=	sect.course_number
	INNER JOIN	teachers		t
			ON		t.id				=	sect.teacher
	INNER JOIN	cc
			ON		(cc.sectionid		=	sect.id
				OR	cc.sectionid		=	-sect.id)
			AND		cc.schoolid			=	ca_d.schoolid
			AND		cc.dateenrolled		<=	ca_d.date_value
			AND		cc.dateleft			>	ca_d.date_value
	INNER JOIN	students		s
			ON		s.id				=	cc.studentid
	LEFT JOIN	attendance				att
			ON		att.studentid		=	cc.studentid
			AND		att.att_date		=	ca_d.date_value
			AND		att.ccid			=	cc.id
			AND		att.periodid		=	p.id
	LEFT JOIN	attendance_code			ac
			ON		ac.id				=	att.attendance_codeid
			AND		(ac.calculate_ada_yn	=	1
				OR	ac.att_code		=	'NCH')

	WHERE	ca_d.insession		=	1
		AND	bsi.ada_code		=	1
		AND	sect.exclude_ada	=	0
		AND	(ac.att_code		!=	'NCH'
			OR	ac.att_code		IS	NULL)

	GROUP BY
		s.id
		,	ca_d.date_value
		,	ca_d.schoolid
)	pam2
	ON			pam2.studentid		=	PSER.studentid
	AND			pam2.schoolid		=	PSER.schoolid

WHERE	PSER.entrydate		<=		'%param1%'
	AND	PSER.exitdate		>		'%param1%'
	AND	PSER.schoolid 		IN		(%param3%)
	AND	PSER.schoolid		NOT IN	(45541,777777,999999,6666666,666666,11111)
	AND	PSER.grade_level	>=		0

GROUP BY
	s.dcid
	,	PSER.studentid
	,	sch.name
	,	s.student_number
	,	s.lastfirst
	,	PSER.grade_level
	,	s.street
	,	s.city
	,	s.state
	,	s.zip
	,	s.home_phone
	,	ps_customfields.getStudentscf(s.id,'guardiandayphone')
	,	ps_customfields.getStudentscf(s.id,'motherdayphone')
	,	ps_customfields.getStudentscf(s.id,'mother_home_phone')
	,	ps_customfields.getStudentscf(s.id,'fatherdayphone')
	,	ps_customfields.getStudentscf(s.id,'father_home_phone')
	,	s.emerg_phone_1
	,	s.emerg_phone_2
	,	ps_customfields.getStudentscf(s.id,'emerg_3_phone')

HAVING
	COUNT( DISTINCT pam2.date_value) = 0
	OR	CAST(COUNT ( DISTINCT ( CASE WHEN (PSER.grade_level <= 8 AND pam2.pres_count  > 0) THEN pam2.date_value WHEN (PSER.grade_level > 8 AND pam2.pres_count  > 1) THEN pam2.date_value ELSE NULL END))/COUNT( DISTINCT pam2.date_value) AS DECIMAL (4,1)) < %param4%
	
ORDER BY
	sch.name
	,	PSER.grade_level
	,	s.lastfirst