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
	sch.name
	,	COUNT ( DISTINCT ( CASE WHEN (PSER.grade_level = 0 AND pam2.pres_count > 0) THEN PSER.studentid ELSE NULL END))
	,	COUNT ( DISTINCT ( CASE WHEN (PSER.grade_level = 1 AND pam2.pres_count > 0) THEN PSER.studentid ELSE NULL END))
	,	COUNT ( DISTINCT ( CASE WHEN (PSER.grade_level = 2 AND pam2.pres_count > 0) THEN PSER.studentid ELSE NULL END))
	,	COUNT ( DISTINCT ( CASE WHEN (PSER.grade_level = 3 AND pam2.pres_count > 0) THEN PSER.studentid ELSE NULL END))
	,	COUNT ( DISTINCT ( CASE WHEN (PSER.grade_level = 4 AND pam2.pres_count > 0) THEN PSER.studentid ELSE NULL END))
	,	COUNT ( DISTINCT ( CASE WHEN (PSER.grade_level = 5 AND pam2.pres_count > 0) THEN PSER.studentid ELSE NULL END))
	,	COUNT ( DISTINCT ( CASE WHEN (PSER.grade_level = 6 AND pam2.pres_count > 0) THEN PSER.studentid ELSE NULL END))
	,	COUNT ( DISTINCT ( CASE WHEN (PSER.grade_level = 7 AND pam2.pres_count > 0) THEN PSER.studentid ELSE NULL END))
	,	COUNT ( DISTINCT ( CASE WHEN (PSER.grade_level = 8 AND pam2.pres_count > 0) THEN PSER.studentid ELSE NULL END))
	,	COUNT ( DISTINCT ( CASE WHEN (PSER.grade_level = 9 AND pam2.pres_count > 1) THEN PSER.studentid ELSE NULL END))
	,	COUNT ( DISTINCT ( CASE WHEN (PSER.grade_level = 10 AND pam2.pres_count > 1) THEN PSER.studentid ELSE NULL END))
	,	COUNT ( DISTINCT ( CASE WHEN (PSER.grade_level = 11 AND pam2.pres_count > 1) THEN PSER.studentid ELSE NULL END))
	,	COUNT ( DISTINCT ( CASE WHEN (PSER.grade_level = 12 AND pam2.pres_count > 1) THEN PSER.studentid ELSE NULL END))
	,	COUNT ( DISTINCT ( CASE WHEN (PSER.grade_level > 8 AND pam2.pres_count > 1) THEN PSER.studentid WHEN (PSER.grade_level < 9 AND pam2.pres_count > 0) THEN PSER.studentid ELSE NULL END))

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
					WHEN att.attendance_codeid IS NULL THEN 1
					ELSE	0
					END) AS blank_count

	FROM		ca_d_n			ca_d
	INNER JOIN	bell_schedule	bs
			ON		bs.id					=	ca_d.bell_schedule_id
			AND		ca_d.rn					<=	%param4%
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

	WHERE	ca_d.insession		=	1
		AND	bsi.ada_code		=	1
		AND	sect.exclude_ada	=	0

	GROUP BY
		s.id
		,	ca_d.date_value
		,	ca_d.schoolid
)	pam2
	ON			pam2.studentid		=	PSER.studentid
	AND			pam2.schoolid		=	PSER.schoolid
	AND			pam2.date_value		>=	PSER.entrydate
	AND			pam2.date_value		<	PSER.exitdate

WHERE	PSER.entrydate		<=		'%param1%'
	AND	PSER.exitdate		>		'%param1%'
	AND	PSER.schoolid		NOT IN	(45541,777777,999999,6666666,666666,11111)
	AND	PSER.grade_level	>=		0
	AND	PSER.schoolid 		IN		(%param3%)

GROUP BY
	ROLLUP(sch.name)

ORDER BY
	MIN(PSER.grade_level) DESC
	,	MAX(PSER.grade_level) ASC
	,	sch.name