SELECT
	sch.name
	,	s.student_number
	,	s.last_name
	,	s.first_name
	,	COUNT(DISTINCT ca_d.date_value)
	,	COUNT(DISTINCT CASE WHEN pam2.pres_count	>=	1 THEN ca_d.date_value ELSE NULL END)
	,	COUNT(DISTINCT ca_d.date_value) - COUNT(DISTINCT CASE WHEN pam2.pres_count	>=	1 THEN ca_d.date_value ELSE NULL END)
	,	CAST(CAST(100*COUNT(DISTINCT CASE WHEN pam2.pres_count	>=	1 THEN ca_d.date_value ELSE NULL END)/COUNT(DISTINCT ca_d.date_value) AS DECIMAL(4,1)) AS VARCHAR2(10))||'%'
	,	CASE WHEN COUNT(DISTINCT ca_d.date_value) - COUNT(DISTINCT CASE WHEN pam2.pres_count	>=	1 THEN ca_d.date_value ELSE NULL END) > 9 THEN 1 ELSE 0 END

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
LEFT JOIN	S_MI_STU_GC_X	SMSGX
	ON			SMSGX.studentsdcid		=	s.dcid

LEFT JOIN (
	SELECT
		s.id	AS	studentid
		,	ca_d.date_value
		,	ca_d.schoolid
		,	count(*)	AS	no_periods
		,	SUM(CASE WHEN ac.presence_status_cd = 'Present' THEN 1 ELSE 0 END) AS pres_count
		,	SUM(CASE WHEN ac.presence_status_cd = 'Absent' THEN 1 ELSE 0 END) AS abs_count
		,	SUM(CASE WHEN ac.presence_status_cd IS NULL THEN 1 ELSE 0 END) AS blank_count

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
			AND		(ac.calculate_ada_yn	=	1
				OR	ac.att_code		=	'NCH')

	WHERE	ca_d.date_value	>=	'%param1%'
		AND	ca_d.date_value	<=	'%param2%'
		AND	ca_d.insession	=	1
		AND	bsi.ada_code	=	1
		AND	sect.exclude_ada	=	0
		AND	(ac.att_code		!=	'NCH'
			OR	ac.att_code		IS	NULL)

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
	AND	ca_d.insession	=	1
	AND	ca_d.schoolid	NOT IN	(45541,777777,999999,6666666,666666,11111)

GROUP BY
	sch.name
	,	s.student_number
	,	s.last_name
	,	s.first_name

HAVING
	SUM(CASE WHEN PSER.entrydate <= '%param2%' AND PSER.exitdate > '%param2%' THEN 1 ELSE 0 END) > 0

ORDER BY
	sch.name
	,	s.last_name
	,	s.first_name