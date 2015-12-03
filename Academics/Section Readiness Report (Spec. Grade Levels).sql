SELECT 
	tea.lastfirst
	,	sch.abbreviation
	,	ter1.abbreviation
	,	c.course_name
	,	sect.section_number
	,	sect.expression
	,	terb.storecode
	,	CASE
			WHEN	SUM(NVL(PSMSR.VERIFIEDSTATUS,0))	>	0	THEN	'Yes'
			ELSE												'No'
			END

FROM		SECTIONS 					sect
INNER JOIN	COURSES						c
	ON			c.course_number				=	sect.course_number
INNER JOIN	TEACHERS					tea
	ON			tea.id						=	sect.teacher
INNER JOIN	SCHOOLS						sch
	ON			sch.school_number			=	sect.schoolid
INNER JOIN	TERMS 						ter1
	ON			ter1.id						=	sect.termid
	AND			ter1.schoolid				=	sect.schoolid
INNER JOIN	TERMBINS					terb
	ON			terb.schoolid				=	ter1.schoolid
	AND			terb.yearid					=	ter1.yearid
	AND			terb.termid					=	ter1.id
INNER JOIN	cc
	ON			cc.dateleft				>=	terb.date2
	AND			cc.sectionid			=	sect.id
INNER JOIN	students					s
	ON			s.id					=	cc.studentid
LEFT JOIN	SYNC_REPORTINGTERMMAP		SRTM
	ON			SRTM.termbinsdcid			=	terb.dcid
LEFT JOIN	SYNC_SECTIONMAP				SSM
	ON			SSM.sectionsdcid			=	sect.dcid
LEFT JOIN	PSM_SECTIONREADINESS		PSMSR
	ON			PSMSR.sectionid				=	SSM.sectionid
	AND			PSMSR.reportingtermid		=	SRTM.reportingtermid

WHERE	ter1.yearid						=	~(curyearid)
	AND	terb.storecode					=	'%param1%'
	AND	s.grade_level					IN	(%param3%)
	~[if.is.a.school]
		AND	sect.schoolid					=	~(curschoolid)
	[/if]

GROUP BY
	tea.lastfirst
	,	sch.abbreviation
	,	ter1.abbreviation
	,	c.course_name
	,	sect.section_number
	,	sect.expression
	,	terb.storecode

~[if#unv.%param2%=Yes]
HAVING
	SUM(NVL(PSMSR.VERIFIEDSTATUS,0))	=	0
[/if#unv]