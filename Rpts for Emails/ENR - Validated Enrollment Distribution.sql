SELECT
	sch.name
	,	SUM(CASE WHEN (attAggA.distribution = 0										)	THEN 1 ELSE 0 END)
	,	SUM(CASE WHEN (attAggA.distribution > 0		AND attAggA.distribution <=	0.1	)	THEN 1 ELSE 0 END)
	,	SUM(CASE WHEN (attAggA.distribution > 0.1	AND attAggA.distribution <=	0.2	)	THEN 1 ELSE 0 END)
	,	SUM(CASE WHEN (attAggA.distribution > 0.2	AND attAggA.distribution <=	0.3	)	THEN 1 ELSE 0 END)
	,	SUM(CASE WHEN (attAggA.distribution > 0.3	AND attAggA.distribution <=	0.4	)	THEN 1 ELSE 0 END)
	,	SUM(CASE WHEN (attAggA.distribution > 0.4	AND attAggA.distribution <=	0.5	)	THEN 1 ELSE 0 END)
	,	SUM(CASE WHEN (attAggA.distribution > 0.5	AND attAggA.distribution <=	0.6	)	THEN 1 ELSE 0 END)
	,	SUM(CASE WHEN (attAggA.distribution > 0.6	AND attAggA.distribution <=	0.7	)	THEN 1 ELSE 0 END)
	,	SUM(CASE WHEN (attAggA.distribution > 0.7	AND attAggA.distribution <=	0.8	)	THEN 1 ELSE 0 END)
	,	SUM(CASE WHEN (attAggA.distribution > 0.8	AND attAggA.distribution <=	0.9	)	THEN 1 ELSE 0 END)
	,	SUM(CASE WHEN (attAggA.distribution > 0.9	AND attAggA.distribution <=	1.0	)	THEN 1 ELSE 0 END)
	,	SUM(CASE WHEN (attAggA.distribution < 0										)	THEN 1 ELSE 0 END)
	,	COUNT(*)

FROM	schools			sch

INNER JOIN (
	SELECT
		PSER.schoolid
		,	PSER.studentid
		,	PSER.grade_level
		,	CASE WHEN COUNT( DISTINCT pam2.date_value) = 0 THEN -1
				ELSE	COUNT (
							DISTINCT (
								CASE
									WHEN	(PSER.grade_level	<=	8
										AND	pam2.pres_count		>	0)
									THEN	pam2.date_value
									WHEN	(PSER.grade_level	>	8
										AND	pam2.pres_count		>	1)
									THEN	pam2.date_value
									ELSE	NULL
								END))/COUNT( DISTINCT pam2.date_value)
				END	AS		distribution

	FROM		ps_enrollment_reg		PSER

	LEFT JOIN (
		SELECT
			s.id	AS	studentid
			,	ca_d.date_value
			,	ca_d.schoolid
			,	count(*)	AS	no_periods
			,	SUM(CASE
						WHEN ac.presence_status_cd =	'Present' THEN 1
						ELSE	0
						END) AS pres_count
			,	SUM(CASE
						WHEN ac.presence_status_cd =	'Absent' THEN 1
						ELSE	0
						END) AS abs_count
			,	SUM(CASE
						WHEN att.attendance_codeid IS NULL THEN 1
						ELSE	0
						END) AS blank_count

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

		WHERE	ca_d.date_value		>=	'%param1%'
			AND	ca_d.date_value		<=	'%param2%'
			AND	ca_d.insession		=	1
			AND	bsi.ada_code		=	1
			AND	sect.exclude_ada	=	0
			
			~[if.is.a.school] 
				AND	s.schoolid = ~(curschoolid)
			[/if]

		GROUP BY
			s.id
			,	ca_d.date_value
			,	ca_d.schoolid
	)	pam2
		ON			pam2.studentid		=	PSER.studentid
		AND			pam2.schoolid		=	PSER.schoolid

	WHERE	PSER.entrydate		<=		'%param2%'
		AND	PSER.exitdate		>		'%param2%'
		AND	PSER.schoolid		NOT IN	(45541,777777,999999,6666666,666666,11111)
		AND	PSER.grade_level	>=		0
		AND	PSER.schoolid 		IN		(%param3%)

	GROUP BY
		PSER.schoolid
		,	PSER.studentid
		,	PSER.grade_level
) 	attAggA
	ON	attAggA.schoolid		=	sch.school_number
	
GROUP BY
	ROLLUP(sch.name)

ORDER BY
	MIN(attAggA.grade_level) DESC
	,	MAX(attAggA.grade_level) ASC
	,	sch.name