SELECT
	s.dcid
	,	DENSE_RANK() OVER (ORDER BY MIN(LEAST(s.dcid, sB.dcid)) ASC)
	,	'<a href=/admin/students/home.html?frn=001'||to_char(s.dcid)||' target=_blank>Student Link</a><BR />'||
		'<a href=/admin/tech/%param2%/home.html?mcr=001'||s.dcid||' target=_blank>DDE/DDA</a><br />'||
		'<a href=/admin/reportqueue/home.html?DOTHISFOR='||s.id||'&reportname=Updated+Official+District+Transcript&useeao=no&eao='||TO_CHAR(SYSDATE,'MM/DD/YYYY')||'&transactiondate=year&transactionstartdate=&transactionenddate=&watermark=&watermarkcustom=&overlay=true&printwhen=2&printdate=&printtime=&report_request_locale=en_US&ac=printformletter&btnSubmit= target=_blank>Transcript</a>'
	,	s.last_name
	,	s.first_name
	,	s.middle_name
	,	to_char(s.dob,'mm/dd/yyyy')
	,	s.schoolid
	,	sch.name
	,	s.student_number
	,	s.enroll_status
	,	s.ID
	,	s.state_studentnumber
	,	to_char(s.entrydate,'mm/dd/yyyy')
	,	to_char(s.exitdate,'mm/dd/yyyy')
	,	s.exitcode
	,	s.enrollment_schoolid
	,	to_char(LEAST(NVL(MIN(re.entrydate),'1/1/2199'),s.entrydate),'mm/dd/yyyy')
	,	(SELECT LISTAGG('<b>'||re.schoolid||CHR(58)||'</b>'||to_char(re.entrydate,'mm/dd/yyyy')||'-'||to_char(re.exitdate,'mm/dd/yyyy')||',<br />',NULL) WITHIN GROUP (ORDER BY re.entrydate, re.exitdate) FROM reenrollments re WHERE re.studentid = s.id)||'<b>'||s.schoolid||CHR(58)||'</b>'||to_char(s.entrydate,'mm/dd/yyyy')||'-'||to_char(s.exitdate,'mm/dd/yyyy')
	,	COUNT(DISTINCT sB.dcid) + 1
	,	CASE WHEN (SUM(CASE WHEN (re.exitdate > reb.entrydate AND re.entrydate < reb.exitdate) THEN 1 ELSE 0 END)
		+	SUM(CASE WHEN (re.exitdate > sB.entrydate AND re.entrydate < sB.exitdate) THEN 1 ELSE 0 END)
		+	SUM(CASE WHEN (s.exitdate > reb.entrydate AND s.entrydate < reb.exitdate) THEN 1 ELSE 0 END)
		+	SUM(CASE WHEN (s.exitdate > sB.entrydate AND s.entrydate < sB.exitdate) THEN 1 ELSE 0 END)) > 0 THEN 'Yes' ELSE 'No' END
	,	LISTAGG(CASE
			WHEN	(sB.last_name				=	s.Last_Name
					AND		sB.first_name				=	s.First_Name
					AND		sB.dob						=	s.dob)
				THEN	'Name, DOB'
			WHEN	(sB.state_studentnumber					=	s.state_studentnumber)
				THEN	'UIC'
			ELSE		'Unknown'
			END,'<br />') WITHIN GROUP (ORDER BY sB.dcid)

	,	NVL((SELECT COUNT(b.studentid) FROM attendance b WHERE b.studentid = s.id),0)
		+ NVL((SELECT COUNT(c.studentid) FROM attendancequeue c WHERE c.studentid = s.id),0)
		+ NVL((SELECT COUNT(d.studentid) FROM cc d WHERE d.studentid = s.id),0)
		+ NVL((SELECT COUNT(e.studentid) FROM classrank e WHERE e.studentid = s.id),0)
		+ NVL((SELECT COUNT(f.studentid) FROM log f WHERE f.studentid = s.id),0)
		+ NVL((SELECT COUNT(g.studentid) FROM logins g WHERE g.studentid = s.id),0)
		+ NVL((SELECT COUNT(h.studentid) FROM PGFinalGrades h WHERE h.studentid = s.id),0)
		+ NVL((SELECT COUNT(i.studentid) FROM PhoneLog i WHERE i.studentid = s.id),0)
		+ NVL((SELECT COUNT(j.studentid) FROM ReEnrollments j WHERE j.studentid = s.id),0)
		+ NVL((SELECT COUNT(k.studentid) FROM ScheduleCC k WHERE k.studentid = s.id),0)
		+ NVL((SELECT COUNT(l.studentid) FROM ScheduleRequests l WHERE l.studentid = s.id),0)
		+ NVL((SELECT COUNT(m.studentid) FROM SectionScores m WHERE m.studentid = s.id),0)
		+ NVL((SELECT COUNT(n.studentid) FROM SectionScoresID n WHERE n.studentid = s.id),0)
		+ NVL((SELECT COUNT(o.studentid) FROM SpEnrollments o WHERE o.studentid = s.id),0)
		+ NVL((SELECT COUNT(p.studentid) FROM StoredGrades p WHERE p.studentid = s.id),0)
		+ NVL((SELECT COUNT(q.studentid) FROM StudentRace q WHERE q.studentid = s.id),0)
		+ NVL((SELECT COUNT(s.studentid) FROM StudentSchedulingResults s WHERE s.studentid = s.id),0)
		+ NVL((SELECT COUNT(t.studentid) FROM StudentTest t WHERE t.studentid = s.id),0)
		+ NVL((SELECT COUNT(u.studentid) FROM StudentTestScore u WHERE u.studentid = s.id),0)
		+ NVL((SELECT COUNT(v.studentid) FROM Truancies v WHERE v.studentid = s.id),0)
		+ NVL((SELECT COUNT(w.studentid) FROM UnscheduledStudent w WHERE w.studentid = s.id),0) AS total_count

	,	'<a href=/admin/tech/%param2%/home.html'||CHR(63)||'ac=usm'||CHR(38)||'filenum=157'||CHR(38)||'fieldnum_1=6'||CHR(38)||'comparator1='||CHR(37)||'3D'||CHR(38)||'search=submit'||CHR(38)||'value='||s.id||' target=_blank>'||(SELECT COUNT(att.studentid) FROM Attendance att WHERE att.studentid = s.id)||'</a>'
	,	'<a href=/admin/tech/%param2%/home.html'||CHR(63)||'ac=usm'||CHR(38)||'filenum=48'||CHR(38)||'fieldnum_1=2'||CHR(38)||'comparator1='||CHR(37)||'3D'||CHR(38)||'search=submit'||CHR(38)||'value='||s.id||' target=_blank>'||(SELECT COUNT(aq.studentid) FROM AttendanceQueue aq WHERE aq.studentid = s.id)||'</a>'
	,	'<a href=/admin/tech/%param2%/home.html'||CHR(63)||'ac=usm'||CHR(38)||'filenum=4'||CHR(38)||'fieldnum_1=2'||CHR(38)||'comparator1='||CHR(37)||'3D'||CHR(38)||'search=submit'||CHR(38)||'value='||s.id||' target=_blank>'||(SELECT COUNT(cc.studentid) FROM CC cc WHERE cc.studentid = s.id)||'</a>'
	,	'<a href=/admin/tech/%param2%/home.html'||CHR(63)||'ac=usm'||CHR(38)||'filenum=15'||CHR(38)||'fieldnum_1=2'||CHR(38)||'comparator1='||CHR(37)||'3D'||CHR(38)||'search=submit'||CHR(38)||'value='||s.id||' target=_blank>'||(SELECT COUNT(cr.studentid) FROM ClassRank cr WHERE cr.studentid = s.id)||'</a>'
	,	'<a href=/admin/tech/%param2%/home.html'||CHR(63)||'ac=usm'||CHR(38)||'filenum=8'||CHR(38)||'fieldnum_1=2'||CHR(38)||'comparator1='||CHR(37)||'3D'||CHR(38)||'search=submit'||CHR(38)||'value='||s.id||' target=_blank>'||(SELECT COUNT(la.studentid) FROM Log la WHERE la.studentid = s.id)||'</a>'
	,	'<a href=/admin/tech/%param2%/home.html'||CHR(63)||'ac=usm'||CHR(38)||'filenum=16'||CHR(38)||'fieldnum_1=15'||CHR(38)||'comparator1='||CHR(37)||'3D'||CHR(38)||'search=submit'||CHR(38)||'value='||s.id||' target=_blank>'||(SELECT COUNT(lb.studentid) FROM Logins lb WHERE lb.studentid = s.id)||'</a>'
	,	'<a href=/admin/tech/%param2%/home.html'||CHR(63)||'ac=usm'||CHR(38)||'filenum=95'||CHR(38)||'fieldnum_1=3'||CHR(38)||'comparator1='||CHR(37)||'3D'||CHR(38)||'search=submit'||CHR(38)||'value='||s.id||' target=_blank>'||(SELECT COUNT(pgfg.studentid) FROM PGFinalGrades pgfg WHERE pgfg.studentid = s.id)||'</a>'
	,	'<a href=/admin/tech/%param2%/home.html'||CHR(63)||'ac=usm'||CHR(38)||'filenum=27'||CHR(38)||'fieldnum_1=2'||CHR(38)||'comparator1='||CHR(37)||'3D'||CHR(38)||'search=submit'||CHR(38)||'value='||s.id||' target=_blank>'||(SELECT COUNT(pl.studentid) FROM PhoneLog pl WHERE pl.studentid = s.id)||'</a>'
	,	'<a href=/admin/tech/%param2%/home.html'||CHR(63)||'ac=usm'||CHR(38)||'filenum=18'||CHR(38)||'fieldnum_1=2'||CHR(38)||'comparator1='||CHR(37)||'3D'||CHR(38)||'search=submit'||CHR(38)||'value='||s.id||' target=_blank>'||(SELECT COUNT(re.studentid) FROM ReEnrollments re WHERE re.studentid = s.id)||'</a>'
	,	'<a href=/admin/tech/%param2%/home.html'||CHR(63)||'ac=usm'||CHR(38)||'filenum=111'||CHR(38)||'fieldnum_1=2'||CHR(38)||'comparator1='||CHR(37)||'3D'||CHR(38)||'search=submit'||CHR(38)||'value='||s.id||' target=_blank>'||(SELECT COUNT(scc.studentid) FROM ScheduleCC scc WHERE scc.studentid = s.id)||'</a>'
	,	'<a href=/admin/tech/%param2%/home.html'||CHR(63)||'ac=usm'||CHR(38)||'filenum=82'||CHR(38)||'fieldnum_1=13'||CHR(38)||'comparator1='||CHR(37)||'3D'||CHR(38)||'search=submit'||CHR(38)||'value='||s.id||' target=_blank>'||(SELECT COUNT(sreq.studentid) FROM ScheduleRequests sreq WHERE sreq.studentid = s.id)||'</a>'
	,	'<a href=/admin/tech/%param2%/home.html'||CHR(63)||'ac=usm'||CHR(38)||'filenum=100'||CHR(38)||'fieldnum_1=3'||CHR(38)||'comparator1='||CHR(37)||'3D'||CHR(38)||'search=submit'||CHR(38)||'value='||s.id||' target=_blank>'||(SELECT COUNT(ss.studentid) FROM SectionScores ss WHERE ss.studentid = s.id)||'</a>'
	,	'<a href=/admin/tech/%param2%/home.html'||CHR(63)||'ac=usm'||CHR(38)||'filenum=197'||CHR(38)||'fieldnum_1=3'||CHR(38)||'comparator1='||CHR(37)||'3D'||CHR(38)||'search=submit'||CHR(38)||'value='||s.id||' target=_blank>'||(SELECT COUNT(ssid.studentid) FROM SectionScoresID ssid WHERE ssid.studentid = s.id)||'</a>'
	,	'<a href=/admin/tech/%param2%/home.html'||CHR(63)||'ac=usm'||CHR(38)||'filenum=41'||CHR(38)||'fieldnum_1=12'||CHR(38)||'comparator1='||CHR(37)||'3D'||CHR(38)||'search=submit'||CHR(38)||'value='||s.id||' target=_blank>'||(SELECT COUNT(se.studentid) FROM SpEnrollments se WHERE se.studentid = s.id)||'</a>'
	,	'<a href=/admin/tech/%param2%/home.html'||CHR(63)||'ac=usm'||CHR(38)||'filenum=31'||CHR(38)||'fieldnum_1=1'||CHR(38)||'comparator1='||CHR(37)||'3D'||CHR(38)||'search=submit'||CHR(38)||'value='||s.id||' target=_blank>'||(SELECT COUNT(sg.studentid) FROM StoredGrades sg WHERE sg.studentid = s.id)||'</a>'
	,	'<a href=/admin/tech/%param2%/home.html'||CHR(63)||'ac=usm'||CHR(38)||'filenum=201'||CHR(38)||'fieldnum_1=2'||CHR(38)||'comparator1='||CHR(37)||'3D'||CHR(38)||'search=submit'||CHR(38)||'value='||s.id||' target=_blank>'||(SELECT COUNT(srace.studentid) FROM StudentRace srace WHERE srace.studentid = s.id)||'</a>'
	,	'<a href=/admin/tech/%param2%/home.html'||CHR(63)||'ac=usm'||CHR(38)||'filenum=190'||CHR(38)||'fieldnum_1=3'||CHR(38)||'comparator1='||CHR(37)||'3D'||CHR(38)||'search=submit'||CHR(38)||'value='||s.id||' target=_blank>'||(SELECT COUNT(ssr.studentid) FROM StudentSchedulingResults ssr WHERE ssr.studentid = s.id)||'</a>'
	,	'<a href=/admin/tech/%param2%/home.html'||CHR(63)||'ac=usm'||CHR(38)||'filenum=87'||CHR(38)||'fieldnum_1=2'||CHR(38)||'comparator1='||CHR(37)||'3D'||CHR(38)||'search=submit'||CHR(38)||'value='||s.id||' target=_blank>'||(SELECT COUNT(st.studentid) FROM StudentTest st WHERE st.studentid = s.id)||'</a>'
	,	'<a href=/admin/tech/%param2%/home.html'||CHR(63)||'ac=usm'||CHR(38)||'filenum=89'||CHR(38)||'fieldnum_1=2'||CHR(38)||'comparator1='||CHR(37)||'3D'||CHR(38)||'search=submit'||CHR(38)||'value='||s.id||' target=_blank>'||(SELECT COUNT(sts.studentid) FROM StudentTestScore sts WHERE sts.studentid = s.id)||'</a>'
	,	'<a href=/admin/tech/%param2%/home.html'||CHR(63)||'ac=usm'||CHR(38)||'filenum=42'||CHR(38)||'fieldnum_1=2'||CHR(38)||'comparator1='||CHR(37)||'3D'||CHR(38)||'search=submit'||CHR(38)||'value='||s.id||' target=_blank>'||(SELECT COUNT(tr.studentid) FROM Truancies tr WHERE tr.studentid = s.id)||'</a>'
	,	'<a href=/admin/tech/%param2%/home.html'||CHR(63)||'ac=usm'||CHR(38)||'filenum=141'||CHR(38)||'fieldnum_1=2'||CHR(38)||'comparator1='||CHR(37)||'3D'||CHR(38)||'search=submit'||CHR(38)||'value='||s.id||' target=_blank>'||(SELECT COUNT(us.studentid) FROM UnscheduledStudent us WHERE us.studentid = s.id)||'</a>'

	,	(SELECT COUNT(b.studentid) FROM attendance b WHERE b.studentid = s.id) as att_count
	,	(SELECT COUNT(c.studentid) FROM attendancequeue c WHERE c.studentid = s.id) as attque_count
	,	(SELECT COUNT(d.studentid) FROM cc d WHERE d.studentid = s.id) as cc_count
	,	(SELECT COUNT(e.studentid) FROM classrank e WHERE e.studentid = s.id) as classrank_count
	,	(SELECT COUNT(f.studentid) FROM log f WHERE f.studentid = s.id) as log_count
	,	(SELECT COUNT(g.studentid) FROM logins g WHERE g.studentid = s.id) as logins_count
	,	(SELECT COUNT(h.studentid) FROM PGFinalGrades h WHERE h.studentid = s.id) as pgfinal_count
	,	(SELECT COUNT(i.studentid) FROM PhoneLog i WHERE i.studentid = s.id) as PhoneLog_count
	,	(SELECT COUNT(j.studentid) FROM ReEnrollments j WHERE j.studentid = s.id) as ReEnrollments_count
	,	(SELECT COUNT(k.studentid) FROM ScheduleCC k WHERE k.studentid = s.id) as ScheduleCC_count
	,	(SELECT COUNT(l.studentid) FROM ScheduleRequests l WHERE l.studentid = s.id) as ScheduleRequests_count
	,	(SELECT COUNT(m.studentid) FROM SectionScores m WHERE m.studentid = s.id) as SectionScores_count
	,	(SELECT COUNT(n.studentid) FROM SectionScoresID n WHERE n.studentid = s.id) as SectionScoresID_count
	,	(SELECT COUNT(o.studentid) FROM SpEnrollments o WHERE o.studentid = s.id) as SpEnrollments_count
	,	(SELECT COUNT(p.studentid) FROM StoredGrades p WHERE p.studentid = s.id) as StoredGrades_count
	,	(SELECT COUNT(q.studentid) FROM StudentRace q WHERE q.studentid = s.id) as StudentRace_count
	,	(SELECT COUNT(s.studentid) FROM StudentSchedulingResults s WHERE s.studentid = s.id) as StudentSchedulingResults_count
	,	(SELECT COUNT(t.studentid) FROM StudentTest t WHERE t.studentid = s.id) as StudentTest_count
	,	(SELECT COUNT(u.studentid) FROM StudentTestScore u WHERE u.studentid = s.id) as StudentTestScore_count
	,	(SELECT COUNT(v.studentid) FROM Truancies v WHERE v.studentid = s.id) as Truancies_count
	,	(SELECT COUNT(w.studentid) FROM UnscheduledStudent w WHERE w.studentid = s.id) as UnscheduledStudent_count

FROM		students			s

INNER JOIN	students			sB
		ON		sB.dcid					<>	s.dcid
		AND		((sB.last_name				=	s.Last_Name
			AND		sB.first_name				=	s.First_Name
			AND		sB.dob						=	s.dob)
		OR		(sB.state_studentnumber	=	s.state_studentnumber))

~[if#cursel.%param1%=Yes]
	INNER JOIN		~[temp.table.current.selection:students]	stusel
			ON			stusel.dcid				=	s.dcid
			OR			stusel.dcid				=	sB.dcid
[/if#cursel]

LEFT JOIN	reenrollments		re
		ON		re.studentid				=	s.id
LEFT JOIN	reenrollments		reb
		ON		reb.studentid				=	sB.id
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
	,	s.state_studentnumber
	,	s.entrydate
	,	s.exitdate
	,	s.exitcode
	,	s.enrollment_schoolid


ORDER BY
	MIN(LEAST(s.dcid, sB.dcid)) ASC
	,	s.exitdate DESC