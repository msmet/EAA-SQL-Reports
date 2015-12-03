SELECT
	enrAgg.name
	,	COUNT (DISTINCT CASE WHEN enrAgg.ver_count >= 1 THEN enrAgg.studentid ELSE NULL END)
	,	COUNT (DISTINCT CASE WHEN enrAgg.ver_count >= 2 THEN enrAgg.studentid ELSE NULL END)
	,	COUNT (DISTINCT CASE WHEN enrAgg.ver_count >= 3 THEN enrAgg.studentid ELSE NULL END)
	,	COUNT (DISTINCT CASE WHEN enrAgg.ver_count >= 4 THEN enrAgg.studentid ELSE NULL END)
	,	COUNT (DISTINCT CASE WHEN enrAgg.ver_count >= 5 THEN enrAgg.studentid ELSE NULL END)

FROM
(
	SELECT
		sch.name
		,	PSER.studentid
		,	PSER.grade_level
		,	COUNT ( DISTINCT ( CASE WHEN (PSER.grade_level <= 8 AND pam2.pres_count  > 0) THEN pam2.date_value WHEN (PSER.grade_level > 8 AND pam2.pres_count  > 1) THEN pam2.date_value ELSE NULL END)) AS ver_count
		,	COUNT( DISTINCT pam2.date_value)		AS		full_count

	FROM		ps_enrollment_reg		PSER
	INNER JOIN	schools					sch
			ON		sch.school_number		=	PSER.schoolid

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
						WHEN ac.presence_status_cd IS NULL THEN 1
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
				AND		(ac.calculate_ada_yn	=	1
					OR	ac.att_code		=	'NCH')

		WHERE	ca_d.date_value		>=	'%param1%'
			AND	ca_d.date_value		<=	'%param2%'
			AND	ca_d.insession		=	1
			AND	bsi.ada_code		=	1
			AND	sect.exclude_ada	=	0
			AND	(ac.att_code		!=	'NCH'
				OR	ac.att_code		IS	NULL)
			AND	ca_d.schoolid IN		(%param3%)

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
		sch.name
		,	PSER.studentid
		,	PSER.grade_level
)	enrAgg

GROUP BY
	enrAgg.name