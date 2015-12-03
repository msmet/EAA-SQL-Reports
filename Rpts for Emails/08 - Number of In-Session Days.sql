SELECT
	sch.name
	,	COUNT(DISTINCT ca_d.date_value)
	,	TO_CHAR(MIN(ca_d.date_value),'MM/DD/YYYY')
	,	TO_CHAR(MAX(ca_d.date_value),'MM/DD/YYYY')

FROM		schools			sch
INNER JOIN	terms			ter
		ON		ter.schoolid		=	sch.school_number
		AND		ter.isyearrec		=	1
		AND		ter.yearid			=	~(curyearid)
LEFT JOIN	calendar_day	ca_d
		ON		ca_d.schoolid		=	sch.school_number
		AND		ca_d.insession		=	1
		~[if.%param1%=Yes]
			AND		ca_d.date_value		>=	'%param2%'
			AND		ca_d.date_value		<=	'%param3%'
		[else]
			AND		ca_d.date_value		>=	ter.firstday
			AND		ca_d.date_value		<	'~[short.date]'
		[/if]

WHERE	sch.school_number	NOT IN (45541,777777,999999,6666666,666666,11111)

GROUP BY	sch.name