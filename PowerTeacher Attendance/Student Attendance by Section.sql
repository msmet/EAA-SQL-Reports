SELECT
c.course_name||chr(58)||' '||sect.section_number||' ('||sect.expression||')'
	,	c.course_name
	,	sect.section_number
	,	sect.expression
	,	'<a href=/teachers/studentpages/quicklookup.html?frn=001'||s.dcid||'>'||s.lastfirst||'</a>'
	,	s.grade_level
	,	COUNT (*)	AS	full_count
	,	CONCAT(CAST(cast(100*
		SUM(CASE
				WHEN ac.presence_status_cd =	'Present' THEN 1
				ELSE	0
				END)
		/count(*) as decimal(4,1)) AS varchar(10)),'%')	AS	pres_percent

FROM		teachers		t
INNER JOIN	sections		sect
	ON			sect.teacher		=	t.id
INNER JOIN	courses			c
	ON			c.course_number		=	sect.course_number
INNER JOIN	terms			ter1
	ON			ter1.id				=	sect.termid
	AND			ter1.schoolid		=	sect.schoolid
INNER JOIN	terms			ter2
	ON			ter2.schoolid		=	sect.schoolid
	AND			ter2.firstday		>=	ter1.firstday
	AND			ter2.lastday		>=	ter1.lastday
	AND			ter2.abbreviation	>=	'%param1%'
INNER JOIN	section_meeting	sm
	ON			sm.sectionid		=	sect.id
INNER JOIN	cycle_day		cy_d
	ON			cy_d.schoolid		=	sm.schoolid
	AND			cy_d.letter			=	sm.Cycle_Day_Letter
	AND			cy_d.year_id		=	sm.year_id
INNER JOIN	period			p
	ON			p.schoolid			=	sm.schoolid
	AND			p.year_id			=	sm.year_id
	AND			p.period_number		=	sm.period_number
INNER JOIN	calendar_day	ca_d
	ON			ca_d.schoolid		=	sect.schoolid
	AND			ca_d.date_value		>=	ter1.firstday
	AND			ca_d.date_value		<=	ter1.lastday
	AND			ca_d.cycle_day_id	=	cy_d.id
INNER JOIN	bell_schedule	bs
		ON		bs.id				=	ca_d.bell_schedule_id
INNER JOIN	bell_schedule_items bsi
		ON		bsi.bell_schedule_id	=	bs.id
		AND		bsi.period_id			=	p.id
INNER JOIN	cc
	ON		(cc.sectionid			=	sect.id
		OR	cc.sectionid			=	-sect.id)
	AND		cc.schoolid				=	ca_d.schoolid
	AND		cc.dateenrolled			<=	ca_d.date_value
	AND		cc.dateleft				>	ca_d.date_value
INNER JOIN	students		s
	ON		s.id					=	cc.studentid
LEFT JOIN	attendance att
	ON		att.studentid			=	cc.studentid
	AND		att.att_date			=	ca_d.date_value
	AND		att.ccid				=	cc.id
	AND		att.periodid			=	p.id
LEFT JOIN	attendance_code	ac
	ON		ac.id					=	att.attendance_codeid

WHERE	t.id	=	~[x:userid]
	AND		ca_d.date_value	<=	'~[short.date]'
	AND		ter1.yearid	=	'~(curyearid)'
	AND		cc.dateenrolled	<=	ter2.lastday
	AND		cc.dateleft		>=	ter2.lastday
	AND		sect.id IN (%param2%)

GROUP BY
	c.course_name
	,	sect.section_number
	,	sect.expression
	,	s.dcid
	,	s.lastfirst
	,	s.grade_level
ORDER BY
	c.course_name
	,	sect.section_number
	,	sect.expression
	,	s.lastfirst