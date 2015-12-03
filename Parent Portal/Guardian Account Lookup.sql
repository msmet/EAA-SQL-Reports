SELECT
	s.dcid
	,	sch.abbreviation
	,	s.student_number
	,	s.last_name
	,	s.first_name
	,	s.grade_level
	,	s.student_allowwebaccess
	,	s.allowwebaccess
	,	g.lastname
	,	g.firstname
	,	pcasa.username
	,	pcasec.emailaddress
	
FROM		students			s
INNER JOIN	schools				sch
	ON			sch.school_number		=	s.schoolid
INNER JOIN	guardianstudent		gs
	ON			gs.studentsdcid			=	s.dcid
INNER JOIN	Guardian			g
	ON			g.guardianid			=	gs.guardianid
LEFT JOIN	PCAS_Account		pcasa
	ON			pcasa.pcas_accounttoken	=	g.accountidentifier
LEFT JOIN	PCAS_EMAILCONTACT		pcasec
	ON			pcasec.pcas_accountid	=	pcasa.pcas_accountid

WHERE	s.enroll_status			=	0

~[if.is.a.school]
	AND s.schoolid 				=	~(curschoolid)
[/if]