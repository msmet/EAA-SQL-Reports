SELECT
	s.dcid
	,	schb.name
	,	COUNT(DISTINCT sch.name)
	,	TO_CHAR(MIN (PSER.entrydate),'MM/DD/YYYY')
	,	TO_CHAR(MAX (PSER.exitdate),'MM/DD/YYYY')
	,	MAX (PSER.grade_level)
	,	'<a href=/admin/students/home.html?frn=001'||to_char(s.dcid)||' target=_blank>'||s.student_number||'</a>'
	,	s.state_studentnumber
	,	s.first_name
	,	s.last_name
	,	s.middle_name
	,	TO_CHAR(s.dob,'MM/DD/YYYY')
	,	s.gender
	,	SMSGX.residentLEA
	,	SMSGX.residentCounty
	,	s.street
	,	s.city
	,	s.state
	,	s.zip
	,	SMSGX.ethnicIndian||SMSGX.ethnicAsian||SMSGX.ethnicBlack||SMSGX.ethnicPacific||SMSGX.ethnicWhite||SMSGX.ethnicHispanic
	,	s.home_phone
	,	CASE WHEN s.state_studentnumber IS NULL THEN 'Y' ELSE 'N' END
	,	CASE WHEN s.first_name IS NULL OR s.last_name IS NULL THEN 'Y' ELSE 'N' END
	,	CASE WHEN s.dob IS NULL OR s.dob < '1/1/1990' THEN 'Y' ELSE 'N' END
	,	CASE WHEN s.gender IS NULL THEN 'Y' ELSE 'N' END
	,	CASE WHEN SMSGX.residentLEA IS NULL THEN 'Y' ELSE 'N' END
	,	CASE WHEN SMSGX.residentCounty IS NULL THEN 'Y' ELSE 'N' END
	,	CASE WHEN
			(	s.street	IS	NULL
			OR	s.city		IS	NULL
			OR	s.state		IS	NULL
			OR	s.zip		IS	NULL) THEN 'Y' ELSE 'N' END
	,	CASE WHEN
			(	(SMSGX.ethnicIndian		NOT IN	(1)	OR	SMSGX.ethnicIndian	IS NULL)
			AND	(SMSGX.ethnicAsian		NOT IN	(1)	OR	SMSGX.ethnicAsian	IS NULL)
			AND	(SMSGX.ethnicBlack		NOT IN	(1)	OR	SMSGX.ethnicBlack	IS NULL)
			AND	(SMSGX.ethnicPacific	NOT IN	(1) OR	SMSGX.ethnicPacific IS NULL)
			AND	(SMSGX.ethnicWhite		NOT IN	(1) OR	SMSGX.ethnicWhite	IS NULL)
			AND	(SMSGX.ethnicHispanic	NOT IN	(1)	OR	SMSGX.ethnicHispanic	IS NULL))	THEN	'Y'
			ELSE												'N'	END
	,	CASE WHEN	s.home_phone LIKE '___-___-____' THEN 'N' ELSE 'Y' END
	,	CASE WHEN	(s.state_studentnumber	IS	NULL
			OR	s.first_name			IS	NULL
			OR	s.last_name				IS	NULL
			OR	s.dob					IS	NULL
			OR	s.dob					<	'1/1/1990'
			OR	s.gender				IS	NULL
			OR	s.street				IS	NULL
			OR	s.city					IS	NULL
			OR	s.state					IS	NULL
			OR	s.zip					IS	NULL
			OR	SMSGX.residentLEA		IS	NULL
			OR	SMSGX.residentCounty		IS	NULL
			OR	(	(SMSGX.ethnicIndian		NOT IN	(1)	OR	SMSGX.ethnicIndian	IS NULL)
				AND	(SMSGX.ethnicAsian		NOT IN	(1)	OR	SMSGX.ethnicAsian	IS NULL)
				AND	(SMSGX.ethnicBlack		NOT IN	(1)	OR	SMSGX.ethnicBlack	IS NULL)
				AND	(SMSGX.ethnicPacific	NOT IN	(1) OR	SMSGX.ethnicPacific IS NULL)
				AND	(SMSGX.ethnicWhite		NOT IN	(1) OR	SMSGX.ethnicWhite	IS NULL)
				AND	(SMSGX.ethnicHispanic	NOT IN	(1)	OR	SMSGX.ethnicHispanic	IS NULL))
			OR	s.home_phone			NOT LIKE '___-___-____') THEN 'Incomplete'
		ELSE	'Complete'
		END
	
FROM		ps_enrollment_reg		PSER
INNER JOIN	students				s
		ON		s.id					=	PSER.studentid
INNER JOIN	schools					sch
		ON		sch.school_number		=	PSER.schoolid
INNER JOIN	schools					schb
		ON		schb.school_number		=	s.schoolid
LEFT JOIN	S_MI_STU_GC_X	SMSGX
	ON			SMSGX.studentsdcid		=	s.dcid

~[if.%param1%=Yes]
	INNER JOIN ~[temp.table.current.selection:students] stusel ON stusel.dcid=s.dcid
[/if]

WHERE	PSER.entrydate	< PSER.exitdate
	~[if.%param1%=No]
		AND	 PSER.entrydate >= '%param2%'
	[/if]
	
GROUP BY
	s.dcid
	,	schb.name
	,	s.student_number
	,	s.state_studentnumber
	,	s.first_name
	,	s.last_name
	,	s.middle_name
	,	s.dob
	,	s.gender
	,	SMSGX.residentLEA
	,	SMSGX.residentCounty
	,	s.street
	,	s.city
	,	s.state
	,	s.zip
	,	SMSGX.ethnicIndian
	,	SMSGX.ethnicAsian
	,	SMSGX.ethnicBlack
	,	SMSGX.ethnicPacific
	,	SMSGX.ethnicWhite
	,	SMSGX.ethnicHispanic
	,	s.home_phone


~[if.%param3%=Yes]
	HAVING	s.state_studentnumber	IS	NULL
		OR	s.first_name			IS	NULL
		OR	s.last_name				IS	NULL
		OR	s.dob					IS	NULL
		OR	s.dob					<	'1/1/1990'
		OR	s.gender				IS	NULL
		OR	s.street				IS	NULL
		OR	s.city					IS	NULL
		OR	s.state					IS	NULL
		OR	s.zip					IS	NULL
		OR	SMSGX.residentLEA		IS	NULL
		OR	SMSGX.residentCounty		IS	NULL
		OR	(	(SMSGX.ethnicIndian		NOT IN	(1)	OR	SMSGX.ethnicIndian	IS NULL)
			AND	(SMSGX.ethnicAsian		NOT IN	(1)	OR	SMSGX.ethnicAsian	IS NULL)
			AND	(SMSGX.ethnicBlack		NOT IN	(1)	OR	SMSGX.ethnicBlack	IS NULL)
			AND	(SMSGX.ethnicPacific	NOT IN	(1) OR	SMSGX.ethnicPacific IS NULL)
			AND	(SMSGX.ethnicWhite		NOT IN	(1) OR	SMSGX.ethnicWhite	IS NULL)
			AND	(SMSGX.ethnicHispanic	NOT IN	(1)	OR	SMSGX.ethnicHispanic	IS NULL))
		OR	s.home_phone			NOT LIKE '___-___-____'
[/if]