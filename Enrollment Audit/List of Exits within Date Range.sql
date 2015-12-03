SELECT
	s.dcid
	,	sch.name
	,	s.id
	,	s.student_number
	,	s.lastfirst
	,	to_char(s.dob, 'MM/DD/YYYY')
	,	PSER.grade_level
	,	TO_CHAR(PSER.entrydate,'MM/DD/YYYY')
	,	TO_CHAR(PSER.exitdate,'MM/DD/YYYY')
	,	PSER.exitcode
	,	g.name
	,	PSER.exitcomment
	,	S.enroll_status
	,	schB.name
	
FROM		ps_enrollment_reg	pser
INNER JOIN	students			s
		ON		s.id				=	PSER.studentid
INNER JOIN	schools				sch
		ON		sch.school_number	=	pser.schoolid
INNER JOIN	schools				schb
		ON		schb.school_number	=	s.schoolid
INNER JOIN	gen					g
		ON		g.name				=	PSER.exitcode
		AND		g.cat				=	'exitcodes'
		
WHERE	PSER.exitdate			>=	'%param1%'
	AND	PSER.exitdate			<=	'%param2%'
	AND	s.enroll_status			IN	(%param3%)