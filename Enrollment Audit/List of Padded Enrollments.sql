SELECT
	s.dcid
	,	sch.name
	,	s.student_number
	,	'<a href=/admin/students/home.html?frn=001'||to_char(s.dcid)||' target=_blank>'||s.lastfirst||'</a>'
	,	PSER.grade_level
	,	TO_CHAR(PSER.entrydate, 'MM/DD/YYYY')
	,	TO_CHAR(PSER.exitdate, 'MM/DD/YYYY')
	,	COUNT (DISTINCT ca_d.date_value)
	,	COUNT (DISTINCT (CASE WHEN cc.id IS NOT NULL THEN ca_d.date_value ELSE NULL END))
	,	COUNT (DISTINCT (CASE WHEN cc.id IS NULL THEN ca_d.date_value ELSE NULL END))
	,	LISTAGG ((CASE WHEN cc.id IS NULL THEN TO_CHAR(ca_d.date_value,'MM/DD/YYYY') ELSE NULL END),', ') WITHIN GROUP (ORDER BY ca_d.date_value)
	
FROM		ps_enrollment_reg	PSER
INNER JOIN	students			s
		ON		s.id				=	PSER.studentid
INNER JOIN	schools				sch
		ON		sch.school_number	=	PSER.schoolid
INNER JOIN	calendar_day		ca_d
		ON		ca_d.date_value		>=	PSER.entrydate
		AND		ca_d.date_value		<	PSER.exitdate
		AND		ca_d.schoolid		=	PSER.schoolid
		AND		ca_d.insession		=	1
LEFT JOIN	cc
		ON		cc.studentid		=	PSER.studentid
		AND		cc.schoolid			=	PSER.schoolid
		AND		cc.dateenrolled		<=	ca_d.date_value
		AND		cc.dateleft			>	ca_d.date_value

WHERE	PSER.entrydate				<	PSER.exitdate
	AND	ca_d.date_value				>=	'%param1%'
	AND	ca_d.date_value				<=	'%param2%'
	AND	ca_d.schoolid				IN	(%param3%)
	
GROUP BY
	s.dcid
	,	sch.name
	,	s.student_number
	,	s.lastfirst
	,	PSER.grade_level
	,	PSER.entrydate
	,	PSER.exitdate
	
HAVING	COUNT (DISTINCT (CASE WHEN cc.id IS NOT NULL THEN ca_d.date_value ELSE NULL END)) IS NULL
	OR	COUNT (DISTINCT ca_d.date_value) != COUNT (DISTINCT (CASE WHEN cc.id IS NOT NULL THEN ca_d.date_value ELSE NULL END))