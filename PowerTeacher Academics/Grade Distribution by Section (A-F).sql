SELECT
	t.lastfirst
	,	c.course_name
	,	sect.expression
	,	COUNT ( DISTINCT CC.DCID)	AS	full_count
	,	CONCAT(CAST(cast(100*SUM(CASE WHEN pgfg.grade IN ('A+','A','A-') THEN 1 ELSE 0 END)/count(*) as decimal(4,1)) AS varchar(10)),'%') AS A_perc
	,	CONCAT(CAST(cast(100*SUM(CASE WHEN pgfg.grade IN ('B+','B','B-') THEN 1 ELSE 0 END)/count(*) as decimal(4,1)) AS varchar(10)),'%') AS B_perc
	,	CONCAT(CAST(cast(100*SUM(CASE WHEN pgfg.grade IN ('C+','C','C-') THEN 1 ELSE 0 END)/count(*) as decimal(4,1)) AS varchar(10)),'%') AS C_perc
	,	CONCAT(CAST(cast(100*SUM(CASE WHEN pgfg.grade IN ('D+','D','D-') THEN 1 ELSE 0 END)/count(*) as decimal(4,1)) AS varchar(10)),'%') AS D_perc
	,	CONCAT(CAST(cast(100*SUM(CASE WHEN pgfg.grade IN ('F') THEN 1 ELSE 0 END)/count(*) as decimal(4,1)) AS varchar(10)),'%') AS F_perc
	,	CONCAT(CAST(cast(100*SUM(CASE WHEN pgfg.grade NOT IN ('A+','A','A-','B+','B','B-','C+','C','C-','D+','D','D-','F') THEN 1 ELSE 0 END)/count(*) as decimal(4,1)) AS varchar(10)),'%') AS OTHER_perc
	,	CONCAT(CAST(cast(100*SUM(CASE WHEN pgfg.grade IS NULL THEN 1 ELSE 0 END)/count(*) as decimal(4,1)) AS varchar(10)),'%') AS MISSING_perc


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
INNER JOIN	gradescaleitem	gs
	ON			(gs.id				=	sect.gradescaleid
		OR		(sect.gradescaleid	=	0
			AND	gs.id				=	c.gradescaleid))
INNER JOIN	gradescaleitem	gsi
	ON			gsi.gradescaleid	=	gs.id
	AND			gsi.name			=	'4'
LEFT JOIN	cc
	ON			cc.sectionid			=	sect.id
	AND			cc.dateleft				>=	ter2.lastday
~[if#pgfg.%param2%=Yes]
	LEFT JOIN            storedgrades     pgfg
[else#pgfg]
	LEFT JOIN            pgfinalgrades     pgfg
[/if#pgfg]
	ON			pgfg.studentid			=	cc.studentid
	AND			pgfg.sectionid			=	cc.sectionid
~[if#pgfg.%param2%=Yes]
	AND			pgfg.storecode		=	ter2.abbreviation
[else#pgfg]
	AND			pgfg.finalgradename		=	ter2.abbreviation
[/if#pgfg]	

WHERE	t.id	=	~[x:userid]
	AND		ter1.yearid	=	'~(curyearid)'

GROUP BY
	t.lastfirst
	,	c.course_name
	,	sect.expression