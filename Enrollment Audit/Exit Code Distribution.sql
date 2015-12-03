SELECT
	CASE WHEN GROUPING(sch.name) = 1 THEN 'District' ELSE sch.name END
	, SUM (CASE WHEN s.exitcode = '01' THEN 1 ELSE 0 END)
	, SUM (CASE WHEN s.exitcode = '02' THEN 1 ELSE 0 END)
	, SUM (CASE WHEN s.exitcode = '03' THEN 1 ELSE 0 END)
	, SUM (CASE WHEN s.exitcode = '04' THEN 1 ELSE 0 END)
	, SUM (CASE WHEN s.exitcode = '05' THEN 1 ELSE 0 END)
	, SUM (CASE WHEN s.exitcode = '06' THEN 1 ELSE 0 END)
	, SUM (CASE WHEN s.exitcode = '07' THEN 1 ELSE 0 END)
	, SUM (CASE WHEN s.exitcode = '08' THEN 1 ELSE 0 END)
	, SUM (CASE WHEN s.exitcode = '09' THEN 1 ELSE 0 END)
	, SUM (CASE WHEN s.exitcode = '10' THEN 1 ELSE 0 END)
	, SUM (CASE WHEN s.exitcode = '11' THEN 1 ELSE 0 END)
	, SUM (CASE WHEN s.exitcode = '12' THEN 1 ELSE 0 END)
	, SUM (CASE WHEN s.exitcode = '13' THEN 1 ELSE 0 END)
	, SUM (CASE WHEN s.exitcode = '14' THEN 1 ELSE 0 END)
	, SUM (CASE WHEN s.exitcode = '15' THEN 1 ELSE 0 END)
	, SUM (CASE WHEN s.exitcode = '16' THEN 1 ELSE 0 END)
	, SUM (CASE WHEN s.exitcode = '17' THEN 1 ELSE 0 END)
	, SUM (CASE WHEN s.exitcode = '18' THEN 1 ELSE 0 END)
	, SUM (CASE WHEN s.exitcode = '19' THEN 1 ELSE 0 END)
	, SUM (CASE WHEN s.exitcode = '20' THEN 1 ELSE 0 END)
	, SUM (CASE WHEN s.exitcode = '21' THEN 1 ELSE 0 END)
	, SUM (CASE WHEN s.exitcode = '30' THEN 1 ELSE 0 END)
	, SUM (CASE WHEN s.exitcode = '40' THEN 1 ELSE 0 END)
	, SUM (CASE WHEN s.exitcode = '41' THEN 1 ELSE 0 END)
	, SUM (CASE WHEN s.exitcode = '42' THEN 1 ELSE 0 END)
	, SUM (CASE WHEN s.exitcode = '00' THEN 1 ELSE 0 END)
	, SUM (CASE WHEN s.exitcode = '99' THEN 1 ELSE 0 END)

FROM		students				s
INNER JOIN	schools					sch
		ON		sch.school_number		=	s.enrollment_schoolid

WHERE	s.exitdate		>=	'%param1%'
	AND	s.exitdate		<=	'%param2%'
	AND	s.enrollment_schoolid		IN	(%param3%)

GROUP BY
	ROLLUP(sch.name)