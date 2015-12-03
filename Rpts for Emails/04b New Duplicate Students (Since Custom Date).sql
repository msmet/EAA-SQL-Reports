WITH stuQuery AS
	(SELECT
		s.dcid
		,	s.id
		,	s.last_name
		,	s.first_name
		,	s.middle_name
		,	s.dob
		,	s.schoolid
		,	s.student_number
		,	s.enroll_status
		,	s.entrydate
		,	s.exitdate
		,	s.exitcode
		,	s.enrollment_schoolid
		,	ps_customfields.getcf('Students',s.id,'MI_SRSD_StudentUIC') AS	cfuic
		,	sb.studentuic	AS	extuic

	FROM		students			s
	LEFT JOIN	U_DEF_EXT_STUDENTS	sb
			ON		sb.studentsdcid				=	s.dcid
			AND		sb.StudentUIC				IS	NOT NULL)

SELECT
	s.dcid
	,	DENSE_RANK() OVER (ORDER BY MIN(LEAST(s.dcid, sQB.dcid)) ASC)
	,	'<a href=/admin/students/home.html?frn=001'||to_char(s.dcid)||' target=_blank>Student Link</a><BR />'||
		'<a href=/admin/reportqueue/home.html?DOTHISFOR='||s.id||'&amp;amp;reportname=Updated+Official+District+Transcript&amp;amp;useeao=no&amp;amp;eao='||TO_CHAR(SYSDATE,'MM/DD/YYYY')||'&amp;amp;transactiondate=year&amp;amp;transactionstartdate=&amp;amp;transactionenddate=&amp;amp;watermark=&amp;amp;watermarkcustom=&amp;amp;overlay=true&amp;amp;printwhen=2&amp;amp;printdate=&amp;amp;printtime=&amp;amp;report_request_locale=en_US&amp;amp;ac=printformletter&amp;amp;btnSubmit= target=_blank>Transcript</a>'
	,	s.last_name
	,	s.first_name
	,	s.middle_name
	,	to_char(s.dob,'mm/dd/yyyy')
	,	s.schoolid
	,	sch.name
	,	s.student_number
	,	s.enroll_status
	,	s.ID
	,	s.cfuic||'<br />'||s.extuic
	,	to_char(s.entrydate,'mm/dd/yyyy')
	,	to_char(s.exitdate,'mm/dd/yyyy')
	,	s.exitcode
	,	s.enrollment_schoolid
	,	to_char(LEAST(NVL(MIN(re.entrydate),'1/1/2199'),s.entrydate),'mm/dd/yyyy')
	,	(SELECT LISTAGG('<b>'||re.schoolid||CHR(58)||'</b>'||to_char(re.entrydate,'mm/dd/yyyy')||'-'||to_char(re.exitdate,'mm/dd/yyyy')||',<br />',NULL) WITHIN GROUP (ORDER BY re.entrydate, re.exitdate) FROM reenrollments re WHERE re.studentid = s.id)||'<b>'||s.schoolid||CHR(58)||'</b>'||to_char(s.entrydate,'mm/dd/yyyy')||'-'||to_char(s.exitdate,'mm/dd/yyyy')
	,	COUNT(DISTINCT sQB.dcid) + 1
	,	CASE WHEN (SUM(CASE WHEN (re.exitdate > reb.entrydate AND re.entrydate < reb.exitdate) THEN 1 ELSE 0 END)
		+	SUM(CASE WHEN (re.exitdate > sQB.entrydate AND re.entrydate < sQB.exitdate) THEN 1 ELSE 0 END)
		+	SUM(CASE WHEN (s.exitdate > reb.entrydate AND s.entrydate < reb.exitdate) THEN 1 ELSE 0 END)
		+	SUM(CASE WHEN (s.exitdate > sQB.entrydate AND s.entrydate < sQB.exitdate) THEN 1 ELSE 0 END)) > 0 THEN 'Yes' ELSE 'No' END
	,	LISTAGG(CASE
			WHEN	(sQB.last_name				=	s.Last_Name
					AND		sQB.first_name				=	s.First_Name
					AND		sQB.dob						=	s.dob)
				THEN	'Name, DOB'
			WHEN	((sQB.cfuic					=	s.cfuic)
				OR		(sQB.extuic					=	s.extuic)
				OR		(sQB.cfuic					=	s.extuic)
				OR		(sQB.extuic					=	s.cfuic))
				THEN	'UIC'
			ELSE		'Unknown'
			END,'<br />') WITHIN GROUP (ORDER BY sQB.dcid)

FROM		stuQuery			s

INNER JOIN	stuQuery			sQB
		ON		sQB.dcid					<>	s.dcid
		AND		((sQB.last_name				=	s.Last_Name
			AND		sQB.first_name				=	s.First_Name
			AND		sQB.dob						=	s.dob)
		OR		(sQB.cfuic					=	s.cfuic)
		OR		(sQB.extuic					=	s.extuic)
		OR		(sQB.cfuic					=	s.extuic)
		OR		(sQB.extuic					=	s.cfuic))

~[if#cursel.%param1%=Yes]
	INNER JOIN		~[temp.table.current.selection:students]	stusel
			ON			stusel.dcid				=	s.dcid
			OR			stusel.dcid				=	sQB.dcid
[/if#cursel]

LEFT JOIN	reenrollments		re
		ON		re.studentid				=	s.id
LEFT JOIN	reenrollments		reb
		ON		reb.studentid				=	sQB.id
LEFT JOIN	schools				sch 
		ON		s.schoolid					=	sch.school_number

GROUP BY
	s.dcid
	,	s.last_name
	,	s.first_name
	,	s.middle_name
	,	s.dob
	,	s.schoolid
	,	sch.name
	,	s.student_number
	,	s.enroll_status
	,	s.ID
	,	s.cfuic
	,	s.extuic
	,	s.entrydate
	,	s.exitdate
	,	s.exitcode
	,	s.enrollment_schoolid
	
HAVING
	LEAST(NVL(MIN(re.entrydate),'1/1/2199'),s.entrydate) >= '%param2%'

ORDER BY
	MIN(LEAST(s.dcid, sQB.dcid)) ASC
	,	s.exitdate DESC