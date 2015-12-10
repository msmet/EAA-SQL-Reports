SELECT
	s.dcid
	,	'<a href=/admin/students/home.html?frn=001'||to_char(s.dcid)||' target=_blank>'||'Student'||'</a><br /><a href=/admin/students/section25e.html?frn=001'||to_char(s.dcid)||' target=_blank>'||'Sec25e'||'</a>'
	,	s.last_name
	,	s.first_name
	,	s.middle_name
	,	CASE
			WHEN	s.state_studentnumber IS NULL	THEN	'<span style='||CHR(34)||'color'||CHR(58)||'red'||CHR(34)||'><b>Missing</b></span>'
			ELSE	TO_CHAR(s.state_studentnumber)
			END
	,	TO_CHAR(s.dob,'MM/DD/YYYY')
	,	'N'
	,	CASE
			WHEN	SMSGX.residentLEA IS NULL	THEN	'<span style='||CHR(34)||'color'||CHR(58)||'red'||CHR(34)||'><b>Missing</b></span>'
			ELSE	TO_CHAR(SMSGX.residentLEA)
			END
	,	CASE
			WHEN	SMSGX.residentMembership IS NULL	THEN	'<span style='||CHR(34)||'color'||CHR(58)||'red'||CHR(34)||'><b>Missing</b></span>'
			ELSE	TO_CHAR(SMSGX.residentMembership)
			END
	,	'Education Achievement Authority'
	,	84060
	,	TO_CHAR(SMSGX.SRMDate,'MM/DD/YYYY')
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
			WHEN	UDES.SEC25EFALLISD IS NULL	THEN	'<span style='||CHR(34)||'color'||CHR(58)||'red'||CHR(34)||'><b>Missing</b></span>'
			ELSE	TO_CHAR(UDES.SEC25EFALLISD)
			END
	,	LISTAGG(CASE WHEN PSER.entrydate > '10/7/2015' THEN sch.name ELSE NULL END,', ') WITHIN GROUP (ORDER BY PSER.entrydate)		-- SET DATE TO LAST SUBMISSION DATE
	,	MAX(pser.grade_level)
	,	TO_CHAR(MIN(CASE WHEN PSER.entrydate > '10/7/2015' THEN PSER.entrydate ELSE NULL END),'MM/DD/YYYY')			-- SET DATE TO LAST SUBMISSION DATE
	,	CASE	
			WHEN SMSGX.firstAttendDate IS NULL THEN	'<span style='||CHR(34)||'color'||CHR(58)||'red'||CHR(34)||'><b>Missing</b></span>'
			ELSE	'<a href=/admin/attendance/record/week/meeting.html?frn=001'||to_char(s.dcid)||'&startdate='||TO_CHAR(SMSGX.firstAttendDate,'MM/DD/YYYY')||'&ATT_RecordMode=ATT_ModeMeeting target=_blank>'||TO_CHAR(SMSGX.firstAttendDate,'MM/DD/YYYY')||'</a>'
			END
	,	CASE
			WHEN	UDES.Sec25eFTE IS NULL	THEN	'<span style='||CHR(34)||'color'||CHR(58)||'red'||CHR(34)||'><b>Missing</b></span>'
			ELSE	TO_CHAR(UDES.Sec25eFTE)
			END
	,	CASE
			WHEN	UDES.Sec25eFTE52 IS NULL	THEN	'<span style='||CHR(34)||'color'||CHR(58)||'red'||CHR(34)||'><b>Missing</b></span>'
			ELSE	TO_CHAR(UDES.Sec25eFTE52)
			END
	,	SMSGX.sePrgm1
	,	CASE UDES.SEC25EINELIGIBLE
			WHEN 0 THEN 'Eligible'
			WHEN 1 THEN 'Ineligible'
			ELSE 'Unknown'
			END
	,	TO_CHAR(UDES.SEC25ESUBMITTEDDATE, 'MM/DD/YYYY')
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
	~[if.is.a.school]
		AND	PSER.schoolid = ~(curschoolid)
	[/if]

GROUP BY
	s.dcid
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
	,	sch.name
	,	SMSGX.firstAttendDate
	,	UDES.Sec25eFTE
	,	UDES.Sec25eFTE52
	,	SMSGX.sePrgm1
	,	UDES.SEC25ESUBMITTEDDATE

HAVING		SUM(CASE WHEN PSER.entrydate <= '10/7/2015' AND PSER.exitdate > '10/7/2015' THEN 1 ELSE 0 END) = 0		-- SET DATES TO FIRST AND LAST SUBMISSION DATE
	AND		(SUM(CASE WHEN PSER.entrydate <= '10/7/2015' AND PSER.exitdate > '10/7/2015' THEN 1 ELSE 0 END) = 0 OR UDES.SEC25ESUBMITTEDDATE IS NULL)		-- SET DATES TO FIRST AND LAST SUBMISSION DATE
	AND		SUM(CASE WHEN PSER.entrydate > '10/7/2015' THEN 1 ELSE 0 END) > 0	-- SET DATE TO LAST SUBMISSION DATE
	AND		MAX(PSER.grade_level) >= 0