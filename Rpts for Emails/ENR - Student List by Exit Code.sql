SELECT
	sch.name
	,	s.student_number
	,	s.lastfirst
	,	s.grade_level
	,	TO_CHAR(s.entrydate,'MM/DD/YYYY')
	,	TO_CHAR(s.exitdate,'MM/DD/YYYY')
	,	s.exitcode
	,	s.street
	,	s.city
	,	s.state
	,	s.zip
	,	s.home_phone
	,	ps_customfields.getStudentscf(s.id,'mother_home_phone')
	,	ps_customfields.getStudentscf(s.id,'motherdayphone')
	,	ps_customfields.getStudentscf(s.id,'father_home_phone')
	,	ps_customfields.getStudentscf(s.id,'fatherdayphone')
	,	ps_customfields.getStudentscf(s.id,'guardiandayphone')
	,	s.emerg_phone_1
	,	s.emerg_phone_2
	,	ps_customfields.getStudentscf(s.id,'emerg_3_phone')

FROM		students				s
LEFT JOIN	schools					sch
	ON			sch.School_Number			=	s.enrollment_schoolid

WHERE	s.exitdate			>=		'%param1%'
	AND	s.exitdate			<=		'%param2%'
	AND	s.schoolid			NOT IN	(45541,777777,999999,6666666,666666,11111)
	AND	s.exitcode			IN		(%param3%)
	AND	s.schoolid 			IN		(%param4%)