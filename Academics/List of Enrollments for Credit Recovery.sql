SELECT
	s.dcid
	,	sch.name
	,	s.id
	,	s.student_number
	,	s.lastfirst
	,	s.grade_level
	,	sectA.termid
	,	terA.abbreviation
	,	cA.course_name
	,	sectA.course_number||'.'||sectA.section_number
	,	sectA.expression
	,	cA.credittype
	,	tA.lastfirst
	,	LISTAGG(sectB.termid,', <br />') WITHIN GROUP (ORDER BY sg.dcid)
	,	LISTAGG(sg.storecode,', <br />') WITHIN GROUP (ORDER BY sg.dcid)
	,	LISTAGG(sg.teacher_name,', <br />') WITHIN GROUP (ORDER BY sg.dcid)
	,	LISTAGG(cB.course_name,', <br />') WITHIN GROUP (ORDER BY sg.dcid)
	,	LISTAGG(sectB.course_number||'.'||sectB.section_number,', <br />') WITHIN GROUP (ORDER BY sg.dcid)
	,	LISTAGG(sectB.expression,', <br />') WITHIN GROUP (ORDER BY sg.dcid)
	,	LISTAGG(sg.grade,', <br />') WITHIN GROUP (ORDER BY sg.dcid)
	,	LISTAGG(sg.earnedcrhrs,', <br />') WITHIN GROUP (ORDER BY sg.dcid)
	,	LISTAGG(sg.potentialcrhrs,', <br />') WITHIN GROUP (ORDER BY sg.dcid)

FROM		students		s
INNER JOIN	cc
		ON		cc.studentid	=	s.id
		AND		cc.dateleft		>	'~[short.date]'
INNER JOIN	sections		sectA
		ON		sectA.id		=	cc.sectionid
INNER JOIN	courses			cA
		ON		cA.course_number=	cc.course_number
INNER JOIN	teachers		tA
		ON		tA.id			=	sectA.teacher
INNER JOIN	terms			terA
		ON		terA.id			=	sectA.termid
		AND		terA.schoolid	=	sectA.schoolid
INNER JOIN	schools			sch
		ON		sch.school_number	=	sectA.schoolid

INNER JOIN	storedgrades	sg
		ON		sg.studentid	=	s.id
		AND		sg.credit_type	=	cA.credittype
		AND		sg.earnedcrhrs	=	0
		AND		sg.potentialcrhrs > 0
LEFT JOIN	sections		sectB
		ON		sectB.id		=	sg.sectionid
LEFT JOIN	courses			cB
		ON		cB.course_number=	sg.course_number
LEFT JOIN	terms			terB
		ON		terB.id			=	sg.termid
		AND		terB.schoolid	=	sg.schoolid

WHERE	s.enroll_status = 0
	AND	s.schoolid IN (%param1%)

GROUP BY
	s.dcid
	,	sch.name
	,	s.id
	,	s.student_number
	,	s.lastfirst
	,	s.grade_level
	,	sectA.termid
	,	terA.abbreviation
	,	cA.course_name
	,	cA.credittype
	,	tA.lastfirst
	,	sectA.course_number
	,	sectA.section_number
	,	sectA.expression