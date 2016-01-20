SELECT
	s.dcid
	,	'<a href=/admin/students/home.html?frn=001'||to_char(s.dcid)||' target=_blank>'||'<u>Student</u>'||'</a><br /><a href=/admin/students/section25e.html?frn=001'||to_char(s.dcid)||' target=_blank>'||'<u>Sec25e</u>'||'</a><br /><a href=/admin/reportqueue/home.html?DOTHISFOR='||s.id||'&reportname=Sample+-+Student+Schedules&useeao=yes&eao='||TO_CHAR(SMSGX.firstAttendDate,'MM/DD/YYYY')||'&transactiondate=year&transactionstartdate=&transactionenddate=&watermark=&watermarkcustom=&overlay=true&printwhen=2&printdate=&printtime=&report_request_locale=en_US&ac=printformletter&btnSubmit= target=_blank><u>Schedule</u></a>'
	,	s.last_name
	,	s.first_name
	,	CASE
			WHEN	s.state_studentnumber IS NULL	THEN	'<span style='||CHR(34)||'color'||CHR(58)||'red'||CHR(34)||'><b>Missing</b></span>'
			ELSE	TO_CHAR(s.state_studentnumber)
			END
	,	TO_CHAR(s.dob,'MM/DD/YYYY')
	,	LISTAGG(CASE WHEN PSER.entrydate > '10/7/2015' THEN sch.name ELSE NULL END,', ') WITHIN GROUP (ORDER BY PSER.entrydate)		-- SET DATE TO LAST SUBMISSION DATE
	,	MAX(pser.grade_level)
	,	TO_CHAR(MIN(CASE WHEN PSER.entrydate > '10/7/2015' THEN PSER.entrydate ELSE NULL END),'MM/DD/YYYY')			-- SET DATE TO LAST SUBMISSION DATE
	,	CASE	
			WHEN SMSGX.firstAttendDate IS NULL THEN	'<b><a href=/admin/attendance/view/meeting.html?frn=001'||to_char(s.dcid)||' target=_blank style='||CHR(34)||'color'||CHR(58)||'red'||CHR(34)||'>'||'<u>Missing</u>'||'</a></b>'
			ELSE	'<a href=/admin/attendance/record/week/meeting.html?frn=001'||to_char(s.dcid)||'&startdate='||TO_CHAR(CASE TO_CHAR(SMSGX.firstAttendDate, 'Dy')
			WHEN	'Mon' THEN SMSGX.firstAttendDate
			WHEN	'Tue' THEN SMSGX.firstAttendDate-1
			WHEN	'Wed' THEN SMSGX.firstAttendDate-2
			WHEN	'Thu' THEN SMSGX.firstAttendDate-3
			WHEN	'Fri' THEN SMSGX.firstAttendDate-4
			END,'MM/DD/YYYY')||'&ATT_RecordMode=ATT_ModeMeeting target=_blank><u>'||TO_CHAR(SMSGX.firstAttendDate,'MM/DD/YYYY')||'</u></a>'
			END
	,	CASE
			WHEN	UDES.SEC25EEXITEDLEANAME IS NULL	THEN	'<span style='||CHR(34)||'color'||CHR(58)||'red'||CHR(34)||'><b>Missing</b></span>'
			ELSE	TO_CHAR(UDES.SEC25EEXITEDLEANAME)
			END
	,	CASE
			WHEN	UDES.SEC25EEXITEDLEANUMBER IS NULL	THEN	'<span style='||CHR(34)||'color'||CHR(58)||'red'||CHR(34)||'><b>Missing</b></span>'
			ELSE	TO_CHAR(UDES.SEC25EEXITEDLEANUMBER)
			END
	,	CASE
			WHEN	UDES.SEC25EEXITEDSCHOOL IS NULL	THEN	'<span style='||CHR(34)||'color'||CHR(58)||'red'||CHR(34)||'><b>Missing</b></span>'
			ELSE	TO_CHAR(UDES.SEC25EEXITEDSCHOOL)
			END
	,	CASE
			WHEN	UDES.SEC25EFALLLEANAME IS NULL	THEN	'<span style='||CHR(34)||'color'||CHR(58)||'red'||CHR(34)||'><b>Missing</b></span>'
			ELSE	TO_CHAR(UDES.SEC25EFALLLEANAME)
			END
	,	CASE
			WHEN	UDES.SEC25EFALLLEANUMBER IS NULL	THEN	'<span style='||CHR(34)||'color'||CHR(58)||'red'||CHR(34)||'><b>Missing</b></span>'
			ELSE	TO_CHAR(UDES.SEC25EFALLLEANUMBER)
			END
	,	CASE
			WHEN	UDES.Sec25eFTE IS NULL	THEN	'<span style='||CHR(34)||'color'||CHR(58)||'red'||CHR(34)||'><b>Missing</b></span>'
			ELSE	TO_CHAR(UDES.Sec25eFTE)
			END
	,	CASE UDES.SEC25EINELIGIBLE
			WHEN 0 THEN 'Eligible'
			WHEN 1 THEN 'Ineligible'
			ELSE 'Unknown'
			END
	,	CASE
			WHEN	UDES.SEC25EINELIGIBLE = 1 THEN 'Ineligible'
			WHEN	s.state_studentnumber IS NULL	THEN 'Incomplete'
			WHEN	SMSGX.firstAttendDate IS NULL THEN	 'Incomplete'
			WHEN	UDES.SEC25EEXITEDLEANAME IS NULL	THEN	 'Incomplete'
			WHEN	UDES.SEC25EEXITEDLEANUMBER IS NULL	THEN	 'Incomplete'
			WHEN	UDES.SEC25EEXITEDSCHOOL IS NULL	THEN	 'Incomplete'
			WHEN	UDES.SEC25EFALLLEANAME IS NULL	THEN	 'Incomplete'
			WHEN	UDES.SEC25EFALLLEANUMBER IS NULL	THEN	 'Incomplete'
			WHEN	UDES.Sec25eFTE IS NULL	THEN	 'Incomplete'
			WHEN	UDES.SEC25ESUBMITTEDDATE IS NOT NULL THEN 'Submitted'
			ELSE	'Complete'
			END
	,	CASE
			WHEN	UDES.SEC25ESUBMITTEDDATE	IS NULL THEN 'Not Submitted'
			ELSE	TO_CHAR(UDES.SEC25ESUBMITTEDDATE,'MM/DD/YYYY')
			END
	,	UDES.SEC25ECOMMENTS

FROM		PS_Enrollment_Reg		PSER

INNER JOIN	students				s
		ON		s.id					=	PSER.studentid
INNER JOIN	schools					sch
		ON		sch.school_number		=	PSER.schoolid

LEFT JOIN	S_MI_STU_GC_X			SMSGX
		ON		SMSGX.studentsdcid		=	s.dcid

LEFT JOIN	U_DEF_EXT_STUDENTS	UDES
		ON		UDES.studentsdcid		=	s.dcid

WHERE	PSER.entrydate	<	PSER.exitdate

GROUP BY
	s.dcid
	,	s.id
	,	UDES.SEC25EINELIGIBLE
	,	UDES.SEC25ECOMMENTS
	,	s.last_name
	,	s.first_name
	,	s.middle_name
	,	s.state_studentnumber
	,	s.dob
	,	SMSGX.residentLEA
	,	SMSGX.residentMembership
	,	SMSGX.SRMDate
	,	UDES.SEC25EEXITEDLEANAME
	,	UDES.SEC25EEXITEDLEANUMBER
	,	UDES.SEC25EEXITEDSCHOOL
	,	UDES.SEC25EFALLLEANAME
	,	UDES.SEC25EFALLLEANUMBER
	,	UDES.SEC25EFALLISD
	,	SMSGX.firstAttendDate
	,	UDES.Sec25eFTE
	,	UDES.Sec25eFTE52
	,	SMSGX.sePrgm1
	,	UDES.SEC25ESUBMITTEDDATE

HAVING		SUM(CASE WHEN PSER.entrydate <= '10/7/2015' AND PSER.exitdate > '10/7/2015' THEN 1 ELSE 0 END) = 0		-- SET DATES TO FIRST AND LAST SUBMISSION DATE
	AND		(SUM(CASE WHEN PSER.entrydate <= '10/7/2015' AND PSER.exitdate > '10/7/2015' THEN 1 ELSE 0 END) = 0 OR UDES.SEC25ESUBMITTEDDATE IS NULL)		-- SET DATES TO FIRST AND LAST SUBMISSION DATE
	AND		SUM(CASE WHEN PSER.entrydate > '10/7/2015' ~[if.is.a.school] AND PSER.schoolid = ~(curschoolid)[/if] THEN 1 ELSE 0 END) > 0	-- SET DATE TO LAST SUBMISSION DATE
	AND		MAX(PSER.grade_level) >= 0