SELECT
	s.dcid
	,	sch.abbreviation
	,	s.student_number
	,	s.lastfirst
	,	s.grade_level
	,	tea.lastfirst
	,	c.course_name
	,	sect.section_number
	,	sect.expression
	,	CASE	
			WHEN	((sect.ExcludeFromStoredGrades = 0 AND c.ExcludeFromStoredGrades = 1) OR sect.ExcludeFromStoredGrades = 1)	THEN	'Excluded'
			ELSE																												NULL
			END
	,	ter.abbreviation
	,	pgfg.finalgradename
	,	NVL(pgfg.grade,'MISSING')
	,	pgfg.percent
	,	pgfg.lastgradeupdate
	,	pgfg.overridefg
	,	sg.storecode
	,	NVL(sg.grade,'MISSING')
	,	sg.percent
	,	sg.datestored
	,	sg.earnedcrhrs
	,	sg.gpa_points
	,	sg.excludefromgpa
	,	sg.excludefromtranscripts
	
FROM		students		s
INNER JOIN	schools			sch
	ON			sch.school_number	=	s.schoolid
INNER JOIN	cc
	ON			cc.studentid	=	s.id
	AND			cc.dateenrolled	<=	'%param3%'
	AND			cc.dateleft		>	'%param3%'
INNER JOIN	sections		sect
	ON			sect.id			=	ABS(cc.sectionid)
INNER JOIN	courses			c
	ON			c.course_number	=	sect.course_number
INNER JOIN	teachers		tea
	ON			tea.id			=	sect.teacher
INNER JOIN	terms			ter
	ON			ter.id			=	sect.termid
	and			ter.schoolid	=	sect.schoolid
INNER JOIN	terms			ter2
	ON			ter2.yearid		=	ter.yearid
	AND			ter2.schoolid	=	ter.schoolid
	AND			ter2.firstday	>=	ter.firstday
	AND			ter2.lastday	<=	ter.lastday	
	AND			ter2.abbreviation	=	'%param2%'
LEFT JOIN	pgfinalgrades	pgfg
	ON			pgfg.studentid		=	cc.studentid
	AND			pgfg.sectionid		=	sect.id
	AND			pgfg.finalgradename	=	ter2.abbreviation
LEFT JOIN	storedgrades	sg
	ON			sg.sectionid		=	sect.id
	AND			sg.studentid		=	cc.studentid
	AND			sg.storecode		=	ter2.abbreviation

WHERE	s.schoolid		IN	(%param1%)
	AND	s.enroll_status	=	0
	
ORDER BY
	tea.lastfirst
	,	sect.expression
	,	c.course_name
	,	s.lastfirst