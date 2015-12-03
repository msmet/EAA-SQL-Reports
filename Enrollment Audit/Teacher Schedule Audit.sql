SELECT
	t.dcid
	,	sch.name
	,	t.lastfirst
	,	NVL(t.SIF_StatePrid,'NULL')
	,	NVL(t.Email_Addr,'NULL')
	,	c.course_name
	,	c.course_number
	,	sect.section_number
	,	ter.abbreviation
	,	sect.expression
	,	sect.no_of_students
	,	sect.id

FROM		teachers			t
INNER JOIN	sections			sect
		ON		sect.teacher	=	t.id
INNER JOIN	courses				c
		ON		c.course_number	=	sect.course_number
INNER JOIN	schools				sch
		ON		sch.school_number	=	sect.schoolid
INNER JOIN	terms				ter
		ON		ter.id			=	sect.termid
		AND		ter.schoolid	=	sect.schoolid


WHERE	ter.yearid		=	%param1%
	AND	sect.schoolid	IN	(%param2%)