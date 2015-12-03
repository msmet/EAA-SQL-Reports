SELECT
	t.id
	,	sect.schoolid
	,	t.email_addr
	,	t.first_name
	,	t.last_name
	,	sect.course_number
	
FROM		sections	sect
INNER JOIN	teachers	t
		ON		t.id		=	sect.teacher
INNER JOIN	terms		ter
		ON		ter.id		=	sect.termid
INNER JOIN	section_meeting	sm
		ON		sm.sectionid	=	sect.id
INNER JOIN	period			p
		ON		p.period_number	=	sm.period_number
		AND		p.schoolid		=	sm.schoolid
		AND		p.year_id		=	sm.year_id

WHERE	ter.firstday			<=	'~[short.date]'
	AND	ter.lastday				>=	'~[short.date]'
	AND	sect.course_number		LIKE	'HS%RS%'
	AND	(p.abbreviation			LIKE	'CR%'
		OR	sect.schoolid		=	902)

GROUP BY
	t.id
	,	sect.schoolid
	,	t.email_addr
	,	t.first_name
	,	t.last_name
	,	sect.course_number