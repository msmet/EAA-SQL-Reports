SELECT b.name, a.first_name, a.last_name, a.grade_level, to_char(a.entrydate, 'MM/DD/YYYY') as entrydate, to_char(a.exitdate, 'MM/DD/YYYY') as exitdate, to_char(a.entrydate,'Day') as entryday, to_char(a.exitdate,'Day') as exitday, a.exitcode as exitcode, a.exitcomment as exitstatus,
(CASE
WHEN a.entrydate BETWEEN '%param1%' AND '%param2%' THEN '1'
ELSE '0'
END) as Entries,
(CASE 
WHEN a.exitdate BETWEEN '%param1%' AND '%param2%' THEN '1'
ELSE '0'
END) as Exits
FROM students a LEFT JOIN schools b ON a.schoolid = b.school_number
WHERE (a.entrydate BETWEEN '%param1%' AND '%param2%' OR a.exitdate BETWEEN '%param1%' AND '%param2%') and a.entrydate != a.exitdate
ORDER BY b.name, a.grade_level, a.last_name, a.first_name