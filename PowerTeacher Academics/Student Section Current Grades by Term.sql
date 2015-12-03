SELECT
	s.lastfirst
	,	s.grade_level
	,	c.course_name
	,	sect.expression
	,	pgfg.finalgradename
	,	TO_CHAR(TO_DATE(pgfg.lastgradeupdate),'MM/DD/YYYY')
	,	pgfg.grade
	,	pgfg.percent

FROM		teachers		t
INNER JOIN	sections		sect
	ON			sect.teacher		=	t.id
INNER JOIN	courses			c
	ON			c.course_number		=	sect.course_number
INNER JOIN	terms			ter1
	ON			ter1.id				=	sect.termid
	AND			ter1.schoolid		=	sect.schoolid
INNER JOIN	terms			ter2
	ON			ter2.schoolid		=	ter1.schoolid
	AND			ter2.firstday		>=	ter1.firstday
	AND			ter2.lastday		<=	ter1.lastday
	AND			ter2.abbreviation	IN	('%param3%')
LEFT JOIN	cc
	ON			(cc.sectionid		=	sect.id
		OR		cc.sectionid		=	-sect.id)
	AND			cc.dateleft			>=	ter2.lastday
LEFT JOIN	students		s
	ON			s.id				=	cc.studentid
LEFT JOIN   pgfinalgrades	pgfg
	ON			pgfg.studentid		=	cc.studentid
	AND			pgfg.sectionid		=	sect.id
	AND			pgfg.finalgradename	=	ter2.abbreviation	

WHERE	t.id	=	~[x:userid]
	AND	sect.id		IN	(%param1%)
	AND	ter1.yearid	IN	(%param2%)