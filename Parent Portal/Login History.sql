SELECT
	s.dcid
	,	sch.abbreviation
	,	s.student_number
	,	s.id
	,	s.lastfirst
	,	s.grade_level
	,	(CASE	s.enroll_status
			WHEN	0			THEN	'Active'
			ELSE						'Inactive'
			END
		)	AS	enroll_state
	,	g.lastname
	,	g.firstname
	,	pcasa.username
	,	pcasec.emailaddress
	,	TO_CHAR(TO_DATE(CAST(pcasaah.LoginAttemptDate AS DATE)), 'MM/DD/YYYY')
	,	(CASE	pcasaah.IsLoginSuccessful
			WHEN	1			THEN	'Successful'
			ELSE						'Unsuccessful'
			END
		)	AS	success_flag
	
FROM		students			s
INNER JOIN	schools				sch
	ON			sch.school_number		=	s.schoolid
INNER JOIN	guardianstudent		gs
	ON			gs.studentsdcid			=	s.dcid
INNER JOIN	Guardian			g
	ON			g.guardianid			=	gs.guardianid
INNER JOIN	PCAS_Account		pcasa
	ON			pcasa.pcas_accounttoken	=	g.accountidentifier
INNER JOIN	PCAS_EMAILCONTACT		pcasec
	ON			pcasec.pcas_accountid	=	pcasa.pcas_accountid

INNER JOIN	PCAS_AccountAccessHist		pcasaah
	ON			pcasaah.pcas_accountid	=	pcasa.pcas_accountid

WHERE	CAST(pcasaah.LoginAttemptDate AS DATE)	>=	'%param1%'
	AND	CAST(pcasaah.LoginAttemptDate AS DATE)	<=	'%param2%'

~[if.is.a.school]
	AND s.schoolid 				=	~(curschoolid)
[/if]