SELECT
	sect.dcid
	,	sch.school_number
	,	sch.abbreviation
	,	sch.name
	,	'<a href=/admin/faculty/home.html'||CHR(63)||'FRN=005'||t.dcid||CHR(38)||'request_locale=en_US'||CHR(38)||'xselectteacher=nosearch'||CHR(38)||'helpLink='||CHR(37)||'2Fadmin'||CHR(37)||'2Fhelp'||CHR(37)||'2Fhow_to'||CHR(37)||'2Ffa_07a_inform_teacher_view.html'||CHR(38)||'currentResource=admin'||CHR(37)||'2Ffaculty'||CHR(37)||'2Fhome.html>Teacher Link</a>'
	,	t.id
	,	t.SIF_StatePrid
	,	t.lastfirst
	,	LISTAGG ( teaB.lastfirst || ' (' || rd.name || ')', chr(38) || ' ') WITHIN GROUP  (ORDER BY teaB.lastfirst)
	,	ter.abbreviation
	,	sect.expression
	,	c.course_name
	,	c.course_number
	,	sect.section_number	
	,	sect.no_of_students
	
FROM		sections			sect
INNER JOIN	terms				ter
	ON			ter.id				=	sect.termid
	AND			ter.schoolid		=	sect.schoolid
INNER JOIN	courses				c
	ON			c.course_number		=	sect.course_number
INNER JOIN	teachers			t
	ON			t.id				=	sect.teacher
INNER JOIN	schools				sch
	ON			sch.school_number	=	sect.schoolid
LEFT JOIN	sectionteacher		st
	ON			st.sectionid		=	sect.id
	AND			st.teacherid		!=	t.id
LEFT JOIN	roledef				rd
	ON			rd.id				=	st.roleid
LEFT JOIN	teachers			teaB
	ON			teaB.id				=	st.teacherid

WHERE	ter.yearid													=		%param1%
	AND	sect.schoolid												NOT IN	(45541,777777,999999,6666666,666666,11111,0)
	AND	sect.schoolid												IN	(%param2%)

GROUP BY
	sect.dcid
	,	sch.school_number
	,	sch.abbreviation
	,	sch.name
	,	t.dcid
	,	t.id
	,	t.SIF_StatePrid
	,	t.lastfirst
	,	ter.abbreviation
	,	sect.expression
	,	c.course_name
	,	c.course_number
	,	sect.section_number	
	,	sect.no_of_students