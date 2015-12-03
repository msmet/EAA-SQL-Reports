SELECT
	sch.school_number		AS	a
	,	sch.abbreviation	AS	b
	,	sch.name			AS	c
	,	'<a href=/admin/faculty/home.html'||CHR(63)||'FRN=005'||t.dcid||CHR(38)||'request_locale=en_US'||CHR(38)||'xselectteacher=nosearch'||CHR(38)||'helpLink='||CHR(37)||'2Fadmin'||CHR(37)||'2Fhelp'||CHR(37)||'2Fhow_to'||CHR(37)||'2Ffa_07a_inform_teacher_view.html'||CHR(38)||'currentResource=admin'||CHR(37)||'2Ffaculty'||CHR(37)||'2Fhome.html>Teacher Link</a>'
	,	t.id				AS	d
	,	t.lastfirst			AS	e
	,	TO_CHAR(CAST(MIN(st.start_date) AS DATE),'MM/DD/YYYY')||' - '||TO_CHAR(CAST(MAX(st.end_date) AS DATE),'MM/DD/YYYY')
	,	LISTAGG(c.course_name||' ('|| rd.name ||' '|| TO_CHAR(CAST(st.start_date AS DATE),'MM/DD/YYYY')||'-'||TO_CHAR(CAST(st.end_date AS DATE),'MM/DD/YYYY') ||')',', <br />') WITHIN GROUP (ORDER BY c.course_name, rd.name, st.start_date)
	,	ps_customfields.getTeacherscf(t.id,'MI_REP_PIC')
	
	
FROM		sections			sect
INNER JOIN	terms		ter
	ON			ter.id				=	sect.termid
	AND			ter.schoolid		=	sect.schoolid
INNER JOIN	courses				c
	ON			c.course_number		=	sect.course_number
INNER JOIN	sectionteacher		st
	ON			st.sectionid		=	sect.id
	AND			st.end_date			>=	st.start_date + 10
LEFT JOIN	roledef				rd
	ON			rd.id				=	st.roleid
INNER JOIN	teachers			t
	ON			st.teacherid		=	t.id
INNER JOIN	schools				sch
	ON			sch.school_number	=	sect.schoolid

WHERE	ter.yearid													=		%param1%
	AND	sect.schoolid												NOT IN	(45541,777777,999999,6666666,666666,11111,0)
	AND	ps_customfields.getSectionscf(sect.id,'MI_TSDL_Exclude')	IS		NULL
	AND	ps_customfields.getCoursescf(c.id,'MI_TSDL_Exclude')		IS		NULL
	AND	(SELECT COUNT (*) FROM CC WHERE ABS(cc.sectionid) = sect.id AND cc.dateleft >= cc.dateenrolled + 10) > 0
~[if#p3.%param3%=Yes]
	AND		(ps_customfields.getTeacherscf(t.id,'MI_REP_PIC')	IS 		NULL
		OR	ps_customfields.getTeacherscf(t.id,'MI_REP_PIC')	=		'')
[/if#p3]


GROUP BY
	sch.school_number
	,	sch.abbreviation
	,	sch.name
	,	t.id
	,	ps_customfields.getTeacherscf(t.id,'MI_REP_PIC')
	,	t.lastfirst
	,	t.dcid