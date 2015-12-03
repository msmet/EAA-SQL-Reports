SELECT
	TO_CHAR(log_raw.grade_level) || ' - ' || log_raw.gender
	,	CAST (100*COUNT (DISTINCT CASE WHEN log_raw.log_type = 'Discipline' THEN log_raw.logdcid ELSE NULL END) / COUNT (DISTINCT log_raw.studentid) AS DECIMAL (5,1))
	,	CAST (100*COUNT (DISTINCT CASE WHEN log_raw.expulsion_flag = 'Yes' THEN log_raw.logdcid ELSE NULL END) / COUNT (DISTINCT log_raw.studentid) AS DECIMAL (5,1))
	,	CAST (100*COUNT (DISTINCT CASE WHEN log_raw.oss_flag = 'Yes' THEN log_raw.logdcid ELSE NULL END) / COUNT (DISTINCT log_raw.studentid) AS DECIMAL (5,1))
	,	CAST (100*COUNT (DISTINCT CASE WHEN log_raw.oss_flag = 'Yes' THEN log_raw.studentid ELSE NULL END) / COUNT (DISTINCT log_raw.studentid) AS DECIMAL (5,1))
	

FROM		schools				sch

LEFT JOIN (
	SELECT
		sch.school_number AS schoolid
		,	s.dcid AS studentsdcid
		,	l.dcid AS logdcid
		,	s.id AS studentid
		,	s.student_number
		,	s.lastfirst AS student_lastfirst
		,	MAX(PSER.grade_level) AS grade_level
		,	s.gender
		,	CASE
				WHEN	SMSGX.flagSpecEd		=	1	THEN	'SpEd'
				ELSE											'GenEd'
				END AS special_program
		,	CASE
				WHEN SMSGX.ethnicAsian = 1 AND SMSGX.ethnicBlack != 1 AND SMSGX.ethnicIndian != 1 AND SMSGX.ethnicPacific != 1 AND SMSGX.ethnicWhite != 1 AND SMSGX.ethnicHispanic != 1 THEN 'Asian'
				WHEN SMSGX.ethnicAsian != 1 AND SMSGX.ethnicBlack = 1 AND SMSGX.ethnicIndian != 1 AND SMSGX.ethnicPacific != 1 AND SMSGX.ethnicWhite != 1 AND SMSGX.ethnicHispanic != 1 THEN 'Black'
				WHEN SMSGX.ethnicAsian != 1 AND SMSGX.ethnicBlack != 1 AND SMSGX.ethnicIndian = 1 AND SMSGX.ethnicPacific != 1 AND SMSGX.ethnicWhite != 1 AND SMSGX.ethnicHispanic != 1 THEN 'Indian'
				WHEN SMSGX.ethnicAsian != 1 AND SMSGX.ethnicBlack != 1 AND SMSGX.ethnicIndian != 1 AND SMSGX.ethnicPacific = 1 AND SMSGX.ethnicWhite != 1 AND SMSGX.ethnicHispanic != 1 THEN 'Pacific'
				WHEN SMSGX.ethnicAsian != 1 AND SMSGX.ethnicBlack != 1 AND SMSGX.ethnicIndian != 1 AND SMSGX.ethnicPacific != 1 AND SMSGX.ethnicWhite = 1 AND SMSGX.ethnicHispanic != 1 THEN 'White'
				WHEN SMSGX.ethnicAsian != 1 AND SMSGX.ethnicBlack != 1 AND SMSGX.ethnicIndian != 1 AND SMSGX.ethnicPacific != 1 AND SMSGX.ethnicWhite != 1 AND SMSGX.ethnicHispanic = 1 THEN 'Hispanic'
				WHEN SMSGX.ethnicAsian != 1 AND SMSGX.ethnicBlack != 1 AND SMSGX.ethnicIndian != 1 AND SMSGX.ethnicPacific != 1 AND SMSGX.ethnicWhite != 1 AND SMSGX.ethnicHispanic != 1 THEN 'Unknown'
				WHEN SMSGX.ethnicAsian IS NULL AND SMSGX.ethnicBlack IS NULL AND SMSGX.ethnicIndian IS NULL AND SMSGX.ethnicPacific IS NULL AND SMSGX.ethnicWhite IS NULL AND SMSGX.ethnicHispanic IS NULL THEN 'Unknown'
				ELSE	'Multiethnic'
				END AS state_ethnicity
		,	TO_CHAR(UDEL.datecreated,'MM/DD/YYYY') AS datecreated
		,	TO_CHAR(l.Entry_Date,'MM/DD/YYYY') AS entry_date
		,	TO_CHAR(l.Entry_Date,'MM')
		,	TO_CHAR(l.Entry_Date,'W')
		,	TO_CHAR(l.Discipline_IncidentDate,'MM/DD/YYYY') AS Discipline_IncidentDate
		,	l.entry_author
		,	g1.name AS log_type
		,	TO_CHAR(g2.valueT) AS log_subtype
		,	l.Subject
		,	to_char(l.Entry) AS log_entry
		,	l.consequence
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
				END) AS consequence_full
		,	(CASE		SMLGX.actionTaken1
				WHEN	'1'						THEN	'ISS'
				WHEN	'2'						THEN	'OOS'
				WHEN	'3'						THEN	'Rem-Hearing'
				WHEN	'4'						THEN	'Uni-Rem (SpEd)'
				WHEN	'5'						THEN	'Exp'
				WHEN	'ISS'					THEN	'ISS (DEPR)'
				WHEN	'OSS'					THEN	'OSS (DEPR)'
				WHEN	'RHO'					THEN	'RHO (DEPR)'
				WHEN	'RWO'					THEN	'RWO (DEPR)'
				WHEN	'RDO'					THEN	'RDO (DEPR)'
				WHEN	'SBI'					THEN	'SBI (DEPR)'
				ELSE									SMLGX.actionTaken1
				END) AS actionTaken1
		,	SMLGX.disciplineDays1
		,	TO_CHAR(SMLGX.disciplineDate1,'MM/DD/YYYY') AS disciplineDate1
		,	(CASE		SMLGX.actionTaken2
				WHEN	'1'						THEN	'ISS'
				WHEN	'2'						THEN	'OOS'
				WHEN	'3'						THEN	'Rem-Hearing'
				WHEN	'4'						THEN	'Uni-Rem (SpEd)'
				WHEN	'5'						THEN	'Exp'
				WHEN	'ISS'					THEN	'ISS (DEPR)'
				WHEN	'OSS'					THEN	'OSS (DEPR)'
				WHEN	'RHO'					THEN	'RHO (DEPR)'
				WHEN	'RWO'					THEN	'RWO (DEPR)'
				WHEN	'RDO'					THEN	'RDO (DEPR)'
				WHEN	'SBI'					THEN	'SBI (DEPR)'
				ELSE									SMLGX.actionTaken2
				END) AS actionTaken2
		,	SMLGX.disciplineDays2
		,	TO_CHAR(SMLGX.disciplineDate2,'MM/DD/YYYY') AS disciplineDate2
		,	(CASE		SMLGX.actionTaken3
				WHEN	'1'						THEN	'ISS'
				WHEN	'2'						THEN	'OOS'
				WHEN	'3'						THEN	'Rem-Hearing'
				WHEN	'4'						THEN	'Uni-Rem (SpEd)'
				WHEN	'5'						THEN	'Exp'
				WHEN	'ISS'					THEN	'ISS (DEPR)'
				WHEN	'OSS'					THEN	'OSS (DEPR)'
				WHEN	'RHO'					THEN	'RHO (DEPR)'
				WHEN	'RWO'					THEN	'RWO (DEPR)'
				WHEN	'RDO'					THEN	'RDO (DEPR)'
				WHEN	'SBI'					THEN	'SBI (DEPR)'
				ELSE									SMLGX.actionTaken3
				END) AS actionTaken3
		,	SMLGX.disciplineDays3
		,	TO_CHAR(SMLGX.disciplineDate3,'MM/DD/YYYY') AS disciplineDate3
		,	(CASE
				WHEN	(SMLGX.actionTaken1='5'
					OR	SMLGX.actionTaken2='5'
					OR	SMLGX.actionTaken3='5'
					)							THEN	'Yes'
				ELSE									'No'
			END) AS expulsion_flag
		,	(CASE
				WHEN	(l.consequence='OSS'
					OR	SMLGX.actionTaken1='2'
					OR	SMLGX.actionTaken1='OSS'
					OR	SMLGX.actionTaken2='2'
					OR	SMLGX.actionTaken2='OSS'
					OR	SMLGX.actionTaken3='2'
					OR	SMLGX.actionTaken3='OSS'
					)							THEN	'Yes'
				ELSE									'No'
			END) AS oss_flag
		,	(CASE
				WHEN	(SMLGX.actionTaken1='2'
					OR	SMLGX.actionTaken1='OSS'
					)							THEN	SMLGX.disciplineDays1
				WHEN	(SMLGX.actionTaken2='2'
					OR	SMLGX.actionTaken2='OSS'
					)							THEN	SMLGX.disciplineDays2
				WHEN	(SMLGX.actionTaken3='2'
					OR	SMLGX.actionTaken3='OSS'
					)							THEN	SMLGX.disciplineDays3
				WHEN	l.consequence IN ('OSS','OSSL')	THEN	SMLGX.disciplineDays1
				ELSE									NULL
			END) AS oss_exp_length
		,	TO_CHAR(ca_d2.date_value,'MM/DD/YYYY')	AS	oss_exp_return
		,	TO_CHAR(MIN	(CASE
					WHEN	ac.Presence_Status_CD	=	'Present'	THEN	att.att_date
					ELSE													NULL
					END),'MM/DD/YYYY') AS oss_act_return
		,	MIN	(ca_d3.rn) - ca_d1.rn - 1 AS oss_act_length
		,	CASE WHEN SMLGX.includeGC = 1 THEN 'Yes' ELSE 'No' END AS state_flag
		,	SMLGX.incidentNbr

		
	FROM		schools			sch
	LEFT JOIN	ps_enrollment_reg	PSER
		ON			PSER.schoolid			=	sch.school_number
		AND			PSER.entrydate			<=	'%param3%'
		AND			PSER.exitdate			>	'%param2%'
	LEFT JOIN	log				l
		ON			l.studentid				=	PSER.studentid
		AND			l.schoolid				=	PSER.schoolid
		AND			((l.Discipline_IncidentDate			>=	'%param2%'
				AND	l.Discipline_IncidentDate			<=	'%param3%')
			OR		(l.Entry_Date			>=	'%param2%'
				AND	l.Entry_Date			<=	'%param3%'
				AND	Discipline_IncidentDate IS 	NULL))
	LEFT JOIN	S_MI_LOG_GC_X	SMLGX
		ON			SMLGX.logdcid			=	l.dcid
	LEFT JOIN	U_DEF_EXT_LOG	UDEL
		ON			UDEL.logdcid			=	l.dcid	
	INNER JOIN	students		s
		ON			s.id					=	PSER.studentid
	LEFT JOIN	S_MI_STU_GC_X	SMSGX
		ON			SMSGX.studentsdcid		=	s.dcid
	LEFT JOIN	gen				g1
		ON			g1.cat					=	'logtype'
		AND			g1.id					=	l.logtypeid
	LEFT JOIN	gen				g2
		ON			g2.cat					=	'subtype'
		AND			g2.name					=	TO_CHAR(g1.id)
		AND			g2.value				=	l.subtype
	LEFT JOIN	terms			ter
		ON			ter.firstday			<=	l.entry_date
		AND			ter.lastday				>	l.entry_date
		AND			ter.schoolid			=	l.schoolid
		AND			ter.IsYearRec			=	1

	~[if#cursel.%param1%=Yes]
		INNER JOIN ~[temp.table.current.selection:students] stusel ON stusel.dcid = s.dcid
	[/if#cursel]

	LEFT JOIN	attendance		att
		ON			att.studentid			=	l.studentid
		AND			att.schoolid			=	l.schoolid
		AND			att.att_date			>	l.Discipline_IncidentDate + 1
		AND			att.att_date			<	l.Discipline_IncidentDate + 45
		AND			(l.consequence='OSS'
				OR	SMLGX.actionTaken1='2'
				OR	SMLGX.actionTaken1='OSS'
				OR	SMLGX.actionTaken2='2'
				OR	SMLGX.actionTaken2='OSS'
				OR	SMLGX.actionTaken3='2'
				OR	SMLGX.actionTaken3='OSS')
	LEFT JOIN	attendance_code	ac
		ON			ac.id					=	att.attendance_codeid
		AND			ac.Calculate_ADA_YN		=	1

	LEFT JOIN	(
		SELECT
			row_number() OVER (PARTITION BY ca_d1.schoolid ORDER BY ca_d1.date_value) AS rn
			,	ca_d1.schoolid
			,	ca_d1.date_value
		FROM calendar_day	ca_d1
		WHERE	ca_d1.insession				=	1
		~[if.is.a.school]
			AND	ca_d1.schoolid						=	~(curschoolid)
		[/if]
		ORDER BY
			ca_d1.schoolid
			,	ca_d1.date_value asc
	)	ca_d1
		ON			ca_d1.date_value		=	l.Discipline_IncidentDate
		AND			ca_d1.schoolid			=	l.schoolid

	LEFT JOIN	(
		SELECT
			row_number() OVER (PARTITION BY ca_d2.schoolid ORDER BY ca_d2.date_value)	AS	rn
			,	ca_d2.schoolid
			,	ca_d2.date_value
		FROM calendar_day	ca_d2
		WHERE	ca_d2.insession				=	1
		~[if.is.a.school]
			AND	ca_d2.schoolid						=	~(curschoolid)
		[/if]
		ORDER BY
			ca_d2.schoolid
			,	ca_d2.date_value asc
	)	ca_d2
		ON			ca_d2.schoolid			=	l.schoolid
		AND			ca_d2.rn				=	ca_d1.rn + 1 + CAST((CASE
				WHEN	(SMLGX.actionTaken1='2'
					OR	SMLGX.actionTaken1='OSS'
					)							THEN	SMLGX.disciplineDays1
				WHEN	(SMLGX.actionTaken2='2'
					OR	SMLGX.actionTaken2='OSS'
					)							THEN	SMLGX.disciplineDays2
				WHEN	(SMLGX.actionTaken3='2'
					OR	SMLGX.actionTaken3='OSS'
					)							THEN	SMLGX.disciplineDays3
				WHEN	l.consequence IN ('OSS','OSSL')	THEN	SMLGX.disciplineDays1
				ELSE									NULL
			END) AS INT)

	LEFT JOIN	(
		SELECT
			row_number() OVER (PARTITION BY ca_d3.schoolid ORDER BY ca_d3.date_value)	AS	rn
			,	ca_d3.schoolid
			,	ca_d3.date_value
		FROM calendar_day	ca_d3
		WHERE	ca_d3.insession				=	1
		~[if.is.a.school]
			AND	ca_d3.schoolid						=	~(curschoolid)
		[/if]
		ORDER BY
			ca_d3.schoolid
			,	ca_d3.date_value asc
	)	ca_d3
		ON			ca_d3.schoolid			=	l.schoolid
		AND			ca_d3.date_value		=	att.att_date
		AND			ac.Presence_Status_CD	=	'Present'

	WHERE	1							=	1
		~[if.is.a.school]
			AND	PSER.schoolid					=	~(curschoolid)
		[/if]

	GROUP BY
			sch.school_number
		,	s.dcid
		,	s.id
		,	s.student_number
		,	s.lastfirst
		,	s.grade_level
		,	s.gender
		,	SMSGX.flagSpecEd
		,	UDEL.datecreated
		,	l.Entry_Date
		,	l.Discipline_IncidentDate
		,	l.entry_author
		,	g1.name
		,	TO_CHAR(g2.valueT)
		,	l.Subject
		,	to_char(l.Entry)
		,	l.consequence
		,	l.id
		,	l.dcid
		,	SMLGX.actionTaken1
		,	SMLGX.disciplineDays1
		,	SMLGX.actionTaken2
		,	SMLGX.disciplineDays2
		,	SMLGX.actionTaken3
		,	SMLGX.disciplineDays3
		,	SMLGX.disciplineDate1
		,	SMLGX.disciplineDate2
		,	SMLGX.disciplineDate3
		,	ca_d2.date_value
		,	ca_d1.rn
		,	SMLGX.includeGC
		,	SMLGX.incidentNbr
		,	SMSGX.ethnicAsian
		,	SMSGX.ethnicBlack
		,	SMSGX.ethnicIndian
		,	SMSGX.ethnicPacific
		,	SMSGX.ethnicWhite
		,	SMSGX.ethnicHispanic
		
	ORDER BY
		l.Entry_Date
) log_raw
		ON		log_raw.schoolid		=	sch.school_number

WHERE
	sch.school_number NOT IN (45541,777777,999999,6666666,666666,11111)
	~[if.is.a.school]
		AND	sch.school_number			=	~(curschoolid)
	[/if]
GROUP BY
	log_raw.grade_level
	,	ROLLUP(log_raw.gender)