SELECT
	sch.name
	,	t.lastfirst
	,	t.sif_stateprid
	,	t.Email_Addr
	,	rd.name
	,	st.start_date
	,	st.end_date
	,	c.course_name
	,	c.course_number
	,	sect.section_number
	,	sect.id

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
INNER JOIN	sectionteacher		st
		ON		st.sectionid		=	sect.id
INNER JOIN	roledef				rd
		ON		rd.id			=	st.roleid
INNER JOIN	courses			c
		ON		c.course_number		=	sect.course_number
INNER JOIN	teachers		t
		ON		t.id				=	st.teacherid
INNER JOIN	cc
		ON		ABS(cc.sectionid)	=	sect.id
		AND		cc.schoolid			=	ca_d.schoolid
		AND		cc.dateenrolled		<=	ca_d.date_value
		AND		cc.dateleft			>	ca_d.date_value
INNER JOIN	students		s
		ON		s.id				=	cc.studentid

WHERE	ca_d.date_value	>=	'%param1%'
	AND	ca_d.date_value	<=	'%param2%'
	AND	ca_d.insession	=	1
	AND	bsi.ada_code	=	1
	AND	sect.exclude_ada	=	0
	AND	s.grade_level		>=	0
	~[if.is.a.school]
		AND ca_d.schoolid	= ~(curschoolid)
	[/if]

GROUP BY
	sch.name
	,	t.lastfirst
	,	t.Email_Addr
	,	c.course_name
	,	rd.name
	,	st.start_date
	,	st.end_date
	,	sect.id
	,	t.sif_stateprid
	,	c.course_number
	,	sect.section_number

ORDER BY
	sch.name
	,	t.lastfirst
	,	t.Email_Addr
	,	c.course_name