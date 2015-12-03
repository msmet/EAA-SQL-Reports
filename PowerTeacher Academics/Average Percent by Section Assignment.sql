SELECT
	c.course_name||chr(58)||' '||sect.section_number||' ('||sect.expression||')'
	,	t.lastfirst
	,	c.course_name
	,	sect.expression
	,	pga.name
	,	TO_CHAR(TO_DATE(pga.datedue),'MM/DD/YYYY')
	,	COUNT ( DISTINCT ssa.DCID)	AS	full_count
	,	(CASE
			WHEN	COUNT (DISTINCT ssa.dcid) > 0	THEN	CONCAT(CAST(cast(100*AVG(CAST(ssa.percent AS Decimal(38,1)))/100 as decimal(5,1)) AS varchar(10)),'%')
			ELSE	NULL
		END)

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
	AND			ter2.abbreviation	=	'%param1%'
INNER JOIN	pgassignments	pga
	ON			pga.sectionid		=	sect.id
	AND			pga.datedue			>=	ter2.firstday
	AND			pga.datedue			<=	ter2.lastday
LEFT JOIN	sectionscoresassignments	ssa
	ON			ssa.assignment		=	pga.id
	AND			ssa.exempt			!=	'1'
	AND			ssa.percent			IS NOT NULL

WHERE	t.id	=	~[x:userid]
	AND		ter1.yearid	=	'~(curyearid)'
	AND		sect.id IN (%param2%)

GROUP BY
	t.lastfirst
	,	c.course_name
	,	sect.section_number
	,	sect.expression
	,	pga.name
	,	pga.datedue

ORDER BY
	c.course_name
	,	sect.section_number
	,	sect.expression