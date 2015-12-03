SELECT
	t.lastfirst
	,	sect.grade_level
	,	c.course_name
	,	sect.id
	,	sect.expression
	,	ter.abbreviation
	,	terb.storecode
	,	COUNT(	DISTINCT	(CASE
								WHEN	cc.dateleft		>=	terb.date2
									THEN	cc.dcid
								ELSE		NULL
								END))
	,	TO_CHAR(TO_DATE(MAX(pgfg.lastgradeupdate)), 'MM/DD/YYYY')
	,	sr.verstatus
	,	sr.verdate
	,	sr.vercomment
	,	COUNT(	DISTINCT pga.dcid)
	,	COUNT(	DISTINCT	(CASE
								WHEN	pga.datedue		>=	terb.date1
									AND	pga.datedue		<	terb.date1	+7
									THEN	pga.dcid
								ELSE		NULL
								END))
	,	COUNT(	DISTINCT	(CASE
								WHEN	pga.datedue		>=	terb.date1	+7
									AND	pga.datedue		<	terb.date1	+14
									THEN	pga.dcid
								ELSE		NULL
								END))
	,	COUNT(	DISTINCT	(CASE
								WHEN	pga.datedue		>=	terb.date1	+14
									AND	pga.datedue		<	terb.date1	+21
									THEN	pga.dcid
								ELSE		NULL
								END))
	,	COUNT(	DISTINCT	(CASE
								WHEN	pga.datedue		>=	terb.date1	+21
									AND	pga.datedue		<	terb.date1	+28
									THEN	pga.dcid
								ELSE		NULL
								END))
	,	COUNT(	DISTINCT	(CASE
								WHEN	pga.datedue		>=	terb.date1	+28
									AND	pga.datedue		<	terb.date1	+35
									THEN	pga.dcid
								ELSE		NULL
								END))
	,	COUNT(	DISTINCT	(CASE
								WHEN	pga.datedue		>=	terb.date1	+35
									AND	pga.datedue		<	terb.date1	+42
									THEN	pga.dcid
								ELSE		NULL
								END))
	,	COUNT(	DISTINCT	(CASE
								WHEN	pga.datedue		>=	terb.date1	+42
									AND	pga.datedue		<	terb.date1	+49
									THEN	pga.dcid
								ELSE		NULL
								END))
	,	COUNT(	DISTINCT	(CASE
								WHEN	pga.datedue		>=	terb.date1	+49
									AND	pga.datedue		<	terb.date1	+56
									THEN	pga.dcid
								ELSE		NULL
								END))
	,	COUNT(	DISTINCT	(CASE
								WHEN	pga.datedue		>=	terb.date1	+56
									AND	pga.datedue		<	terb.date1	+63
									THEN	pga.dcid
								ELSE		NULL
								END))
	,	COUNT(	DISTINCT	(CASE
								WHEN	pga.datedue		>=	terb.date1	+63
									AND	pga.datedue		<	terb.date1	+70
									THEN	pga.dcid
								ELSE		NULL
								END))
	,	COUNT(	DISTINCT	(CASE
								WHEN	pga.datedue		>=	terb.date1	+70
									AND	pga.datedue		<	terb.date1	+77
									THEN	pga.dcid
								ELSE		NULL
								END))
	,	COUNT(	DISTINCT	(CASE
								WHEN	pga.datedue		>=	terb.date1	+77
									AND	pga.datedue		<	terb.date1	+84
									THEN	pga.dcid
								ELSE		NULL
								END))
	,	COUNT(	DISTINCT	(CASE
								WHEN	pga.datedue		>=	terb.date1	+84
									AND	pga.datedue		<	terb.date1	+91
									THEN	pga.dcid
								ELSE		NULL
								END))
	,	COUNT(	DISTINCT	(CASE
								WHEN	pga.datedue		>=	terb.date1	+91
									AND	pga.datedue		<	terb.date1	+98
									THEN	pga.dcid
								ELSE		NULL
								END))
	,	COUNT(	DISTINCT	(CASE
								WHEN	pga.datedue		>=	terb.date1	+98
									AND	pga.datedue		<	terb.date1	+105
									THEN	pga.dcid
								ELSE		NULL
								END))
	,	COUNT(	DISTINCT	(CASE
								WHEN	pga.datedue		>=	terb.date1	+105
									AND	pga.datedue		<	terb.date1	+112
									THEN	pga.dcid
								ELSE		NULL
								END))
	,	COUNT(	DISTINCT	(CASE
								WHEN	pga.datedue		>=	terb.date1	+112
									AND	pga.datedue		<	terb.date1	+119
									THEN	pga.dcid
								ELSE		NULL
								END))
	,	COUNT(	DISTINCT	(CASE
								WHEN	pga.datedue		>=	terb.date1	+119
									AND	pga.datedue		<	terb.date1	+126
									THEN	pga.dcid
								ELSE		NULL
								END))
	,	COUNT(	DISTINCT	(CASE
								WHEN	pga.datedue		>=	terb.date1	+126
									AND	pga.datedue		<	terb.date1	+133
									THEN	pga.dcid
								ELSE		NULL
								END))
	,	COUNT(	DISTINCT	(CASE
								WHEN	pga.datedue		>=	terb.date1	+133
									AND	pga.datedue		<	terb.date1	+140
									THEN	pga.dcid
								ELSE		NULL
								END))
	
FROM 		cc
INNER JOIN	sections		sect
	ON			(sect.id				=	cc.sectionid
			OR	sect.id				=	-cc.sectionid)
INNER JOIN	teachers		t
	ON			t.id				=	sect.teacher
INNER JOIN	terms			ter
	ON			ter.id				=	sect.termid
	AND			ter.schoolid		=	sect.schoolid
	AND			ter.yearid			=	~(curyearid)
INNER JOIN	termbins		terb
	ON			terb.termid			=	ter.id
	AND			terb.schoolid		=	ter.schoolid
	AND			terb.yearid			=	ter.yearid
INNER JOIN	courses			c
	ON			c.course_number		=	cc.course_number
LEFT JOIN	pgassignments	pga
	ON			pga.sectionid		=	sect.id
	AND			pga.datedue			>=	terb.date1
	AND			pga.datedue			<=	terb.date2
LEFT JOIN	pgfinalgrades	pgfg
	ON			pgfg.sectionid		=	ABS(cc.sectionid)
	AND			pgfg.studentid		=	cc.studentid
	AND			pgfg.finalgradename	=	terb.storecode

LEFT JOIN
(
	SELECT 
		sect.id
		,	CASE
				WHEN	SUM(PSMSR.VERIFIEDSTATUS)	>	0	THEN	'Yes'
				ELSE												'No'
				END	AS	verstatus
		,	listagg(PSMSR.VERIFIEDDATE,'') WITHIN GROUP (ORDER BY terb.dcid)	AS	verdate
		,	listagg(PSMSR.VERIFIEDCOMMENT,'') WITHIN GROUP (ORDER BY terb.dcid)	AS	vercomment

		FROM		SECTIONS 					sect
		INNER JOIN	COURSES						c
			ON			c.course_number				=	sect.course_number
		INNER JOIN	TEACHERS					tea
			ON			tea.id						=	sect.teacher
		INNER JOIN	SCHOOLS						sch
			ON			sch.school_number			=	sect.schoolid
		INNER JOIN	TERMS 						ter
			ON			ter.id						=	sect.termid
			AND			ter.schoolid				=	sect.schoolid
			AND			ter.yearid					=	~(curyearid)
		INNER JOIN	TERMBINS					terb
			ON			terb.schoolid				=	ter.schoolid
			AND			terb.yearid					=	ter.yearid
			AND			terb.termid					=	ter.id
		LEFT JOIN	SYNC_REPORTINGTERMMAP		SRTM
			ON			SRTM.termbinsdcid			=	terb.dcid
		LEFT JOIN	SYNC_SECTIONMAP				SSM
			ON			SSM.sectionsdcid			=	sect.dcid
		LEFT JOIN	PSM_SECTIONREADINESS		PSMSR
			ON			PSMSR.sectionid				=	SSM.sectionid
			AND			PSMSR.reportingtermid		=	SRTM.reportingtermid

		WHERE	terb.storecode						=	'%param1%'
		~[if.is.a.school]
			AND	sect.schoolid						=	~(curschoolid)
		[/if]
		GROUP BY
			sect.id
)	sr
	ON		sr.id		=	sect.id

WHERE	terb.storecode			=	'%param1%'
	~[if.is.a.school]
		AND	cc.schoolid				= ~(curschoolid)
	[/if]
	AND (
			sect.excludefromgpa		!=	1
		OR	(sect.excludefromgpa	!=	0
		AND	c.excludefromgpa		!=	1))

GROUP BY
	t.lastfirst
	,	sect.grade_level
	,	c.course_name
	,	sect.id
	,	sect.expression
	,	ter.abbreviation
	,	terb.storecode
	,	sr.verstatus
	,	sr.verdate
	,	sr.vercomment