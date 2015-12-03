SELECT
	sect.dcid
	,	sch.school_number
	,	sch.name
	,	sch.abbreviation
	,	'<a href=/admin/sections/edit.html?page=sched&frn=003'||sect.dcid||CHR(38)||'lrn=005'||tea.dcid||CHR(38)||'tnum='||tea.TeacherNumber||' target=_blank>Edit</a>'
	,	tea.lastfirst
	,	NVL(ps_customfields.getTeacherscf(tea.id,'MI_REP_PIC'),'NULL')
	,	ter.abbreviation
	,	c.id
	,	c.course_name
	,	c.course_number
	,	sect.section_number
	,	sect.id
	,	(SELECT COUNT(distinct cc.dcid) FROM cc WHERE ABS(cc.sectionid) = sect.id AND cc.dateleft >= cc.dateenrolled + 10)
	,	TO_CHAR(ter.firstday,'MM/DD/YYYY')
	,	TO_CHAR(ter.lastday,'MM/DD/YYYY')
	,	(SELECT MAX(cc.dateleft - cc.dateenrolled) FROM cc WHERE ABS(cc.sectionid) = sect.id AND cc.dateleft >= cc.dateenrolled + 10)
	,	TO_CHAR((SELECT MIN(cc.dateenrolled) FROM cc WHERE ABS(cc.sectionid) = sect.id AND cc.dateleft >= cc.dateenrolled + 10),'MM/DD/YYYY')
	,	TO_CHAR((SELECT MAX(cc.dateleft) FROM cc WHERE ABS(cc.sectionid) = sect.id AND cc.dateleft >= cc.dateenrolled + 10),'MM/DD/YYYY')
	,	CASE		sect.ExcludeFromStoredGrades
			WHEN	2	THEN	'Sect Include'
			WHEN	1	THEN	'Sect Exclude'
			WHEN	0	THEN
				(CASE		c.ExcludeFromStoredGrades
					WHEN	0	THEN	'Crs Include'
					WHEN	1	THEN	'Crs Exclude'
				END)
		END
	,	CASE
			WHEN	sect.gradescaleid	IS NULL OR sect.gradescaleid = 0
				THEN	'Course'
			ELSE		'Section'
			END
	,	CASE
			WHEN	sect.gradescaleid	IS NULL OR sect.gradescaleid = 0
				THEN	gsic.name || ' (' || gsic.id || ')'
			ELSE		gsisect.name || ' (' || gsisect.id || ')'
			END
	,	CASE
			WHEN	ps_customfields.getcf('Courses',c.id,'MI_TSDL_Exclude') = '1'		THEN	'Course Excluded'
			WHEN	ps_customfields.getcf('Sections',sect.id,'MI_TSDL_Exclude') = '1'	THEN	'Section Excluded'
			ELSE	'Included'
			END
	,	'<a href=/admin/tech/dde/home.html?mcr=003'||sect.dcid||CHR(38)||'UF-003057'||sect.dcid||'=1'||CHR(38)||'ac=prim target=_blank>Excl. Sect.</a><BR />'||
		'<a href=/admin/tech/dde/home.html?mcr=003'||sect.dcid||CHR(38)||'UF-003057'||sect.dcid||'='||CHR(38)||'ac=prim target=_blank>Incl. Sect.</a><BR />'||
		'<a href=/admin/tech/dde/home.html?mcr=002'||c.dcid||CHR(38)||'UF-002086'||c.dcid||'=1'||CHR(38)||'ac=prim target=_blank>Excl. Crs.</a><BR />'||
		'<a href=/admin/tech/dde/home.html?mcr=002'||c.dcid||CHR(38)||'UF-002086'||c.dcid||'='||CHR(38)||'ac=prim target=_blank>Incl. Crs.</a>'
	,	CASE
			WHEN	SUM(CASE WHEN rd.islocked=1 AND (ps_customfields.getTeacherscf(t.id,'MI_REP_PIC') IS NULL or ps_customfields.getTeacherscf(t.id,'MI_REP_PIC') = 0) THEN 1 ELSE 0 END) > 0
				THEN	'Missing Lead Tea. PIC(s) Missing'
			ELSE		'No Lead Tea. PIC(s) Missing'  
			END
	,	CASE
			WHEN	(COUNT(DISTINCT CASE WHEN rd.id = 10 THEN t.id ELSE NULL END) > (CASE WHEN ps_customfields.getcf('Sections',sect.id,'MI_CoTeacher_PIC1') IS NULL THEN 0 ELSE 1 END + CASE WHEN ps_customfields.getcf('Sections',sect.id,'MI_CoTeacher_PIC2') IS NULL THEN 0 ELSE 1 END))
				THEN	'Missing CoTeacher PIC(s)'
			WHEN	(COUNT(DISTINCT CASE WHEN rd.id = 10 THEN t.id ELSE NULL END) < (CASE WHEN ps_customfields.getcf('Sections',sect.id,'MI_CoTeacher_PIC1') IS NULL THEN 0 ELSE 1 END + CASE WHEN ps_customfields.getcf('Sections',sect.id,'MI_CoTeacher_PIC2') IS NULL THEN 0 ELSE 1 END))
				THEN	'Too Many CoTeacher PICs(s)'
				ELSE	'Correct Number of CoTeacher PIC(s)'
				END
	,	NVL(ps_customfields.getcf('Sections',sect.id,'MI_CoTeacher_PIC1'),'NULL')
	,	NVL(ps_customfields.getcf('Sections',sect.id,'MI_CoTeacher_PIC2'),'NULL')
	,	LISTAGG(
			CASE
				WHEN	rd.islocked = 0 THEN	rd.name || ' ' || TO_CHAR(st.start_date,'MM/DD/YYYY') || '-' || TO_CHAR(st.end_date,'MM/DD/YYYY') || CHR(58) || ' ' || t.lastfirst || ', ' || ps_customfields.getTeacherscf(t.id,'MI_REP_PIC')||
					'<BR /><a href=/admin/tech/dde/home.html?mcr=003'||sect.dcid||CHR(38)||'UF-003059'||sect.dcid||'='||ps_customfields.getTeacherscf(t.id,'MI_REP_PIC')||CHR(38)||'ac=prim target=_blank>Set_CoPIC_1</a>'||
					'<BR /><a href=/admin/tech/dde/home.html?mcr=003'||sect.dcid||CHR(38)||'UF-003062'||sect.dcid||'='||ps_customfields.getTeacherscf(t.id,'MI_REP_PIC')||CHR(38)||'ac=prim target=_blank>Set_CoPIC_2</a>'
				ELSE	NULL
				END,'<BR /><u>__________________________</u><BR />') WITHIN GROUP (ORDER BY st.start_date, st.end_date)
	,	NVL(ps_customfields.getcf('Sections',sect.id,'MI_Mentor_Teacher'),'NULL')
	,	NVL(ps_customfields.getcf('Sections',sect.id,'MI_Virtual_Delivery'),'NULL')
	,	CASE	NVL(ps_customfields.getcf('Sections',sect.id,'MI_Virtual_Delivery'),'NULL')
			WHEN	'NULL'	THEN	'Not a Virtual Class Room'
			WHEN	'BL'	THEN	'(BL) Blended Learning'
			WHEN	'DL'	THEN	'(DL) Digital Learning'
			WHEN	'OC'	THEN	'(OC) Online Course'
			WHEN	'1'		THEN	'(1) Yes do not use.  Change to DL or OC'
			END
	,	'<a href=/admin/tech/dde/home.html?mcr=003'||sect.dcid||CHR(38)||'UF-003061'||sect.dcid||'='||CHR(38)||'ac=prim target=_blank>Not_Virt.</a><BR />'||
		'<a href=/admin/tech/dde/home.html?mcr=003'||sect.dcid||CHR(38)||'UF-003061'||sect.dcid||'=BL'||CHR(38)||'ac=prim target=_blank>Blend._L.</a><BR />'||
		'<a href=/admin/tech/dde/home.html?mcr=003'||sect.dcid||CHR(38)||'UF-003061'||sect.dcid||'=DL'||CHR(38)||'ac=prim target=_blank>Dig._L.</a><BR />'||
		'<a href=/admin/tech/dde/home.html?mcr=003'||sect.dcid||CHR(38)||'UF-003061'||sect.dcid||'=OC'||CHR(38)||'ac=prim target=_blank>Online</a>'
	,	LISTAGG(
			CASE
				WHEN	rd.islocked = 1 THEN	rd.name || ' ' || TO_CHAR(st.start_date,'MM/DD/YYYY') || '-' || TO_CHAR(st.end_date,'MM/DD/YYYY') || CHR(58) || ' ' || t.lastfirst || ', ' || ps_customfields.getTeacherscf(t.id,'MI_REP_PIC') 
				ELSE	NULL
				END,'<BR /><u>__________________________</u><BR />') WITHIN GROUP (ORDER BY st.start_date, st.end_date)



FROM		sections			sect
LEFT JOIN	teachers			tea
	ON			tea.id				=	sect.teacher
LEFT JOIN	schools				sch
	ON			sch.school_number	=	sect.schoolid
LEFT JOIN	courses				c
	ON			c.course_number		=	sect.course_number
LEFT JOIN	terms				ter
	ON			ter.id				=	sect.termid
	AND			ter.schoolid		=	sect.schoolid

LEFT JOIN	gradescaleitem		gsisect
	ON			gsisect.id			=	sect.gradescaleid
LEFT JOIN	gradescaleitem		gsic
	ON			gsic.id				=	c.gradescaleid

LEFT JOIN	sectionteacher		st
	ON			st.sectionid		=	sect.id
LEFT JOIN	roledef				rd
	ON			rd.id				=	st.roleid
LEFT JOIN	teachers			t
	ON			t.id				=	st.teacherid

WHERE	sect.schoolid				IN	(%param1%)
	AND	sect.schoolid				NOT IN	(44541,777777,999999,6666666,666666,11111)
	AND	ter.id					>=	%param3%00
	AND	ter.id					<=	%param3%06


GROUP BY
	sect.dcid
	,	sch.school_number
	,	sch.name
	,	sch.abbreviation
	,	tea.dcid
	,	tea.lastfirst
	,	tea.id
	,	tea.TeacherNumber
	,	ter.abbreviation
	,	c.dcid
	,	c.id
	,	c.course_name
	,	c.course_number
	,	sect.section_number
	,	sect.id
	,	sect.No_of_students	
	,	ter.firstday
	,	ter.lastday
	,	sect.gradescaleid
	,	sect.gradescaleid
	,	gsic.name
	,	gsic.id
	,	gsisect.name
	,	gsisect.id
	,	sect.ExcludeFromStoredGrades
	,	c.ExcludeFromStoredGrades