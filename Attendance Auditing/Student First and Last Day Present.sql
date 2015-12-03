WITH	student_list_source
		(studentid
		,	grade_level
		,	schoolid
		,	entrydate
		,	exitdate
		,	source_number
		,	dcid)
AS	(
	SELECT
		ID				AS	studentid
		,	grade_level	AS	grade_level
		,	enrollment_SchoolID	AS	schoolid
		,	EntryDate	AS	entrydate
		,	ExitDate	AS	exitdate
		,	1			AS	source_number
		,	dcid		AS	dcid
	FROM	Students
	WHERE	Grade_Level		>=	%param3%
		AND	grade_level		<=	%param4%
		AND	schoolid		IN	(%param5%)
		AND	entrydate		<=	'%param2%'
		AND	exitdate		>	'%param1%'
	UNION
	
	SELECT
		StudentID		AS	studentid
		,	grade_level	AS	grade_level
		,	SchoolID	AS	schoolid
		,	EntryDate	AS	entrydate
		,	ExitDate	AS	exitdate
		,	2			AS	source_number
		,	dcid		AS	dcid
	FROM	ReEnrollments
	WHERE	Grade_Level		>=	%param3%
		AND	grade_level		<=	%param4%
		AND	schoolid		IN	(%param5%)
		AND	entrydate		<=	'%param2%'
		AND	exitdate		>	'%param1%'
),
ca_d AS	(
	SELECT
		row_number() OVER (PARTITION BY ca_d1.schoolid ORDER BY ca_d1.date_value) AS rn
		,	ca_d1.schoolid
		,	ca_d1.date_value
	FROM calendar_day	ca_d1
	WHERE	ca_d1.insession				=	1
		AND	ca_d1.schoolid				IN	(%param5%)
		AND	ca_d1.date_value	>=	'%param1%'
		AND	ca_d1.date_value	<=	'%param2%'
	ORDER BY
		ca_d1.schoolid
		,	ca_d1.date_value asc
)

SELECT
	s.dcid
	,	sls.schoolid
	,	sch.abbreviation
	,	CASE
			WHEN (SELECT COUNT (DISTINCT re.dcid) FROM reenrollments re WHERE re.studentid = sls.studentid AND re.schoolid = sls.schoolid AND re.entrydate <= '6/12/2015' AND re.exitdate > '6/12/2015') > 0
			THEN	'Returning'
			ELSE	'New'
			END
	,	sls.studentid
	,	'<a href=/admin/students/home.html?frn=001'||to_char(s.dcid)||' target=_blank>'||s.student_number||'</a>'
	,	'<a href=/admin/students/home.html?frn=001'||to_char(s.dcid)||' target=_blank>'||s.lastfirst||'</a>'
	,	sls.grade_level
	,	TO_CHAR(TO_DATE(sls.entrydate),'MM/DD/YYYY')
	,	TO_CHAR(TO_DATE(sls.exitdate),'MM/DD/YYYY')
	,	TO_CHAR(TO_DATE(MIN(cc.dateenrolled)),'MM/DD/YYYY')
	,	TO_CHAR(TO_DATE(MAX(cc.dateleft)),'MM/DD/YYYY')
	,	MIN(ca_d4.rn) - ca_d1.rn
	,	(CASE WHEN ca_d2.rn IS NULL THEN ca_d2b.rn ELSE ca_d2.rn - 1 END) - GREATEST(MAX(NVL(ca_d5.rn,0)-1),MAX(NVL(ca_d5b.rn,0)),MAX(NVL(ca_d5c.rn,0)),MAX(NVL(ca_d5d.rn,0)),MAX(NVL(ca_d5e.rn,0)))
	,	TO_CHAR(TO_DATE(MIN(CASE WHEN ac.Presence_Status_CD		=	'Present' THEN att.att_date ELSE NULL END)),'MM/DD/YYYY')
	,	TO_CHAR(TO_DATE(MAX(CASE WHEN ac.Presence_Status_CD		=	'Present' THEN att.att_date ELSE NULL END)),'MM/DD/YYYY')
	,	MIN(ca_d3.rn) - ca_d1.rn
	,	(CASE WHEN ca_d2.rn IS NULL THEN ca_d2b.rn ELSE ca_d2.rn - 1 END)
			- MAX(ca_d3.rn)
	,	(CASE WHEN
			COUNT	(DISTINCT ccb.dcid)	> 0			THEN	'There are '|| COUNT(DISTINCT ccb.dcid) ||'mismatched CC schoolid records.'
			ELSE	NULL
			END)
	,	(CASE
			WHEN	sls.source_min	=	1	THEN	'<a href=/admin/students/edittransfer1.html?frn=001'||to_char(sls.dcid)||' target=_blank>'||'Transfer Info (S)'||'</a>'
			WHEN	sls.source_min	=	2	THEN	'<a href=/admin/students/edittransfer2.html?frn=018'||to_char(sls.dcid)||' target=_blank>'||'Transfer Info (R)'||'</a>'
			ELSE	'<a href=/admin/students/transferinfo.html?frn=001'||to_char(s.dcid)||' target=_blank>'||'Transfer Info (U)'||'</a>'	
			END)	AS	links

FROM	(			/***	Initial Query for Distinct Relevant Student LIST For Each Active Date		***/
	SELECT
		ca_d.date_value
		,	ca_d.schoolid
		,	sls.dcid
		,	sls.studentid
		,	sls.grade_level
		,	sls.entrydate
		,	sls.exitdate
		,	MIN(sls.source_number)	AS	source_min
		,	(CASE
				WHEN	MIN(sls.source_number)	=	1		THEN	'Current'
				WHEN	MIN(sls.source_number)	=	2		THEN	'ReEnrollments'
				ELSE												'Unknown'
				END)	AS	source
	FROM		calendar_day		ca_d
	LEFT JOIN	student_list_source	sls
		ON			sls.entrydate	<=	ca_d.date_value
		AND			sls.exitdate	>	ca_d.date_value
		AND			sls.schoolid	=	ca_d.schoolid
	WHERE	ca_d.date_value	>=	'%param1%'
		AND	ca_d.date_value	<=	'%param2%'
		AND	ca_d.insession	=	1
		AND	ca_d.schoolid	IN	(%param5%)
	GROUP BY
		ca_d.date_value
		,	ca_d.schoolid
		,	sls.dcid
		,	sls.studentid
		,	sls.grade_level
		,	sls.entrydate
		,	sls.exitdate
) sls

INNER JOIN	Students				s
	ON			s.id						=	sls.studentid
INNER JOIN	Schools					sch
	ON			sch.School_Number			=	sls.schoolid
LEFT JOIN	attendance				att
	ON			att.studentid				=	sls.studentid
	AND			att.att_date				=	sls.date_value
LEFT JOIN	attendance_code			ac
	ON			ac.id						=	att.attendance_codeid
	AND			ac.Presence_Status_CD		=	'Present'
	AND			ac.calculate_ada_yn			=	1
LEFT JOIN	cc
	on			cc.studentid				=	sls.studentid
	AND			cc.schoolid					=	sls.schoolid	
	AND			cc.dateenrolled				<	sls.exitdate
	AND			cc.dateleft					>	sls.entrydate
LEFT JOIN	cc						ccb
	on			ccb.studentid				=	sls.studentid
	AND			ccb.schoolid					!=	sls.schoolid	
	AND			ccb.dateenrolled				<	sls.exitdate
	AND			ccb.dateleft					>	sls.entrydate
LEFT JOIN	ca_d					ca_d1
	ON			ca_d1.date_value		=	sls.entrydate
	AND			ca_d1.schoolid			=	sls.schoolid

LEFT JOIN	ca_d					ca_d2
	ON			ca_d2.date_value		=	sls.exitdate
	AND			ca_d2.schoolid			=	sls.schoolid

LEFT JOIN	ca_d					ca_d2b
	ON			ca_d2b.date_value		=	sls.exitdate - 1
	AND			ca_d2b.schoolid			=	sls.schoolid

LEFT JOIN	ca_d					ca_d3
	ON			ca_d3.date_value		=	att.att_date
	AND			ca_d3.schoolid			=	sls.schoolid
	AND			ac.Presence_Status_CD		=	'Present'

LEFT JOIN	ca_d					ca_d4
	ON			ca_d4.date_value		=	cc.dateenrolled
	AND			ca_d4.schoolid			=	cc.schoolid

LEFT JOIN	ca_d					ca_d5
	ON			ca_d5.date_value		=	cc.dateleft 
	AND			ca_d5.schoolid			=	cc.schoolid

LEFT JOIN	ca_d					ca_d5b
	ON			ca_d5b.date_value		=	cc.dateleft - 1
	AND			ca_d5b.schoolid			=	cc.schoolid

LEFT JOIN	ca_d					ca_d5c
	ON			ca_d5c.date_value		=	cc.dateleft - 2
	AND			ca_d5c.schoolid			=	cc.schoolid

LEFT JOIN	ca_d					ca_d5d
	ON			ca_d5d.date_value		=	cc.dateleft - 3
	AND			ca_d5d.schoolid			=	cc.schoolid

LEFT JOIN	ca_d					ca_d5e
	ON			ca_d5e.date_value		=	cc.dateleft - 4
	AND			ca_d5e.schoolid			=	cc.schoolid

where	ac.att_code		!=	'NCH'
	OR	ac.att_code		IS	NULL

GROUP BY
	sls.schoolid
	,	sch.abbreviation
	,	sls.source
	,	sls.studentid
	,	s.dcid
	,	s.student_number
	,	s.lastfirst
	,	sls.grade_level
	,	sls.entrydate
	,	sls.exitdate
	,	sls.dcid
	,	sls.source_min
	,	ca_d1.rn
	,	ca_d2.rn
	,	ca_d2b.rn