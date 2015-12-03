SELECT
	s.dcid
	,	sch.name
	,	tea.lastfirst
	,	c.course_name
	,	sect.section_number
	,	sect.expression
	,	ter.abbreviation
	,	s.student_number
	,	s.lastfirst
	,	s.grade_level
	,	CASE	WHEN	s.enroll_status	=	0	AND		PSER.schoolid = s.schoolid THEN 'Active' ELSE 'Inactive' END
	,	TO_CHAR(cc.dateenrolled,'MM/DD/YYYY')
	,	TO_CHAR(cc.dateleft,'MM/DD/YYYY')
	,	terb.storecode
	,	NVL(TO_CHAR(pgfg.lastgradeupdate,'MM/DD/YYYY'),'MISSING')
	,	NVL(pgfg.grade,'MISSING')
	,	NVL(TO_CHAR(pgfg.percent),'MISSING')
	,	CASE WHEN pgfg.overridefg = 1 THEN 'Yes' ELSE 'No' END
	,	CASE
			WHEN	((sect.ExcludeFromStoredGrades = 0 AND c.ExcludeFromStoredGrades = 1) OR sect.ExcludeFromStoredGrades = 1)	THEN	'Excluded'
			ELSE																												NULL
			END
	
FROM		PS_ENROLLMENT_REG		PSER
INNER JOIN	students				s
	ON			s.id			=	PSER.studentid
INNER JOIN	schools			sch
	ON			sch.school_number	=	PSER.schoolid
INNER JOIN	cc
	ON			cc.studentid	=	PSER.studentid
	AND			cc.schoolid		=	PSER.schoolid
	AND			cc.dateenrolled	<	PSER.exitdate
	AND			cc.dateleft		>	PSER.entrydate
	AND			cc.dateenrolled	<=	'%param2%'
	AND			cc.dateleft		>	'%param2%'
INNER JOIN	sections		sect
	ON			sect.id			=	ABS(cc.sectionid)
INNER JOIN	courses			c
	ON			c.course_number	=	sect.course_number
INNER JOIN	teachers		tea
	ON			tea.id			=	sect.teacher
INNER JOIN	terms			ter
	ON			ter.id			=	sect.termid
	and			ter.schoolid	=	sect.schoolid
INNER JOIN	termbins		terb
	ON			terb.termid		=	ter.id
	AND			terb.schoolid	=	ter.schoolid
	AND			terb.storecode	=	'%param1%'
LEFT JOIN	pgfinalgrades	pgfg
	ON			pgfg.studentid		=	cc.studentid
	AND			pgfg.sectionid		=	sect.id
	AND			pgfg.finalgradename	=	terb.storecode

~[if.is.a.school]
WHERE	PSER.schoolid		= ~(curschoolid)
[/if]
	
ORDER BY
	tea.lastfirst
	,	sect.expression
	,	c.course_name
	,	s.lastfirst