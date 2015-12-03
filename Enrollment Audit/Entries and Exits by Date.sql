SELECT
	to_char(ca_d.date_value,'MM/DD/YYYY')
	,	COUNT(DISTINCT PSERa.studentid)
	,	COUNT(DISTINCT PSERb.studentid)
	
FROM		schools				sch
INNER JOIN	calendar_day		ca_d
		ON		ca_d.schoolid		=	sch.school_number
LEFT JOIN	PS_Enrollment_Reg	PSERa
		ON		PSERa.schoolid		=	ca_d.schoolid
		AND		PSERa.entrydate		=	ca_d.date_value
		AND		PSERa.grade_level	>=	%param3%
		AND		PSERa.entrydate		<	PSERa.exitdate
LEFT JOIN	PS_Enrollment_Reg	PSERb
		ON		PSERb.schoolid		=	ca_d.schoolid
		AND		PSERb.exitdate		=	ca_d.date_value
		AND		PSERb.grade_level	>=	%param3%
		AND		PSERb.entrydate		<	PSERb.exitdate

WHERE	ca_d.date_value		>	'%param1%'
	AND	ca_d.date_value		<=	'%param2%'
	AND	ca_d.schoolid		IN	(%param4%)

GROUP BY
	ca_d.date_value
	,	ca_d.insession
	
HAVING	ca_d.insession = 1
	OR	count(PSERa.studentid) + count(PSERb.studentid) > 0

ORDER BY
	ca_d.date_value