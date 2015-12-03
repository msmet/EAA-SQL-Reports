SELECT
	s.student_number
	,	sect.schoolid
	,	s.first_name
	,	s.last_name
	,	s.grade_level
	,	TO_CHAR(cc.dateenrolled,'MM/DD/YYYY')
	,	TO_CHAR(s.dob,'MM/DD/YYYY')
	,	s.home_phone
	,	s.gender
	,	cc.course_number
	,	TO_CHAR(cc.dateleft,'MM/DD/YYYY')
	
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
INNER JOIN	cc
		ON		cc.sectionid	=	ABS(sect.id)
INNER JOIN	students		s
		ON		s.id			=	cc.studentid

WHERE	ter.firstday			<=	'~[short.date]'
	AND	ter.lastday				>=	'~[short.date]'
	AND	cc.dateleft				>=	'~[short.date]'
	AND	sect.course_number		LIKE	'HS%RS%'
	AND	(p.abbreviation			LIKE	'CR%'
		OR	sect.schoolid		=	902)

GROUP BY
	s.student_number
	,	sect.schoolid
	,	s.first_name
	,	s.last_name
	,	s.grade_level
	,	TO_CHAR(cc.dateenrolled,'MM/DD/YYYY')
	,	TO_CHAR(s.dob,'MM/DD/YYYY')
	,	s.home_phone
	,	s.gender
	,	cc.course_number
	,	TO_CHAR(cc.dateleft,'MM/DD/YYYY')