SELECT
	TO_CHAR(ca_d.date_value,'MM/DD/YYYY')
	,	sch.name
	,	t.lastfirst
	,	c.course_name
	,	p.abbreviation||'('||cy_d.day_name||')'
	,	SUM(CASE
				WHEN ac.id IS NULL THEN 1
				ELSE	0
				END) AS blank_count
	,	COUNT(*)

FROM		calendar_day	ca_d
INNER JOIN	schools			sch
		ON		sch.school_number	=	ca_d.schoolid
INNER JOIN	bell_schedule	bs
		ON		bs.id				=	ca_d.bell_schedule_id
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
INNER JOIN	ps_enrollment_reg PSER
		ON		PSER.studentid		=	cc.studentid
		AND		PSER.schoolid		=	cc.schoolid
		AND		PSER.entrydate		<	cc.dateleft
		AND		PSER.exitdate		>	cc.dateenrolled
		AND		(	(PSER.track IS NULL)
			OR		(PSER.track = 'A'	AND		ca_d.A = 1)
			OR		(PSER.track = 'B'	AND		ca_d.B = 1)
			OR		(PSER.track = 'C'	AND		ca_d.C = 1)
			OR		(PSER.track = 'D'	AND		ca_d.D = 1)
			OR		(PSER.track = 'E'	AND		ca_d.E = 1)
			OR		(PSER.track = 'F'	AND		ca_d.F = 1))
INNER JOIN	students		s
		ON		s.id				=	PSER.studentid
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
	~[if.is.a.school]
		AND ca_d.schoolid	= ~(curschoolid)
	[/if]

GROUP BY
	ca_d.date_value
	,	ca_d.schoolid
	,	sch.name
	,	t.lastfirst
	,	c.course_name
	,	c.course_number
	,	sect.section_number
	,	p.abbreviation
	,	cy_d.day_name
	,	c.course_name


~[if#allclasses.%param3%=No]
	HAVING SUM(CASE
				WHEN ac.id IS NULL THEN 1
				ELSE	0
				END) > 0
[/if#allclasses]

ORDER BY
	ca_d.date_value
	,	sch.name
	,	t.lastfirst
	,	p.abbreviation
	,	cy_d.day_name