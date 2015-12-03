SELECT
	sect.dcid
	,	sch.abbreviation
	,	t.lastfirst
	,	terA.abbreviation
	,	c.course_name
	,	sect.section_number
	,	sect.expression
	,	gs.name
	,	LISTAGG(psmsta.identifier,',<BR />') WITHIN GROUP (ORDER BY psmsta.identifier)
	,	LISTAGG(
			NVL((SELECT
				COUNT (DISTINCT psmsa.id)
			FROM		PSM_SECTIONASSIGNMENT	psmsa
			INNER JOIN	PSM_ASSIGNMENTSTANDARD	psmas
				ON	psmas.SECTIONASSIGNMENTID		=	psmsa.ID
			WHERE	psmsa.SECTIONID					=	psms.ID
				AND	psmas.standardid				=	psmsta.ID),0),',<BR />') WITHIN GROUP (ORDER BY psmsta.identifier)
	,	LISTAGG(
			NVL((SELECT
				COUNT (DISTINCT psmsa.id)
			FROM		PSM_SECTIONASSIGNMENT	psmsa
			INNER JOIN	PSM_ASSIGNMENTSTANDARD	psmas
				ON	psmas.SECTIONASSIGNMENTID		=	psmsa.ID
			WHERE	psmsa.SECTIONID					=	psms.ID
				AND	psmas.standardid				=	psmsta.ID
				AND	psmsa.dateassignmentdue			>=	terA.firstday
				AND	psmsa.dateassignmentdue			<	terA.firstday	+7),0),',<BR />') WITHIN GROUP (ORDER BY psmsta.identifier)
	,	LISTAGG(
			NVL((SELECT
				COUNT (DISTINCT psmsa.id)
			FROM		PSM_SECTIONASSIGNMENT	psmsa
			INNER JOIN	PSM_ASSIGNMENTSTANDARD	psmas
				ON	psmas.SECTIONASSIGNMENTID		=	psmsa.ID
			WHERE	psmsa.SECTIONID					=	psms.ID
				AND	psmas.standardid				=	psmsta.ID
				AND	psmsa.dateassignmentdue			>=	terA.firstday	+7
				AND	psmsa.dateassignmentdue			<	terA.firstday	+14),0),',<BR />') WITHIN GROUP (ORDER BY psmsta.identifier)
	,	LISTAGG(
			NVL((SELECT
				COUNT (DISTINCT psmsa.id)
			FROM		PSM_SECTIONASSIGNMENT	psmsa
			INNER JOIN	PSM_ASSIGNMENTSTANDARD	psmas
				ON	psmas.SECTIONASSIGNMENTID		=	psmsa.ID
			WHERE	psmsa.SECTIONID					=	psms.ID
				AND	psmas.standardid				=	psmsta.ID
				AND	psmsa.dateassignmentdue			>=	terA.firstday	+14
				AND	psmsa.dateassignmentdue			<	terA.firstday	+21),0),',<BR />') WITHIN GROUP (ORDER BY psmsta.identifier)
	,	LISTAGG(
			NVL((SELECT
				COUNT (DISTINCT psmsa.id)
			FROM		PSM_SECTIONASSIGNMENT	psmsa
			INNER JOIN	PSM_ASSIGNMENTSTANDARD	psmas
				ON	psmas.SECTIONASSIGNMENTID		=	psmsa.ID
			WHERE	psmsa.SECTIONID					=	psms.ID
				AND	psmas.standardid				=	psmsta.ID
				AND	psmsa.dateassignmentdue			>=	terA.firstday	+21
				AND	psmsa.dateassignmentdue			<	terA.firstday	+28),0),',<BR />') WITHIN GROUP (ORDER BY psmsta.identifier)
	,	LISTAGG(
			NVL((SELECT
				COUNT (DISTINCT psmsa.id)
			FROM		PSM_SECTIONASSIGNMENT	psmsa
			INNER JOIN	PSM_ASSIGNMENTSTANDARD	psmas
				ON	psmas.SECTIONASSIGNMENTID		=	psmsa.ID
			WHERE	psmsa.SECTIONID					=	psms.ID
				AND	psmas.standardid				=	psmsta.ID
				AND	psmsa.dateassignmentdue			>=	terA.firstday	+28
				AND	psmsa.dateassignmentdue			<	terA.firstday	+35),0),',<BR />') WITHIN GROUP (ORDER BY psmsta.identifier)
	,	LISTAGG(
			NVL((SELECT
				COUNT (DISTINCT psmsa.id)
			FROM		PSM_SECTIONASSIGNMENT	psmsa
			INNER JOIN	PSM_ASSIGNMENTSTANDARD	psmas
				ON	psmas.SECTIONASSIGNMENTID		=	psmsa.ID
			WHERE	psmsa.SECTIONID					=	psms.ID
				AND	psmas.standardid				=	psmsta.ID
				AND	psmsa.dateassignmentdue			>=	terA.firstday	+35
				AND	psmsa.dateassignmentdue			<	terA.firstday	+42),0),',<BR />') WITHIN GROUP (ORDER BY psmsta.identifier)
	,	LISTAGG(
			NVL((SELECT
				COUNT (DISTINCT psmsa.id)
			FROM		PSM_SECTIONASSIGNMENT	psmsa
			INNER JOIN	PSM_ASSIGNMENTSTANDARD	psmas
				ON	psmas.SECTIONASSIGNMENTID		=	psmsa.ID
			WHERE	psmsa.SECTIONID					=	psms.ID
				AND	psmas.standardid				=	psmsta.ID
				AND	psmsa.dateassignmentdue			>=	terA.firstday	+42
				AND	psmsa.dateassignmentdue			<	terA.firstday	+49),0),',<BR />') WITHIN GROUP (ORDER BY psmsta.identifier)
	,	LISTAGG(
			NVL((SELECT
				COUNT (DISTINCT psmsa.id)
			FROM		PSM_SECTIONASSIGNMENT	psmsa
			INNER JOIN	PSM_ASSIGNMENTSTANDARD	psmas
				ON	psmas.SECTIONASSIGNMENTID		=	psmsa.ID
			WHERE	psmsa.SECTIONID					=	psms.ID
				AND	psmas.standardid				=	psmsta.ID
				AND	psmsa.dateassignmentdue			>=	terA.firstday	+49
				AND	psmsa.dateassignmentdue			<	terA.firstday	+56),0),',<BR />') WITHIN GROUP (ORDER BY psmsta.identifier)
	,	LISTAGG(
			NVL((SELECT
				COUNT (DISTINCT psmsa.id)
			FROM		PSM_SECTIONASSIGNMENT	psmsa
			INNER JOIN	PSM_ASSIGNMENTSTANDARD	psmas
				ON	psmas.SECTIONASSIGNMENTID		=	psmsa.ID
			WHERE	psmsa.SECTIONID					=	psms.ID
				AND	psmas.standardid				=	psmsta.ID
				AND	psmsa.dateassignmentdue			>=	terA.firstday	+56
				AND	psmsa.dateassignmentdue			<	terA.firstday	+63),0),',<BR />') WITHIN GROUP (ORDER BY psmsta.identifier)
	,	LISTAGG(
			NVL((SELECT
				COUNT (DISTINCT psmsa.id)
			FROM		PSM_SECTIONASSIGNMENT	psmsa
			INNER JOIN	PSM_ASSIGNMENTSTANDARD	psmas
				ON	psmas.SECTIONASSIGNMENTID		=	psmsa.ID
			WHERE	psmsa.SECTIONID					=	psms.ID
				AND	psmas.standardid				=	psmsta.ID
				AND	psmsa.dateassignmentdue			>=	terA.firstday	+63
				AND	psmsa.dateassignmentdue			<	terA.firstday	+70),0),',<BR />') WITHIN GROUP (ORDER BY psmsta.identifier)
	,	LISTAGG(
			NVL((SELECT
				COUNT (DISTINCT psmsa.id)
			FROM		PSM_SECTIONASSIGNMENT	psmsa
			INNER JOIN	PSM_ASSIGNMENTSTANDARD	psmas
				ON	psmas.SECTIONASSIGNMENTID		=	psmsa.ID
			WHERE	psmsa.SECTIONID					=	psms.ID
				AND	psmas.standardid				=	psmsta.ID
				AND	psmsa.dateassignmentdue			>=	terA.firstday	+70
				AND	psmsa.dateassignmentdue			<	terA.firstday	+77),0),',<BR />') WITHIN GROUP (ORDER BY psmsta.identifier)
	,	LISTAGG(
			NVL((SELECT
				COUNT (DISTINCT psmsa.id)
			FROM		PSM_SECTIONASSIGNMENT	psmsa
			INNER JOIN	PSM_ASSIGNMENTSTANDARD	psmas
				ON	psmas.SECTIONASSIGNMENTID		=	psmsa.ID
			WHERE	psmsa.SECTIONID					=	psms.ID
				AND	psmas.standardid				=	psmsta.ID
				AND	psmsa.dateassignmentdue			>=	terA.firstday	+77
				AND	psmsa.dateassignmentdue			<	terA.firstday	+84),0),',<BR />') WITHIN GROUP (ORDER BY psmsta.identifier)
	,	LISTAGG(
			NVL((SELECT
				COUNT (DISTINCT psmsa.id)
			FROM		PSM_SECTIONASSIGNMENT	psmsa
			INNER JOIN	PSM_ASSIGNMENTSTANDARD	psmas
				ON	psmas.SECTIONASSIGNMENTID		=	psmsa.ID
			WHERE	psmsa.SECTIONID					=	psms.ID
				AND	psmas.standardid				=	psmsta.ID
				AND	psmsa.dateassignmentdue			>=	terA.firstday	+84
				AND	psmsa.dateassignmentdue			<	terA.firstday	+91),0),',<BR />') WITHIN GROUP (ORDER BY psmsta.identifier)
	,	LISTAGG(
			NVL((SELECT
				COUNT (DISTINCT psmsa.id)
			FROM		PSM_SECTIONASSIGNMENT	psmsa
			INNER JOIN	PSM_ASSIGNMENTSTANDARD	psmas
				ON	psmas.SECTIONASSIGNMENTID		=	psmsa.ID
			WHERE	psmsa.SECTIONID					=	psms.ID
				AND	psmas.standardid				=	psmsta.ID
				AND	psmsa.dateassignmentdue			>=	terA.firstday	+91
				AND	psmsa.dateassignmentdue			<	terA.firstday	+98),0),',<BR />') WITHIN GROUP (ORDER BY psmsta.identifier)
	,	LISTAGG(
			NVL((SELECT
				COUNT (DISTINCT psmsa.id)
			FROM		PSM_SECTIONASSIGNMENT	psmsa
			INNER JOIN	PSM_ASSIGNMENTSTANDARD	psmas
				ON	psmas.SECTIONASSIGNMENTID		=	psmsa.ID
			WHERE	psmsa.SECTIONID					=	psms.ID
				AND	psmas.standardid				=	psmsta.ID
				AND	psmsa.dateassignmentdue			>=	terA.firstday	+98
				AND	psmsa.dateassignmentdue			<	terA.firstday	+105),0),',<BR />') WITHIN GROUP (ORDER BY psmsta.identifier)
	,	LISTAGG(
			NVL((SELECT
				COUNT (DISTINCT psmsa.id)
			FROM		PSM_SECTIONASSIGNMENT	psmsa
			INNER JOIN	PSM_ASSIGNMENTSTANDARD	psmas
				ON	psmas.SECTIONASSIGNMENTID		=	psmsa.ID
			WHERE	psmsa.SECTIONID					=	psms.ID
				AND	psmas.standardid				=	psmsta.ID
				AND	psmsa.dateassignmentdue			>=	terA.firstday	+105
				AND	psmsa.dateassignmentdue			<	terA.firstday	+112),0),',<BR />') WITHIN GROUP (ORDER BY psmsta.identifier)
	,	LISTAGG(
			NVL((SELECT
				COUNT (DISTINCT psmsa.id)
			FROM		PSM_SECTIONASSIGNMENT	psmsa
			INNER JOIN	PSM_ASSIGNMENTSTANDARD	psmas
				ON	psmas.SECTIONASSIGNMENTID		=	psmsa.ID
			WHERE	psmsa.SECTIONID					=	psms.ID
				AND	psmas.standardid				=	psmsta.ID
				AND	psmsa.dateassignmentdue			>=	terA.firstday	+112
				AND	psmsa.dateassignmentdue			<	terA.firstday	+119),0),',<BR />') WITHIN GROUP (ORDER BY psmsta.identifier)
	,	LISTAGG(
			NVL((SELECT
				COUNT (DISTINCT psmsa.id)
			FROM		PSM_SECTIONASSIGNMENT	psmsa
			INNER JOIN	PSM_ASSIGNMENTSTANDARD	psmas
				ON	psmas.SECTIONASSIGNMENTID		=	psmsa.ID
			WHERE	psmsa.SECTIONID					=	psms.ID
				AND	psmas.standardid				=	psmsta.ID
				AND	psmsa.dateassignmentdue			>=	terA.firstday	+119
				AND	psmsa.dateassignmentdue			<	terA.firstday	+126),0),',<BR />') WITHIN GROUP (ORDER BY psmsta.identifier)
	,	LISTAGG(
			NVL((SELECT
				COUNT (DISTINCT psmsa.id)
			FROM		PSM_SECTIONASSIGNMENT	psmsa
			INNER JOIN	PSM_ASSIGNMENTSTANDARD	psmas
				ON	psmas.SECTIONASSIGNMENTID		=	psmsa.ID
			WHERE	psmsa.SECTIONID					=	psms.ID
				AND	psmas.standardid				=	psmsta.ID
				AND	psmsa.dateassignmentdue			>=	terA.firstday	+126
				AND	psmsa.dateassignmentdue			<	terA.firstday	+133),0),',<BR />') WITHIN GROUP (ORDER BY psmsta.identifier)
	,	LISTAGG(
			NVL((SELECT
				COUNT (DISTINCT psmsa.id)
			FROM		PSM_SECTIONASSIGNMENT	psmsa
			INNER JOIN	PSM_ASSIGNMENTSTANDARD	psmas
				ON	psmas.SECTIONASSIGNMENTID		=	psmsa.ID
			WHERE	psmsa.SECTIONID					=	psms.ID
				AND	psmas.standardid				=	psmsta.ID
				AND	psmsa.dateassignmentdue			>=	terA.firstday	+133
				AND	psmsa.dateassignmentdue			<	terA.firstday	+140),0),',<BR />') WITHIN GROUP (ORDER BY psmsta.identifier)
	,	LISTAGG(
			(SELECT
				NVL(TO_CHAR(MIN(psmsa.DateAssignmentDue),'MM/DD/YYYY'),'NULL')
			FROM		PSM_SECTIONASSIGNMENT	psmsa
			INNER JOIN	PSM_ASSIGNMENTSTANDARD	psmas
				ON	psmas.SECTIONASSIGNMENTID		=	psmsa.ID
			WHERE	psmsa.SECTIONID					=	psms.ID
				AND	psmas.standardid				=	psmsta.ID),',<BR />') WITHIN GROUP (ORDER BY psmsta.identifier)
	,	LISTAGG(
			(SELECT
				NVL(TO_CHAR(MAX(psmsa.DateAssignmentDue),'MM/DD/YYYY'),'NULL')
			FROM		PSM_SECTIONASSIGNMENT	psmsa
			INNER JOIN	PSM_ASSIGNMENTSTANDARD	psmas
				ON	psmas.SECTIONASSIGNMENTID		=	psmsa.ID
			WHERE	psmsa.SECTIONID					=	psms.ID
				AND	psmas.standardid				=	psmsta.ID),',<BR />') WITHIN GROUP (ORDER BY psmsta.identifier)


FROM 		schools		sch
INNER JOIN	sections	sect
	ON			sect.schoolid			=	sch.school_number
INNER JOIN	teachers				t
	ON			t.id								=	sect.teacher
INNER JOIN	courses					c
	ON			c.course_number			=	sect.course_number
INNER JOIN	gradescaleitem			gs
	ON			gs.id					=	(CASE WHEN sect.gradescaleid = 0 THEN c.gradescaleid ELSE sect.gradescaleid END)

INNER JOIN	terms		terA
	ON			terA.id					=	sect.termid
	AND			terA.schoolid			=	sect.schoolid
INNER JOIN	terms		terB
	ON			terB.yearid				=	terA.yearid
	AND			terB.schoolid			=	terA.schoolid
	AND			terB.firstday			<=	terA.firstday
	AND			terB.lastday			>=	terA.lastday

INNER JOIN	SYNC_SectionMap			ssm
	ON			ssm.sectionsdcid		=	sect.dcid

INNER JOIN	PSM_SECTION				psms
	ON			psms.id							=	ssm.sectionid

INNER JOIN	PSM_SECTIONTEACHER		psmst
	ON 			psmst.SECTIONID					=	psms.ID
INNER JOIN	PSM_TEACHER				psmt
	ON 			psmt.ID							=	psmst.TEACHERID

INNER JOIN	PSM_SCHOOLCOURSE			psmsc
	ON			psmsc.ID						=	psms.SCHOOLCOURSEID
INNER JOIN	PSM_COURSE				psmc
	ON			psmc.ID							=	psmsc.COURSEID
INNER JOIN	PSM_COURSESTANDARD		psmcs
	ON			psmcs.COURSEID 					=	psmc.ID
INNER JOIN	PSM_STANDARD				psmsta
	ON			psmsta.ID						=	psmcs.STANDARDID

WHERE		sch.school_number		IN	(%param1%)
	AND			terB.abbreviation	=	'%param2%'
	AND			terB.yearid			=	%param3%

GROUP BY
	sect.dcid
	,	sch.abbreviation
	,	t.lastfirst
	,	terA.abbreviation
	,	c.course_name
	,	sect.id
	,	sect.section_number
	,	sect.expression
	,	gs.name