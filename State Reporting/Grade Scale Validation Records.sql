SELECT
	sg.dcid
	,	'<a href=/admin/tech/usm/home.html?mcr=031'||sg.dcid||' target=_blank>DDA</a><br />'
	,	sg.schoolid
	,	NVL(sch.name,'NULL')
	,	sch.abbreviation
	,	sg.termid
	,	sg.storecode
	,	sg.course_name
	,	sg.course_number
	,	sg.gradescale_name
	,	nvl(sg.grade,'NULL')
	,	CASE WHEN	gsi.id		IS NULL THEN 'Mismatch' ELSE 'Match' END
	,	CASE
			WHEN (sg.termid = 2400 AND sg.storecode IN ('Y1','y1','14-15')) THEN 'Y1'
			WHEN (sg.termid = 2401 AND sg.storecode = 'S1') THEN 'S1'
			WHEN (sg.termid = 2402 AND sg.storecode = 'S2') THEN 'S2'
			WHEN (sg.termid = 2403 AND sg.storecode = 'Q1') THEN 'Q1'
			WHEN (sg.termid = 2404 AND sg.storecode = 'Q2') THEN 'Q2'
			WHEN (sg.termid = 2405 AND sg.storecode = 'Q3') THEN 'Q3'
			WHEN (sg.termid = 2406 AND sg.storecode = 'Q4') THEN 'Q4'
			ELSE 'Unknown'
			END

FROM		storedgrades		sg
LEFT JOIN	gradescaleitem		gs
	ON			gs.name				=	sg.gradescale_name
LEFT JOIN	gradescaleitem		gsi
	ON			gsi.gradescaleid	=	gs.id
	AND			gsi.name			=	sg.grade

LEFT JOIN	schools				sch
	ON			sch.school_number	=	sg.schoolid

WHERE		gsi.id IS NULL
	AND		((sg.termid = 2400 AND sg.storecode IN ('Y1','y1','14-15'))
	OR		(sg.termid = 2401 AND sg.storecode = 'S1')
	OR		(sg.termid = 2402 AND sg.storecode = 'S2')
	OR		(sg.termid = 2403 AND sg.storecode = 'Q1')
	OR		(sg.termid = 2404 AND sg.storecode = 'Q2')
	OR		(sg.termid = 2405 AND sg.storecode = 'Q3')
	OR		(sg.termid = 2406 AND sg.storecode = 'Q4'))