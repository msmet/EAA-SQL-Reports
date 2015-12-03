SELECT
	s.dcid
	,	att.dcid
	,	sch.name
	,	s.lastfirst
	,	s.grade_level
	,	TO_CHAR(att.att_date,'MM/DD/YYYY')
	,	t.lastfirst
	,	c.course_name
	,	c.course_number
	,	sect.section_number
	,	p.abbreviation
	,	REPLACE(LISTAGG(NVL(TO_CHAR(al.log_dt,'MM/DD/YYYY'),'null'),'<BR />') WITHIN GROUP (ORDER BY al.log_dt asc, al.log_tm asc), 'null')
	,	REPLACE(LISTAGG(NVL(TO_CHAR(regexp_replace(to_char(to_date(al.log_tm,'SSSSS'),'HH.MI AM'),'\.',chr(58))),'null'),'<BR />') WITHIN GROUP (ORDER BY al.log_dt asc, al.log_tm asc), 'null')
	,	REPLACE(LISTAGG(NVL(u.lastfirst,'null'),'<BR />') WITHIN GROUP (ORDER BY al.log_dt asc, al.log_tm asc), 'null')
	,	REPLACE(LISTAGG(NVL(attac.att_code,'null'),'<BR />') WITHIN GROUP (ORDER BY al.log_dt asc, al.log_tm asc), 'null')
	,	REPLACE(LISTAGG(NVL(alac.att_code,'null'),'<BR />') WITHIN GROUP (ORDER BY al.log_dt asc, al.log_tm asc), 'null')
	
FROM	students		s

~[if#cursel.%param3%=Yes]
	INNER JOIN ~[temp.table.current.selection:students] stusel ON stusel.dcid=s.dcid
[/if#cursel]
	
INNER JOIN	attendance		att
	on			att.studentid	=	s.id
INNER JOIN	period			p
	ON			p.id			=	att.periodid

INNER JOIN	audit_log		al
	ON			al.pkid			=	att.id
	AND			al.db_objectid	=	2
LEFT JOIN	schoolstaff	ss
	ON			ss.id			=	al.userid
LEFT JOIN	users		u
	ON			u.dcid			=	ss.users_dcid

LEFT JOIN	attendance_code		attac
	ON			attac.id		=	att.attendance_codeid
LEFT JOIN	attendance_code		alac
	ON			alac.id			=	al.old_data

INNER JOIN	cc
	ON			cc.id			=	att.ccid
INNER JOIN	sections		sect
	ON			sect.id			=	cc.sectionid
INNER JOIN	courses			c
	ON			c.course_number	=	sect.course_number
INNER JOIN	teachers		t
	ON			t.id			=	sect.teacher
INNER JOIN	schools			sch
	ON			sch.school_number =	cc.schoolid	

WHERE	att.att_date	>=	'%param1%'
	AND	att.att_date	<=	'%param2%'
~[if.is.a.school]
		AND	att.schoolid	=~(curschoolid)
[/if]

GROUP BY
	s.dcid
	,	att.dcid
	,	sch.name
	,	s.lastfirst
	,	s.grade_level
	,	att.att_date
	,	t.lastfirst
	,	c.course_name
	,	c.course_number
	,	sect.section_number
	,	p.abbreviation

ORDER BY
	s.lastfirst
	,	att.att_date
	,	p.abbreviation