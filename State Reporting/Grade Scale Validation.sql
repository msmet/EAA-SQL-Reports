SELECT
	sg.schoolid
	,	sch.name
	,	sch.abbreviation
	,	sg.termid
	,	sg.storecode
	,	sg.course_name
	,	sg.course_number
	,	sg.gradescale_name
	,	sg.grade
	,	CASE WHEN	gsi.id		IS NULL THEN 'Mismatch' ELSE 'Match' END
	,	count(*)
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
	,	'<a href=/admin/tech/usm/home.html'||CHR(63)||'ac=usm'||CHR(38)||'filenum=31'||CHR(38)||'search=submit target=_blank>Link 1</a><br />
		<a href=/admin/tech/usm/home.html'||CHR(63)||'ac=usm'||CHR(38)||'fieldnum_1=18'||CHR(38)||'comparator1=='||CHR(38)||'value='||sg.schoolid||CHR(38)||'fieldnum_2=22'||CHR(38)||'comparator2=='||CHR(38)||'value='||sg.gradescale_name||CHR(38)||'search=submit'||CHR(38)||' target=_blank>Link 1</a><br />
		<a href=/admin/tech/usm/home.html'||CHR(63)||'ac=usm'||CHR(38)||'fieldnum_1=3'||CHR(38)||'comparator1=='||CHR(38)||'value='||sg.termid||CHR(38)||'fieldnum_2=4'||CHR(38)||'comparator2=='||CHR(38)||'value='||sg.storecode||CHR(38)||'search=submit'||CHR(38)||' target=_blank>Link 2</a><br />
		<a href=/admin/tech/usm/home.html'||CHR(63)||'ac=usm'||CHR(38)||'fieldnum_1=15'||CHR(38)||'comparator1=='||CHR(38)||'value='||sg.course_number||CHR(38)||'fieldnum_2=6'||CHR(38)||'comparator2=='||CHR(38)||'value='||sg.grade||CHR(38)||'search=submit'||CHR(38)||' target=_blank>Link 3</a><br />
		<a href=/admin/tech/usm/home.html'||CHR(63)||'ac=usm'||CHR(38)||'fieldnum_1=14'||CHR(38)||'comparator1=='||CHR(38)||'value='||sg.course_name||CHR(38)||'search=submit'||CHR(38)||' target=_blank>Link 4</a>'
		
	

FROM		storedgrades		sg
LEFT JOIN	gradescaleitem		gs
	ON			gs.name				=	sg.gradescale_name
LEFT JOIN	gradescaleitem		gsi
	ON			gsi.gradescaleid	=	gs.id
	AND			gsi.name			=	sg.grade

LEFT JOIN	schools				sch
	ON			sch.school_number	=	sg.schoolid

WHERE		sg.termid	>=	2400
	AND		sg.termid	<=	2406
	
GROUP BY
	sg.schoolid
	,	sch.name
	,	sch.abbreviation
	,	sg.termid
	,	sg.storecode
	,	sg.course_name
	,	sg.course_number
	,	sg.gradescale_name
	,	sg.grade
	,	CASE WHEN	gsi.id		IS NULL THEN 'Mismatch' ELSE 'Match' END	