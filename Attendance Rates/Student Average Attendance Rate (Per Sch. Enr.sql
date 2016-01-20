SELECT
	s.dcid
	,	CASE WHEN PSER.grade_level <= 8 THEN 'K-8' WHEN PSER.grade_level >= 9 THEN '9-12' ELSE 'Unknown' END
	,	sch.name
	,	s.id
	,	s.student_number
	,	s.lastfirst
	,	PSER.grade_level
	,	s.gender
	,	CASE WHEN SMSGX.flagSpecEd = 1 THEN 'SpEd' ELSE 'GenEd' END
	,	TO_CHAR(PSER.entrydate,'MM/DD/YYYY')
	,	TO_CHAR(PSER.exitdate,'MM/DD/YYYY')
	,	CAST(100*(SUM	(CASE WHEN pam2.pres_count	>=	%param3%	THEN 1 ELSE 0 END))/(nvl(count(*),0)) AS DECIMAL (4,1)) || '%'
	,	CAST(100 - (100*(SUM	(CASE WHEN pam2.pres_count	>=	%param3%	THEN 1 ELSE 0 END))/(nvl(count(*),0))) AS DECIMAL (4,1)) || '%'
	,	count(*)
	,	count (DISTINCT CASE WHEN NVL(pam2.no_periods,0) > 0 THEN ca_d.date_value ELSE NULL END)
	,	SUM	(CASE WHEN pam2.pres_count	>=	%param3%	THEN 1 ELSE 0 END)
	,	SUM	(CASE WHEN pam2.pres_count	<	%param3%	THEN 1 WHEN pam2.pres_count	IS NULL THEN 1 ELSE 0 END)
	,	SUM	(NVL(pam2.no_periods,0))
	,	sum	(pam2.pres_count)
	,	sum	(pam2.abs_count)
	,	sum	(pam2.blank_count)
	,	TO_CHAR(TO_DATE(MIN	(CASE WHEN pam2.pres_count > 0 THEN  pam2.date_value ELSE  NULL END)),'MM/DD/YYYY')
	,	TO_CHAR(TO_DATE(MAX	(CASE WHEN pam2.pres_count > 0 THEN  pam2.date_value ELSE  NULL END)),'MM/DD/YYYY')

FROM		calendar_day			ca_d
INNER JOIN	ps_enrollment_reg		PSER
	ON			PSER.schoolid			=	ca_d.schoolid
	AND			PSER.entrydate			<=	ca_d.date_value
	AND			PSER.exitdate			>	ca_d.date_value
	AND		(	(PSER.track IS NULL)
		OR		(PSER.track = 'A'	AND		ca_d.A = 1)
		OR		(PSER.track = 'B'	AND		ca_d.B = 1)
		OR		(PSER.track = 'C'	AND		ca_d.C = 1)
		OR		(PSER.track = 'D'	AND		ca_d.D = 1)
		OR		(PSER.track = 'E'	AND		ca_d.E = 1)
		OR		(PSER.track = 'F'	AND		ca_d.F = 1))
INNER JOIN	Students				s
	ON			s.id						=	PSER.studentid
INNER JOIN	Schools					sch
	ON			sch.School_Number			=	ca_d.schoolid
LEFT JOIN	S_MI_STU_GC_X	SMSGX
	ON			SMSGX.studentsdcid		=	s.dcid
~[if#cursel.%param4%=Yes]
	INNER JOIN		~[temp.table.current.selection:students] stusel
		ON			s.dcid					=	stusel.dcid
[/if#cursel]

LEFT JOIN (
	SELECT
		s.id	AS	studentid
		,	ca_d.date_value
		,	ca_d.schoolid
		,	count(*)	AS	no_periods
		,	SUM(CASE WHEN ac.presence_status_cd = 'Present' THEN 1 ELSE 0 END) AS pres_count
		,	SUM(CASE WHEN ac.presence_status_cd = 'Absent' THEN 1 ELSE 0 END) AS abs_count
		,	SUM(CASE WHEN ac.presence_status_cd IS NULL THEN 1 ELSE 0 END) AS blank_count

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
		AND	bsi.ada_code	=	1
		AND	sect.exclude_ada	=	0
		AND	(ac.att_code		!=	'NCH'
			OR	ac.att_code		IS	NULL)

	GROUP BY
		s.id
		,	ca_d.date_value
		,	ca_d.schoolid
)	pam2
	ON			pam2.studentid		=	PSER.studentid
	AND			pam2.date_value		=	ca_d.date_value
	AND			pam2.schoolid		=	ca_d.schoolid

WHERE	ca_d.date_value	>=	'%param1%'
	AND	ca_d.date_value	<=	'%param2%'
	AND	ca_d.insession	=	1
	AND	ca_d.schoolid	NOT IN	(45541,777777,999999,6666666,666666,11111)
	AND	ca_d.schoolid	IN		(%param5%)

GROUP BY
	s.dcid
	,	s.id
	,	s.student_number
	,	s.lastfirst
	,	s.gender
	,	SMSGX.flagSpecEd
	,	sch.name
	,	PSER.entrydate
	,	PSER.exitdate
	,	PSER.grade_level

ORDER BY
	sch.name
	,	PSER.grade_level
	,	s.lastfirst