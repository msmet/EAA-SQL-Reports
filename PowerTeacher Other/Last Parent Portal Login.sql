SELECT
	s.lastfirst
	,	s.grade_level
	,	g.lastname
	,	g.firstname
	,	pcasec.emailaddress
	,	TO_CHAR(TO_DATE(MAX(pcasaah.LoginAttemptDate), 'MM-DD-YYYY HH24-MI-SS'), 'MM/DD/YYYY')
	
FROM		teachers		t
INNER JOIN	sections		sect
	ON			sect.teacher		=	t.id
INNER JOIN	courses			c
	ON			c.course_number		=	sect.course_number
INNER JOIN	cc
	ON			cc.sectionid		=	sect.id
	AND			cc.dateenrolled		<=	'~[short.date]'
	AND			cc.dateleft			>	'~[short.date]'
INNER JOIN	students			s
	ON			s.id				=	cc.studentid
INNER JOIN	schools				sch
	ON			sch.school_number		=	s.schoolid
INNER JOIN	guardianstudent		gs
	ON			gs.studentsdcid			=	s.dcid
LEFT JOIN	Guardian			g
	ON			g.guardianid			=	gs.guardianid
LEFT JOIN	PCAS_Account		pcasa
	ON			pcasa.pcas_accounttoken	=	g.accountidentifier
LEFT JOIN	PCAS_EMAILCONTACT		pcasec
	ON			pcasec.pcas_accountid	=	pcasa.pcas_accountid
LEFT JOIN	PCAS_AccountAccessHist		pcasaah
	ON			pcasaah.pcas_accountid	=	pcasa.pcas_accountid

WHERE	(pcasaah.IsLoginSuccessful					=	1
	or	pcasaah.IsLoginSuccessful	IS NULL)

GROUP BY
	s.lastfirst
	,	s.grade_level
	,	g.lastname
	,	g.firstname
	,	pcasec.emailaddress