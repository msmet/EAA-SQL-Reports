SELECT school_name, IncidentDate, MAX(weekday) as weekday, grade_level, consequence, MAX(consequencedetail) as consequencedetail, count(consequence) as countconsequence
FROM (
SELECT
	s.dcid as dcid
	,	sch.name as school_name
	,	s.id as studentid
	,	s.student_number as student_number
	,	s.last_name as last_name
  , s.first_name as first_name
	,	s.grade_level as grade_level
	,	TO_CHAR(l.Entry_Date,'MM/DD/YYYY') as Entry_Date
	,	TO_CHAR(l.Discipline_IncidentDate,'MM/DD/YYYY') as IncidentDate
  ,	TO_CHAR(l.Discipline_IncidentDate,'Day') as Weekday
	,	l.entry_author as entry_author
	,	g1.name as gen_name
	,	l.Subject as subject
	,	l.consequence as consequence
	,	(CASE
			WHEN	l.consequence='AA'		THEN	'Administrative Intervention'
			WHEN	l.consequence='AC'		THEN	'Parent Contact by Administrator'
			WHEN	l.consequence='BS'		THEN	'Suspended from Riding Bus'
			WHEN	l.consequence='CC'		THEN	'Cafeteria Cleanup'
			WHEN	l.consequence='DA'		THEN	'Detention - After School'
			WHEN	l.consequence='DL'		THEN	'Detention - Lunch'
			WHEN	l.consequence='DS'		THEN	'Detention - Saturday'
			WHEN	l.consequence='INCL'	THEN	'Handled in the classroom'
			WHEN	l.consequence='ISI'		THEN	'In School Intervention'
			WHEN	l.consequence='ISS'		THEN	'In School Suspension'
			WHEN	l.consequence='ISSL'	THEN	'In School Suspension and Law Enforcement Involvement'
			WHEN	l.consequence='LP'		THEN	'Loss of Privileges'
			WHEN	l.consequence='MC'		THEN	'Meet with Counselor'
			WHEN	l.consequence='MS'		THEN	'Meet with Social Worker'
			WHEN	l.consequence='O'		THEN	'Other - As Specified Below'
			WHEN	l.consequence='OSS'		THEN	'Out of School Suspension'
			WHEN	l.consequence='OSSL'	THEN	'Out of School Suspension and Law Enforcement Involvement'
			WHEN	l.consequence='PCA'		THEN	'Parent Conference with Administrator'
			WHEN	l.consequence='PCT'		THEN	'Parent Conference with Teacher'
			WHEN	l.consequence='R'		THEN	'Restitution'
			WHEN	l.consequence='RCTR'	THEN	'Removed from Class by Teachers Request'
			WHEN	l.consequence='SCP'		THEN	'Student Must Call Parent'
			WHEN	l.consequence='SS'		THEN	'School Service or Community Service'
			WHEN	l.consequence='T'		THEN	'Teen Court'
			WHEN	l.consequence='TAC'		THEN	'Teacher and Administrator Conference'
			WHEN	l.consequence='W1'		THEN	'Warning - 1st'
			WHEN	l.consequence='W2'		THEN	'Warning - 2nd'
			WHEN	l.consequence='WAP'		THEN	'Written Apology'
			WHEN	l.consequence='WAS'		THEN	'Writing Assignment'
			WHEN	l.consequence	IS NULL	THEN	'No Consequence Given'
			ELSE									'Unknown'
			END) as ConsequenceDetail

FROM		log				l
INNER JOIN	students		s
	ON			l.studentid				=	s.id
INNER JOIN	schools			sch
	ON			sch.school_number		=	s.schoolid
LEFT JOIN	gen				g1
	ON			g1.cat					=	'logtype'
	AND			g1.id					=	l.logtypeid
LEFT JOIN      gen                          gen2
        ON                  gen2.value                       =      l.subtype
LEFT JOIN	terms			ter
	ON			ter.firstday			<=	l.entry_date
	AND			ter.lastday				>	l.entry_date
	AND			ter.schoolid			=	s.schoolid
	AND			ter.IsYearRec			=	1

WHERE	s.id							=	s.id	
		AND	l.Discipline_IncidentDate					>=	'%param1%'
		AND	l.Discipline_IncidentDate					<=	'%param2%'
    AND l.consequence is not null
) dq1
GROUP BY 
school_name
, IncidentDate
, grade_level
, consequence
ORDER BY
school_name
, IncidentDate
, grade_level
, consequence