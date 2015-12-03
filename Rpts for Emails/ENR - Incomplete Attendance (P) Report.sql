SELECT
	s.dcid
	,	sch.name
	,	PSER.studentid
	,	s.student_number
	,	s.lastfirst
	,	PSER.grade_level
	,	TO_CHAR(PSER.entrydate,'MM/DD/YYYY')
	,	TO_CHAR(PSER.exitdate,'MM/DD/YYYY')
	,	COUNT (DISTINCT pam2.date_value) AS sum_enrolledr
	,	SUM (CASE WHEN pam2.pres_flag = 1 THEN 1 ELSE 0 END) AS sum_pres
	,	SUM (CASE WHEN pam2.pres_flag = 0 THEN 1 ELSE 0 END) AS sum_abs
	,	SUM (CASE WHEN pam2.pres_count < pam2.no_periods THEN 1 ELSE 0 END) AS sum_inc
	,	AVG (CASE WHEN pam2.pres_count < pam2.no_periods THEN (pam2.pres_count) ELSE NULL END)
	,	AVG (CASE WHEN pam2.pres_count < pam2.no_periods AND pam2.pres_count > 0 THEN (pam2.pres_count / pam2.no_periods) ELSE NULL END)

FROM		calendar_day			ca_d
LEFT JOIN	ps_enrollment_reg		PSER
	ON			PSER.schoolid			=	ca_d.schoolid
	AND			PSER.entrydate			<=	ca_d.date_value
	AND			PSER.exitdate			>	ca_d.date_value
	AND		(	(PSER.track IS NULL)
		OR		(PSER.track = 'A'	AND		ca_d.A = 1)
		OR		(PSER.track = 'B'	AND		ca_d.B = 1)
		OR		(PSER.track = 'C'	AND		ca_d.C = 1)
		OR		(PSER.track = 'D'	AND		ca_d.D = 1)
		OR		(PSER.track = 'E'	AND		ca_d.E = 1)
		OR		(PSER.track = 'F'	AND		ca_d.F = 1))
LEFT JOIN	Students				s
	ON			s.id						=	PSER.studentid
LEFT JOIN	Schools					sch
	ON			sch.School_Number			=	ca_d.schoolid

LEFT JOIN (
	SELECT
		s.id	AS	studentid
		,	ca_d.date_value
		,	ca_d.schoolid
		,	COUNT (DISTINCT sm.dcid) AS no_periods
		,	SUM(CASE
					WHEN att.attendance_codeid IS NOT NULL THEN 1
					ELSE	0
					END) AS exp_exist_count
		,	SUM(CASE
					WHEN ac.presence_status_cd =	'Present' THEN 1
					ELSE	0
					END) AS pres_count
		,	(CASE
					WHEN (SUM(CASE WHEN ac.presence_status_cd =	'Present' THEN 1 ELSE	0 END))	>	0	THEN	1
					ELSE	0
					END)	AS	pres_flag
		,	SUM(CASE
					WHEN ac.presence_status_cd =	'Absent' THEN 1
					ELSE	0
					END) AS abs_count
		,	SUM(CASE
					WHEN att.attendance_codeid IS NULL THEN 1
					ELSE	0
					END) AS blank_count

	FROM		calendar_day	ca_d
	INNER JOIN	bell_schedule	bs
			ON		bs.id					=	ca_d.bell_schedule_id
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
	LEFT JOIN	PS_Attendance_Meeting	pam
			ON		pam.schoolid		=	ca_d.schoolid
			AND		pam.att_date		=	ca_d.date_value
			AND		pam.ccid			=	cc.id
			AND		pam.studentid		=	s.id
			AND		pam.periodid		=	p.id
	LEFT JOIN	attendance				att
			ON		att.studentid		=	cc.studentid
			AND		att.att_date		=	ca_d.date_value
			AND		att.ccid			=	cc.id
			AND		att.periodid		=	p.id
	LEFT JOIN	attendance_code			ac
			ON		ac.id				=	att.attendance_codeid

	WHERE	ca_d.date_value	>=	'%param1%'
		AND	ca_d.date_value	<=	'%param2%'
		AND	ca_d.insession	=	1
		AND ca_d.schoolid	IN	(%param4%)
		AND	bsi.ada_code	=	1
		AND	sect.exclude_ada	=	0

	GROUP BY
		s.id
		,	ca_d.date_value
		,	ca_d.schoolid
)	pam2
	ON			pam2.studentid		=	PSER.studentid
	AND			pam2.date_value		=	ca_d.date_value
	AND			pam2.schoolid		=	ca_d.schoolid

WHERE	ca_d.date_value	>=	'%param1%'
	AND	ca_d.date_value	<=	'%param2%'
	AND	PSER.grade_level	>=	%param3%
	AND	ca_d.insession	=	1
	AND	ca_d.schoolid	NOT IN	(45541,777777,999999,6666666,666666,11111)
	AND	ca_d.schoolid	IN		(%param4%)

GROUP BY
	s.dcid
	,	sch.name
	,	PSER.studentid
	,	s.student_number
	,	s.lastfirst
	,	PSER.grade_level
	,	PSER.entrydate
	,	PSER.exitdate