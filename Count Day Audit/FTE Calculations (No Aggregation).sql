WITH ca_d_rn AS
(
	SELECT
		ca_d.schoolid
		,	ca_d.date_value
		,	ca_d.insession
		,	ca_d.bell_schedule_id
		,	ca_d.cycle_day_id
		,	ca_d.a
		,	ca_d.b
		,	ca_d.c
		,	ca_d.d
		,	ca_d.e
		,	ca_d.f
		,	RANK() OVER (PARTITION BY ca_d.schoolid ORDER BY ca_d.date_value ASC) AS rn
	FROM		terms			ter
	INNER JOIN	calendar_day	ca_d
			ON		ca_d.date_value	>=	ter.firstday
			AND		ca_d.date_value	<=	ter.lastday
			AND		ca_d.schoolid	=	ter.schoolid
	WHERE	ter.id	=	%param2%00	AND	ca_d.insession = 1
)

SELECT
	cds.schoolid
	,	cds.studentid
	,	cds.grade_level
	,	cds.entrydate
	,	cds.exitdate
	,	cds.expression
	,	cds.periodid
	,	cds.cycle_day_id
	,	cds.bell_schedule_id
	,	cds.count_date
	,	cds.count_rn
	,	ac_cd.att_code
	,	ac_cd.Presence_Status_CD
	,	ac_ec.ce_code
	,	ca_d_rn.date_value
	,	ca_d_rn.rn
	,	att.att_date
	,	ac.att_code
	,	ac.Presence_Status_CD

FROM														/* Identify each section_meeting record based on students active on Count Day. */
(
	SELECT
		PSER.schoolid
		,	PSER.studentid
		,	PSER.grade_level
		,	PSER.entrydate
		,	PSER.exitdate
		,	p.abbreviation || '('||cy_d.letter||')' AS expression
		,	p.id		AS	periodid
		,	cy_d.id		AS	cycle_day_id
		,	bs.id		AS	bell_schedule_id
		,	NVL(MIN(CASE WHEN ca_d_rn.date_value >= '%param1%' THEN ca_d_rn.date_value ELSE NULL END),'12/31/2099') AS count_date
		,	NVL(MIN(CASE WHEN ca_d_rn.date_value >= '%param1%' THEN ca_d_rn.rn ELSE NULL END),99999) AS count_rn

	FROM		ps_enrollment_reg		PSER
	INNER JOIN	cc
			ON		cc.studentid			=	PSER.studentid
			AND		cc.schoolid				=	PSER.schoolid
			AND		cc.dateenrolled			>=	PSER.entrydate
			AND		cc.dateleft				<=	PSER.exitdate
	INNER JOIN	sections				sect
			ON		sect.id					=	ABS(cc.sectionid)
	INNER JOIN	section_meeting			sm
			ON		sm.sectionid			=	sect.id
	INNER JOIN	cycle_day				cy_d
			ON		cy_d.schoolid			=	sm.schoolid
			AND		cy_d.letter				=	sm.cycle_day_letter
			AND		cy_d.year_id			=	sm.year_id	
	INNER JOIN	period					p
			ON		p.schoolid				=	sm.schoolid
			AND		p.period_number			=	sm.period_number
			AND		p.year_id				=	sm.year_id
	INNER JOIN	bell_schedule_items		bsi
			ON		bsi.period_id			=	p.id
	INNER JOIN	bell_schedule			bs
			ON		bs.id					=	bsi.bell_schedule_id
	INNER JOIN	ca_d_rn
			ON		ca_d_rn.bell_schedule_id	=	bs.id
			AND		ca_d_rn.cycle_day_id		=	cy_d.id
			AND		ca_d_rn.schoolid			=	PSER.schoolid

	WHERE	PSER.entrydate		<=	'%param1%'
		AND	PSER.exitdate		>	'%param1%'
		AND	cc.dateenrolled		<=	'%param1%'
		AND	cc.dateleft			>	'%param1%'
		AND	PSER.schoolid		IN	(%param3%)
		AND	sect.exclude_ada	=	0
		AND	bsi.ada_code		=	1
		AND	PSER.studentid		=	30245
		
	GROUP BY
		PSER.schoolid
		,	PSER.studentid
		,	PSER.grade_level
		,	PSER.entrydate
		,	PSER.exitdate
		,	p.abbreviation || '('||cy_d.letter||')'
		,	p.id
		,	cy_d.id
		,	bs.id
) cds

LEFT JOIN	attendance			att_cd							/* Join on attendance data on count day, identify pop-groups. */
	ON			att_cd.att_date		=	cds.count_date
	AND			att_cd.schoolid		=	cds.schoolid
	AND			att_cd.studentid	=	cds.studentid
	AND			att_cd.periodid		=	cds.periodid
LEFT JOIN	Attendance_Code		ac_cd
	ON			ac_cd.id			=	att_cd.Attendance_CodeID
LEFT JOIN
(
	SELECT
		acce.attendance_codeid
		,	ce.ce_code
	FROM		Att_Code_Code_Entity	acce
	INNER JOIN	Code_Entity				ce
			ON		ce.id				=	acce.Code_EntityID
	WHERE	ce.ce_code = 'Excused'
)	ac_ec
	ON			ac_ec.attendance_codeid	=	ac_cd.id

INNER JOIN	ca_d_rn				ca_d_rn							/* Join on calendar day records based on attendance entered on count day. */
		ON		ca_d_rn.schoolid			=	cds.schoolid
		AND		(	(ac_cd.Presence_Status_CD	=	'Present'
				AND	ca_d_rn.rn					>=	cds.count_rn
				AND	ca_d_rn.rn					<=	cds.count_rn + 10
				AND	ca_d_rn.bell_schedule_id	=	cds.bell_schedule_id
				AND	ca_d_rn.cycle_day_id		=	cds.cycle_day_id)
			OR		((ac_cd.Presence_Status_CD	!=	'Present' OR ac_cd.Presence_Status_CD IS NULL)
				AND ac_ec.ce_code				=	'Excused'
				AND	ca_d_rn.rn					>=	cds.count_rn
				AND	ca_d_rn.date_value			<=	TO_DATE('%param1%','MM/DD/YYYY') + 30
				AND	ca_d_rn.bell_schedule_id	=	cds.bell_schedule_id
				AND	ca_d_rn.cycle_day_id		=	cds.cycle_day_id)
			OR		((ac_cd.Presence_Status_CD	!=	'Present' OR ac_cd.Presence_Status_CD IS NULL)
				AND ac_ec.ce_code				IS NULL
				AND	ca_d_rn.rn					>=	cds.count_rn
				AND	ca_d_rn.rn					<=	cds.count_rn + 10
				AND	ca_d_rn.bell_schedule_id	=	cds.bell_schedule_id
				AND	ca_d_rn.cycle_day_id		=	cds.cycle_day_id)
				)

LEFT JOIN	attendance			att							/* Join attendance records on relevant calendar day records. */
	ON			att.att_date		=	ca_d_rn.date_value
	AND			att.schoolid		=	cds.schoolid
	AND			att.studentid		=	cds.studentid
	AND			att.periodid		=	cds.periodid
LEFT JOIN	Attendance_Code		ac
	ON			ac.id			=	att.Attendance_CodeID