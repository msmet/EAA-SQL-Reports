WITH	student_list_source
		(studentid
		,	grade_level
		,	schoolid
		,	entrydate
		,	exitdate
		,	source_number)
AS	(
	SELECT
		ID				AS	studentid
		,	grade_level	AS	grade_level
		,	SchoolID	AS	schoolid
		,	EntryDate	AS	entrydate
		,	ExitDate	AS	exitdate
		,	1			AS	source_number
	FROM	Students
	WHERE	Grade_Level		>=	%param4%
		AND	schoolid		IN	(%param5%)
	UNION
	
	SELECT
		StudentID		AS	studentid
		,	grade_level	AS	grade_level
		,	SchoolID	AS	schoolid
		,	EntryDate	AS	entrydate
		,	ExitDate	AS	exitdate
		,	2			AS	source_number
	FROM	ReEnrollments
	WHERE	Grade_Level		>=	%param4%
		AND	schoolid		IN	(%param5%)
		
	UNION
	
	SELECT
		StudentID		AS	studentid
		,	grade_level	AS	grade_level
		,	SchoolID	AS	schoolid
		,	CalendarDate	AS	entrydate
		,	CalendarDate+1	AS	exitdate
		,	3				AS	source_number
	FROM	PS_AdaAdm_Meeting_Ptod 	pamp
	WHERE	CalendarDate	>=	'%param1%'
		AND	CalendarDate	<=	'%param2%'
		AND	Grade_Level		>=	%param4%
		AND	schoolid		IN	(%param5%)
		AND	MembershipValue	>	0
)

SELECT
	TO_CHAR(student_list.date_value,'MM/DD/YYYY')
	,	student_list.schoolid
	,	sch.abbreviation
	,	student_list.source
	,	student_list.studentid
	,	'<a href=/admin/students/home.html?frn=001'||to_char(s.dcid)||' target=_blank>'||s.student_number||'</a>'
	,	'<a href=/admin/students/home.html?frn=001'||to_char(s.dcid)||' target=_blank>'||s.lastfirst||'</a>'
	,	student_list.grade_level
	,	psap.MembershipValue
	,	psap.AttendanceValue
	,	psap.PeriodCount
	,	pam2.no_periods
	,	(CASE
			WHEN	pam2.pres_count		IS NULL		THEN	0
			ELSE	pam2.pres_count
			END)	AS	pres_count
	,	(CASE
			WHEN	pam2.abs_count		IS NULL		THEN	0
			ELSE	pam2.abs_count
			END)	AS	abs_count
	,	(CASE
			WHEN	pam2.blank_count		IS NULL		THEN	0
			ELSE	pam2.blank_count
			END)	AS	blank_count
	,	(CASE
			WHEN	pam2.pres_flag		IS NULL		THEN	0
			ELSE	pam2.pres_flag
			END)	AS	pres_flag
	,	(CASE
			WHEN	pam2.pres_excluded_count		IS NULL		THEN	0
			ELSE	pam2.pres_excluded_count
			END)	AS	pres_excluded_count
	,	(CASE
			WHEN	pam2.abs_excluded_count		IS NULL		THEN	0
			ELSE	pam2.abs_excluded_count
			END)	AS	abs_excluded_count
	,	(CASE
			WHEN	pam2.blank_excluded_count		IS NULL		THEN	0
			ELSE	pam2.blank_excluded_count
			END)	AS	blank_excluded_count
	,	pam2.per_day_agg
	,	pam2.c_course_number_agg
	,	pam2.sect_section_number_agg
	,	pam2.t_last_name_agg
	,	pam2.bsi_ada_code_agg
	,	pam2.sect_exclude_ada_agg
	,	pam2.c_exclude_ada_agg
	,	pam2.att_att_code2_agg
	,	pam2.att_presence_status_cd_agg
	,	pam2.att_calculate_ada_yn_agg
	,	pam2.att_calculate_adm_yn_agg
	,	pam2.pam_att_code_agg
	,	pam2.pam_Presence_Status_CD_agg
	,	pam2.pam_count_for_ada_agg
	,	(CASE
			WHEN	student_list.source			=	'ADAADM'	THEN	'Refresh Premier Attendance Views Data'
			WHEN	(psap.MembershipValue		=	1
					AND	pam2.pres_flag			=	psap.AttendanceValue
					AND	pam2.blank_count		>	0)
																THEN	'Match, but blank attendance remaining'
			WHEN	(psap.MembershipValue		=	1
					AND	pam2.pres_flag			=	psap.AttendanceValue)
																THEN	'Match'
			WHEN	(psap.AttendanceValue		=	1
					AND	pam2.blank_count		>	0)			THEN	'Blank attendance remaining'
			WHEN	(psap.MembershipValue		=	1
					AND	psap.AttendanceValue 	IS 	NULL)		THEN	'Check FTE Settings'
			WHEN	(pam2.no_periods			=	0
					OR	pam2.no_periods 		IS 	NULL)		THEN	'No enrolled courses. Check enrollments.'
			WHEN	pam2.pres_excluded_count	>	0			THEN	'There were '||pam2.pres_excluded_count||' presents that were excluded due to period, section, or course settings.'
			ELSE	'Outstanding mismatch'
			END)	AS	notes
	,	(CASE
			WHEN	(psap.MembershipValue		=	1
					AND	pam2.pres_flag			=	psap.AttendanceValue
					AND	pam2.blank_count		>	0)
																THEN	NULL
			WHEN	(psap.MembershipValue		=	1
					AND	pam2.pres_flag			=	psap.AttendanceValue)
																THEN	NULL
			WHEN	student_list.source			=	'ADAADM'	THEN	NULL
			WHEN	(psap.AttendanceValue		=	1
					AND	pam2.blank_count		>	0)			THEN	NULL
			WHEN	(psap.MembershipValue		=	1
					AND	psap.AttendanceValue 	IS	NULL)		THEN	'<a href=/admin/students/transferinfo.html?frn=001'||to_char(s.dcid)||' target=_blank>'||'Transfer Info'||'</a>'
			WHEN	(pam2.no_periods			=	0
					OR	pam2.no_periods 		IS 	NULL)		THEN	NULL
			WHEN	pam2.pres_excluded_count	>	0			THEN	NULL
			ELSE	NULL
			END)	AS	links

FROM	(			/***	Initial Query for Distinct Relevant Student LIST For Each Active Date		***/
	SELECT
		ca_d.date_value
		,	ca_d.schoolid
		,	sls.studentid
		,	sls.grade_level
		,	MIN(sls.source_number)	AS	source_min
		,	(CASE
				WHEN	MIN(sls.source_number)	=	1		THEN	'Current'
				WHEN	MIN(sls.source_number)	=	2		THEN	'ReEnrollments'
				WHEN	MIN(sls.source_number)	=	3		THEN	'ADAADM'
				ELSE											'Unknown'
				END)	AS	source
	FROM		calendar_day		ca_d
	LEFT JOIN	student_list_source	sls
		ON			sls.entrydate	<=	ca_d.date_value
		AND			sls.exitdate	>	ca_d.date_value
		AND			sls.schoolid	=	ca_d.schoolid
	WHERE	ca_d.date_value	>=	'%param1%'
		AND	ca_d.date_value	<=	'%param2%'
		AND	ca_d.insession	=	1
		AND	ca_d.schoolid	IN	(%param5%)
	GROUP BY
		ca_d.date_value
		,	ca_d.schoolid
		,	sls.studentid
		,	sls.grade_level
) student_list

INNER JOIN	Students				s
	ON			s.id						=	student_list.studentid
INNER JOIN	Schools					sch
	ON			sch.School_Number			=	student_list.schoolid
LEFT JOIN	PS_AdaAdm_Meeting_Ptod 	psap
	ON			psap.StudentID				=	student_list.studentid
	AND			psap.CalendarDate 			=	student_list.date_value
	AND			psap.schoolid				=	student_list.schoolid

LEFT JOIN (
	SELECT
		s.id	AS	studentid
		,	ca_d.date_value
		,	ca_d.schoolid
		,	count(*)	AS	no_periods
		,	SUM(CASE
					WHEN ac.presence_status_cd =	'Present' AND	bsi.ada_code	=	1	AND	sect.exclude_ada	=	0 THEN 1
					ELSE	0
					END) AS pres_count
		,	(CASE
					WHEN (SUM(CASE WHEN ac.presence_status_cd =	'Present' AND	bsi.ada_code	=	1	AND	sect.exclude_ada	=	0 THEN 1 ELSE	0 END))	>	0	THEN	1
					ELSE	0
					END)	AS	pres_flag
		,	SUM(CASE
					WHEN ac.presence_status_cd =	'Absent' AND	bsi.ada_code	=	1	AND	sect.exclude_ada	=	0 THEN 1
					ELSE	0
					END) AS abs_count
		,	SUM(CASE
					WHEN ac.presence_status_cd IS NULL AND	bsi.ada_code	=	1	AND	sect.exclude_ada	=	0 THEN 1
					ELSE	0
					END) AS blank_count
		,	SUM(CASE
					WHEN ac.presence_status_cd =	'Present' AND
						( 	bsi.ada_code		=	0
						OR	sect.exclude_ada	=	1)		THEN 1
					ELSE	0
					END) AS pres_excluded_count
		,	SUM(CASE
					WHEN ac.presence_status_cd =	'Absent' AND
						( 	bsi.ada_code		=	0
						OR	sect.exclude_ada	=	1)		THEN 1
					ELSE	0
					END) AS abs_excluded_count
		,	SUM(CASE
					WHEN ac.presence_status_cd IS NULL AND
						( 	bsi.ada_code		=	0
						OR	sect.exclude_ada	=	1)		THEN 1
					ELSE	0
					END) AS blank_excluded_count
		,	REPLACE( LISTAGG( NVL(	p.abbreviation||'('||cy_d.day_name||')','NULL'), '<br />')
				WITHIN GROUP (ORDER BY p.abbreviation, cc.id), 'NULL', NULL) AS per_day_agg
		,	REPLACE( LISTAGG( NVL(	c.course_number,'NULL'), '<br />')
				WITHIN GROUP (ORDER BY p.abbreviation, cc.id), 'NULL', NULL) AS c_course_number_agg
		,	REPLACE( LISTAGG( NVL(	sect.section_number,'NULL'), '<br />')
				WITHIN GROUP (ORDER BY p.abbreviation, cc.id), 'NULL', NULL) AS sect_section_number_agg
		,	REPLACE( LISTAGG( NVL(	t.last_name,'NULL'), '<br />')
				WITHIN GROUP (ORDER BY p.abbreviation, cc.id), 'NULL', NULL) AS t_last_name_agg
		,	REPLACE( LISTAGG( NVL(	'<a href=/admin/schoolsetup/bellschedules/edititem.html' || CHR(063) || 'frn=134' || bsi.dcid || CHR(038) || 'id=' || bs.dcid ||' target=_blank>' || bsi.ada_code || '</a>',999), '<br />')
				WITHIN GROUP (ORDER BY p.abbreviation, cc.id), 999, NULL) AS bsi_ada_code_agg
		,	REPLACE( LISTAGG( NVL(	'<a href=/admin/sections/edit.html' || CHR(063) || 'frn=003' || sect.dcid ||' target=_blank>' || sect.exclude_ada || '</a>',999), '<br />')
				WITHIN GROUP (ORDER BY p.abbreviation, cc.id), 999, NULL) AS sect_exclude_ada_agg
		,	REPLACE( LISTAGG( NVL(	'<a href=/admin/courses/edit.html' || CHR(063) || 'frn=002' || c.dcid ||' target=_blank>' || c.exclude_ada || '</a>',999), '<br />')
				WITHIN GROUP (ORDER BY p.abbreviation, cc.id), 999, NULL) AS c_exclude_ada_agg
		,	REPLACE( LISTAGG( NVL((CASE
			   WHEN ac.presence_status_cd IS NULL THEN 'BLANK'
			   WHEN ac.att_code IS NULL THEN 'Dflt P'
			   ELSE ac.att_code
		   END),'NULL'), '<br />')
				WITHIN GROUP (ORDER BY p.abbreviation, cc.id), 'NULL', NULL) AS att_att_code2_agg
		,	REPLACE( LISTAGG( NVL(	ac.presence_status_cd,'NULL'), '<br />')
				WITHIN GROUP (ORDER BY p.abbreviation, cc.id), 'NULL', NULL) AS att_presence_status_cd_agg
		,	REPLACE( LISTAGG( NVL(	ac.calculate_ada_yn,999), '<br />')
				WITHIN GROUP (ORDER BY p.abbreviation, cc.id), 999, NULL) AS 	att_calculate_ada_yn_agg
		,	REPLACE( LISTAGG( NVL(	ac.calculate_adm_yn,999), '<br />')
				WITHIN GROUP (ORDER BY p.abbreviation, cc.id), 999, NULL) AS 	att_calculate_adm_yn_agg
		,	REPLACE( LISTAGG( NVL(	pam.att_code,'NULL'), '<br />')
				WITHIN GROUP (ORDER BY p.abbreviation, cc.id), 'NULL', NULL) AS pam_att_code_agg
		,	REPLACE( LISTAGG( NVL(	pam.Presence_Status_CD,'NULL'), '<br />')
				WITHIN GROUP (ORDER BY p.abbreviation, cc.id), 'NULL', NULL) AS pam_Presence_Status_CD_agg
		,	REPLACE( LISTAGG( NVL(	pam.count_for_ada,999), '<br />')
				WITHIN GROUP (ORDER BY p.abbreviation, cc.id), 999, NULL) AS pam_count_for_ada_agg


	FROM		calendar_day	ca_d
	INNER JOIN	bell_schedule	bs
			ON		bs.id					=	ca_d.bell_schedule_id
	INNER JOIN	bell_schedule_items bsi
			ON		bsi.bell_schedule_id	=	bs.id
	INNER JOIN	cycle_day		cy_d
			ON		cy_d.id				=	ca_d.cycle_day_id
			AND		cy_d.schoolid		=	ca_d.schoolid
	INNER JOIN	section_meeting	sm
			ON		sm.schoolid			=	ca_d.schoolid
			AND		sm.cycle_day_letter	=	cy_d.letter
			AND		sm.year_id			=	cy_d.year_id
	INNER JOIN	period			p
			ON		p.schoolid			=	ca_d.schoolid
			AND		p.year_id			=	cy_d.year_id
			AND		p.period_number		=	sm.period_number
			AND		p.id				=	bsi.period_id
	INNER JOIN	sections		sect
			ON		sect.id				=	sm.sectionid
	INNER JOIN	courses			c
			ON		c.course_number		=	sect.course_number
	INNER JOIN	teachers		t
			ON		t.id				=	sect.teacher
	INNER JOIN	cc
			ON		(cc.sectionid		=	sect.id
				OR	cc.sectionid		=	-sect.id)
			AND		cc.schoolid			=	ca_d.schoolid
			AND		cc.dateenrolled		<=	ca_d.date_value
			AND		cc.dateleft			>	ca_d.date_value
	INNER JOIN	students		s
			ON		s.id				=	cc.studentid
	INNER JOIN	schools 		sch2
			ON		sch2.school_number	=	s.schoolid
	LEFT JOIN	PS_Attendance_Meeting	pam
			ON		pam.schoolid		=	ca_d.schoolid
			AND		pam.att_date		=	ca_d.date_value
			AND		pam.ccid			=	cc.id
			AND		pam.studentid		=	s.id
			AND		pam.periodid		=	p.id

	LEFT JOIN	attendance				att
			ON		att.studentid		=	cc.studentid
			AND		att.att_date		=	ca_d.date_value
			AND		att.ccid			=	cc.id
			AND		att.periodid		=	p.id
	LEFT JOIN	attendance_code			ac
			ON		ac.id				=	att.attendance_codeid
			AND		(ac.calculate_ada_yn	=	1
				OR	ac.att_code		=	'NCH')

	WHERE	ca_d.date_value	>=	'%param1%'
		AND	ca_d.date_value	<=	'%param2%'
		AND	ca_d.insession	=	1
		AND ca_d.schoolid	IN	(%param5%)
		AND	(ac.att_code		!=	'NCH'
			OR	ac.att_code		IS	NULL)

	GROUP BY
		s.id
		,	ca_d.date_value
		,	ca_d.schoolid
)	pam2
	ON			pam2.studentid		=	student_list.studentid
	AND			pam2.date_value		=	student_list.date_value
	AND			pam2.schoolid		=	student_list.schoolid