SELECT
	CASE WHEN GROUPING(sch.name) = 1 THEN 'All High Schools' ELSE sch.name END
	,	CASE WHEN GROUPING(sg.credit_type) = 1 THEN 'All Credit Types' ELSE sg.credit_type END
	,	terb.storecode
	,	COUNT (DISTINCT CASE WHEN sg.grade IN ('A+','A','A-','B+','B','B-','C+','C','C-','D+','D','D-','F','CR','NC','4','3','2','1','0') THEN sg.dcid ELSE NULL END)
	,	CAST ( CAST ( 100 * COUNT (DISTINCT CASE WHEN sg.grade IN ('A+','A','A-') THEN sg.dcid ELSE NULL END)	/	COUNT (DISTINCT CASE WHEN sg.grade IN ('A+','A','A-','B+','B','B-','C+','C','C-','D+','D','D-','F','CR','NC','4','3','2','1','0') THEN sg.dcid ELSE NULL END) AS DECIMAL (5,1)) AS VARCHAR2(6))||'%'
	,	CAST ( CAST ( 100 * COUNT (DISTINCT CASE WHEN sg.grade IN ('B+','B','B-') THEN sg.dcid ELSE NULL END)	/	COUNT (DISTINCT CASE WHEN sg.grade IN ('A+','A','A-','B+','B','B-','C+','C','C-','D+','D','D-','F','CR','NC','4','3','2','1','0') THEN sg.dcid ELSE NULL END) AS DECIMAL (5,1)) AS VARCHAR2(6))||'%'
	,	CAST ( CAST ( 100 * COUNT (DISTINCT CASE WHEN sg.grade IN ('C+','C','C-') THEN sg.dcid ELSE NULL END)	/	COUNT (DISTINCT CASE WHEN sg.grade IN ('A+','A','A-','B+','B','B-','C+','C','C-','D+','D','D-','F','CR','NC','4','3','2','1','0') THEN sg.dcid ELSE NULL END) AS DECIMAL (5,1)) AS VARCHAR2(6))||'%'
	,	CAST ( CAST ( 100 * COUNT (DISTINCT CASE WHEN sg.grade IN ('D+','D','D-') THEN sg.dcid ELSE NULL END)	/	COUNT (DISTINCT CASE WHEN sg.grade IN ('A+','A','A-','B+','B','B-','C+','C','C-','D+','D','D-','F','CR','NC','4','3','2','1','0') THEN sg.dcid ELSE NULL END) AS DECIMAL (5,1)) AS VARCHAR2(6))||'%'
	,	CAST ( CAST ( 100 * COUNT (DISTINCT CASE WHEN sg.grade = 'F' THEN sg.dcid ELSE NULL END)	/	COUNT (DISTINCT CASE WHEN sg.grade IN ('A+','A','A-','B+','B','B-','C+','C','C-','D+','D','D-','F','CR','NC','4','3','2','1','0') THEN sg.dcid ELSE NULL END) AS DECIMAL (5,1)) AS VARCHAR2(6))||'%'
	,	CAST ( CAST ( 100 * COUNT (DISTINCT CASE WHEN sg.grade = 'A+' THEN sg.dcid ELSE NULL END)	/	COUNT (DISTINCT CASE WHEN sg.grade IN ('A+','A','A-','B+','B','B-','C+','C','C-','D+','D','D-','F','CR','NC','4','3','2','1','0') THEN sg.dcid ELSE NULL END) AS DECIMAL (5,1)) AS VARCHAR2(6))||'%'
	,	CAST ( CAST ( 100 * COUNT (DISTINCT CASE WHEN sg.grade = 'A' THEN sg.dcid ELSE NULL END)	/	COUNT (DISTINCT CASE WHEN sg.grade IN ('A+','A','A-','B+','B','B-','C+','C','C-','D+','D','D-','F','CR','NC','4','3','2','1','0') THEN sg.dcid ELSE NULL END) AS DECIMAL (5,1)) AS VARCHAR2(6))||'%'
	,	CAST ( CAST ( 100 * COUNT (DISTINCT CASE WHEN sg.grade = 'A-' THEN sg.dcid ELSE NULL END)	/	COUNT (DISTINCT CASE WHEN sg.grade IN ('A+','A','A-','B+','B','B-','C+','C','C-','D+','D','D-','F','CR','NC','4','3','2','1','0') THEN sg.dcid ELSE NULL END) AS DECIMAL (5,1)) AS VARCHAR2(6))||'%'
	,	CAST ( CAST ( 100 * COUNT (DISTINCT CASE WHEN sg.grade = 'B+' THEN sg.dcid ELSE NULL END)	/	COUNT (DISTINCT CASE WHEN sg.grade IN ('A+','A','A-','B+','B','B-','C+','C','C-','D+','D','D-','F','CR','NC','4','3','2','1','0') THEN sg.dcid ELSE NULL END) AS DECIMAL (5,1)) AS VARCHAR2(6))||'%'
	,	CAST ( CAST ( 100 * COUNT (DISTINCT CASE WHEN sg.grade = 'B' THEN sg.dcid ELSE NULL END)	/	COUNT (DISTINCT CASE WHEN sg.grade IN ('A+','A','A-','B+','B','B-','C+','C','C-','D+','D','D-','F','CR','NC','4','3','2','1','0') THEN sg.dcid ELSE NULL END) AS DECIMAL (5,1)) AS VARCHAR2(6))||'%'
	,	CAST ( CAST ( 100 * COUNT (DISTINCT CASE WHEN sg.grade = 'B-' THEN sg.dcid ELSE NULL END)	/	COUNT (DISTINCT CASE WHEN sg.grade IN ('A+','A','A-','B+','B','B-','C+','C','C-','D+','D','D-','F','CR','NC','4','3','2','1','0') THEN sg.dcid ELSE NULL END) AS DECIMAL (5,1)) AS VARCHAR2(6))||'%'
	,	CAST ( CAST ( 100 * COUNT (DISTINCT CASE WHEN sg.grade = 'C+' THEN sg.dcid ELSE NULL END)	/	COUNT (DISTINCT CASE WHEN sg.grade IN ('A+','A','A-','B+','B','B-','C+','C','C-','D+','D','D-','F','CR','NC','4','3','2','1','0') THEN sg.dcid ELSE NULL END) AS DECIMAL (5,1)) AS VARCHAR2(6))||'%'
	,	CAST ( CAST ( 100 * COUNT (DISTINCT CASE WHEN sg.grade = 'C' THEN sg.dcid ELSE NULL END)	/	COUNT (DISTINCT CASE WHEN sg.grade IN ('A+','A','A-','B+','B','B-','C+','C','C-','D+','D','D-','F','CR','NC','4','3','2','1','0') THEN sg.dcid ELSE NULL END) AS DECIMAL (5,1)) AS VARCHAR2(6))||'%'
	,	CAST ( CAST ( 100 * COUNT (DISTINCT CASE WHEN sg.grade = 'C-' THEN sg.dcid ELSE NULL END)	/	COUNT (DISTINCT CASE WHEN sg.grade IN ('A+','A','A-','B+','B','B-','C+','C','C-','D+','D','D-','F','CR','NC','4','3','2','1','0') THEN sg.dcid ELSE NULL END) AS DECIMAL (5,1)) AS VARCHAR2(6))||'%'
	,	CAST ( CAST ( 100 * COUNT (DISTINCT CASE WHEN sg.grade = 'D+' THEN sg.dcid ELSE NULL END)	/	COUNT (DISTINCT CASE WHEN sg.grade IN ('A+','A','A-','B+','B','B-','C+','C','C-','D+','D','D-','F','CR','NC','4','3','2','1','0') THEN sg.dcid ELSE NULL END) AS DECIMAL (5,1)) AS VARCHAR2(6))||'%'
	,	CAST ( CAST ( 100 * COUNT (DISTINCT CASE WHEN sg.grade = 'D' THEN sg.dcid ELSE NULL END)	/	COUNT (DISTINCT CASE WHEN sg.grade IN ('A+','A','A-','B+','B','B-','C+','C','C-','D+','D','D-','F','CR','NC','4','3','2','1','0') THEN sg.dcid ELSE NULL END) AS DECIMAL (5,1)) AS VARCHAR2(6))||'%'
	,	CAST ( CAST ( 100 * COUNT (DISTINCT CASE WHEN sg.grade = 'D-' THEN sg.dcid ELSE NULL END)	/	COUNT (DISTINCT CASE WHEN sg.grade IN ('A+','A','A-','B+','B','B-','C+','C','C-','D+','D','D-','F','CR','NC','4','3','2','1','0') THEN sg.dcid ELSE NULL END) AS DECIMAL (5,1)) AS VARCHAR2(6))||'%'
	,	CAST ( CAST ( 100 * COUNT (DISTINCT CASE WHEN sg.grade = 'CR' THEN sg.dcid ELSE NULL END)	/	COUNT (DISTINCT CASE WHEN sg.grade IN ('A+','A','A-','B+','B','B-','C+','C','C-','D+','D','D-','F','CR','NC','4','3','2','1','0') THEN sg.dcid ELSE NULL END) AS DECIMAL (5,1)) AS VARCHAR2(6))||'%'
	,	CAST ( CAST ( 100 * COUNT (DISTINCT CASE WHEN sg.grade = 'NC' THEN sg.dcid ELSE NULL END)	/	COUNT (DISTINCT CASE WHEN sg.grade IN ('A+','A','A-','B+','B','B-','C+','C','C-','D+','D','D-','F','CR','NC','4','3','2','1','0') THEN sg.dcid ELSE NULL END) AS DECIMAL (5,1)) AS VARCHAR2(6))||'%'
	,	CAST ( CAST ( 100 * COUNT (DISTINCT CASE WHEN sg.grade = '4' THEN sg.dcid ELSE NULL END)	/	COUNT (DISTINCT CASE WHEN sg.grade IN ('A+','A','A-','B+','B','B-','C+','C','C-','D+','D','D-','F','CR','NC','4','3','2','1','0') THEN sg.dcid ELSE NULL END) AS DECIMAL (5,1)) AS VARCHAR2(6))||'%'
	,	CAST ( CAST ( 100 * COUNT (DISTINCT CASE WHEN sg.grade = '3' THEN sg.dcid ELSE NULL END)	/	COUNT (DISTINCT CASE WHEN sg.grade IN ('A+','A','A-','B+','B','B-','C+','C','C-','D+','D','D-','F','CR','NC','4','3','2','1','0') THEN sg.dcid ELSE NULL END) AS DECIMAL (5,1)) AS VARCHAR2(6))||'%'
	,	CAST ( CAST ( 100 * COUNT (DISTINCT CASE WHEN sg.grade = '2' THEN sg.dcid ELSE NULL END)	/	COUNT (DISTINCT CASE WHEN sg.grade IN ('A+','A','A-','B+','B','B-','C+','C','C-','D+','D','D-','F','CR','NC','4','3','2','1','0') THEN sg.dcid ELSE NULL END) AS DECIMAL (5,1)) AS VARCHAR2(6))||'%'
	,	CAST ( CAST ( 100 * COUNT (DISTINCT CASE WHEN sg.grade = '1' THEN sg.dcid ELSE NULL END)	/	COUNT (DISTINCT CASE WHEN sg.grade IN ('A+','A','A-','B+','B','B-','C+','C','C-','D+','D','D-','F','CR','NC','4','3','2','1','0') THEN sg.dcid ELSE NULL END) AS DECIMAL (5,1)) AS VARCHAR2(6))||'%'
	,	CAST ( CAST ( 100 * COUNT (DISTINCT CASE WHEN sg.grade = '0' THEN sg.dcid ELSE NULL END)	/	COUNT (DISTINCT CASE WHEN sg.grade IN ('A+','A','A-','B+','B','B-','C+','C','C-','D+','D','D-','F','CR','NC','4','3','2','1','0') THEN sg.dcid ELSE NULL END) AS DECIMAL (5,1)) AS VARCHAR2(6))||'%'
	,	CAST ( CAST ( 100 * COUNT (DISTINCT CASE WHEN sg.grade NOT IN ('A+','A','A-','B+','B','B-','C+','C','C-','D+','D','D-','F','CR','NC','4','3','2','1','0') THEN sg.dcid ELSE NULL END)	/	COUNT (DISTINCT CASE WHEN sg.grade IN ('A+','A','A-','B+','B','B-','C+','C','C-','D+','D','D-','F','CR','NC','4','3','2','1','0') THEN sg.dcid ELSE NULL END) AS DECIMAL (5,1)) AS VARCHAR2(6))||'%'
	
FROM		PS_ENROLLMENT_REG		PSER
INNER JOIN	students				s
	ON			s.id			=	PSER.studentid
INNER JOIN	schools			sch
	ON			sch.school_number	=	PSER.schoolid
INNER JOIN	cc
	ON			cc.studentid	=	PSER.studentid
	AND			cc.schoolid		=	PSER.schoolid
	AND			cc.dateenrolled	<	PSER.exitdate
	AND			cc.dateleft		>	PSER.entrydate
	AND			cc.dateenrolled	<=	'%param2%'
	AND			cc.dateleft		>	'%param2%'
INNER JOIN	sections		sect
	ON			sect.id			=	ABS(cc.sectionid)
INNER JOIN	courses			c
	ON			c.course_number	=	sect.course_number
INNER JOIN	teachers		tea
	ON			tea.id			=	sect.teacher
INNER JOIN	terms			ter
	ON			ter.id			=	sect.termid
	and			ter.schoolid	=	sect.schoolid
INNER JOIN	termbins		terb
	ON			terb.termid		=	ter.id
	AND			terb.schoolid	=	ter.schoolid
	AND			terb.storecode	=	'%param1%'
LEFT JOIN	storedgrades	sg
	ON			sg.studentid		=	cc.studentid
	AND			sg.sectionid		=	sect.id
	AND			sg.storecode		=	terb.storecode

~[if.is.a.school]
	WHERE	PSER.schoolid		= ~(curschoolid)
[/if]
	
GROUP BY
	terb.storecode
	,	ROLLUP(sch.name)
	,	ROLLUP(sg.credit_type)