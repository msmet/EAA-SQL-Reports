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
	sch.name
	,	cds.sectionid
	,	TO_CHAR(cds.entrydate,'MM/DD/YYYY') AS entDate
	,	TO_CHAR(cds.exitdate,'MM/DD/YYYY')	AS	exDate
	,	cds.teacher_name
	,	cds.course_name
	,	cds.expression
	,	s.student_number
	,	s.lastfirst
	,	cds.grade_level
	,	TO_CHAR(MIN(cds.count_date),'MM/DD/YYYY')
	,	CASE
			WHEN	MIN(CASE WHEN ac.Presence_Status_CD = 'Present' THEN att.att_date ELSE NULL END ) = MIN(cds.count_date)
					THEN	'Present'
			WHEN	MIN(CASE WHEN (ac_cd.Presence_Status_CD	!= 'Present' OR ac_cd.Presence_Status_CD IS NULL) AND ac_ec.ce_code = 'Excused'  THEN att.att_date ELSE NULL END ) = MIN(cds.count_date)
					THEN	'Excused'
			WHEN	MIN(CASE WHEN (ac_cd.Presence_Status_CD	!= 'Present' OR ac_cd.Presence_Status_CD IS NULL) AND ac_ec.ce_code IS NULL THEN att.att_date ELSE NULL END ) = MIN(cds.count_date)
					THEN	'Unexcused'
			ELSE	'Unknown'
		END AS attCat
	,	ac_cd.att_code
	,	LISTAGG ( CASE WHEN att.att_date = '10/8/2015' THEN ac.att_code ELSE NULL END) WITHIN GROUP (ORDER BY cds.count_rn)
	,	LISTAGG ( CASE WHEN att.att_date = '10/9/2015' THEN ac.att_code ELSE NULL END) WITHIN GROUP (ORDER BY cds.count_rn)
	,	LISTAGG ( CASE WHEN att.att_date = '10/12/2015' THEN ac.att_code ELSE NULL END) WITHIN GROUP (ORDER BY cds.count_rn)
	,	LISTAGG ( CASE WHEN att.att_date = '10/13/2015' THEN ac.att_code ELSE NULL END) WITHIN GROUP (ORDER BY cds.count_rn)
	,	LISTAGG ( CASE WHEN att.att_date = '10/14/2015' THEN ac.att_code ELSE NULL END) WITHIN GROUP (ORDER BY cds.count_rn)
	,	LISTAGG ( CASE WHEN att.att_date = '10/15/2015' THEN ac.att_code ELSE NULL END) WITHIN GROUP (ORDER BY cds.count_rn)
	,	LISTAGG ( CASE WHEN att.att_date = '10/16/2015' THEN ac.att_code ELSE NULL END) WITHIN GROUP (ORDER BY cds.count_rn)
	,	LISTAGG ( CASE WHEN att.att_date = '10/19/2015' THEN ac.att_code ELSE NULL END) WITHIN GROUP (ORDER BY cds.count_rn)
	,	LISTAGG ( CASE WHEN att.att_date = '10/20/2015' THEN ac.att_code ELSE NULL END) WITHIN GROUP (ORDER BY cds.count_rn)
	,	LISTAGG ( CASE WHEN att.att_date = '10/21/2015' THEN ac.att_code ELSE NULL END) WITHIN GROUP (ORDER BY cds.count_rn)
	,	TO_CHAR(MIN(CASE WHEN ac.Presence_Status_CD = 'Present' THEN att.att_date ELSE NULL END ),'MM/DD/YYYY') AS fdp

FROM														/* Identify each section_meeting record based on students active on Count Day. */
(
	SELECT
		PSER.schoolid
		,	PSER.studentid
		,	PSER.grade_level
		,	PSER.entrydate
		,	PSER.exitdate
		,	sect.id AS sectionid
		,	p.abbreviation || '('||cy_d.letter||')' AS expression
		,	p.id		AS	periodid
		,	cy_d.id		AS	cycle_day_id
		,	bs.id		AS	bell_schedule_id
		,	t.lastfirst	AS	teacher_name
		,	c.course_name
		,	c.course_number
		,	NVL(MIN(CASE WHEN ca_d_rn.date_value >= '%param1%' THEN ca_d_rn.date_value ELSE NULL END),'12/31/2099') AS count_date
		,	NVL(MIN(CASE WHEN ca_d_rn.date_value >= '%param1%' THEN ca_d_rn.rn ELSE NULL END),99999) AS count_rn

	FROM		ps_enrollment_reg		PSER
	
	INNER JOIN	students				s
			ON		s.id					=	PSER.studentid
	~[if#cursel.%param5%=Yes]
		INNER JOIN		~[temp.table.current.selection:students] stusel
			ON			s.dcid					=	stusel.dcid
	[/if#cursel]
	
	INNER JOIN	cc
			ON		cc.studentid			=	PSER.studentid
			AND		cc.schoolid				=	PSER.schoolid
			AND		cc.dateenrolled			<	PSER.exitdate
			AND		cc.dateleft				>	PSER.entrydate
	INNER JOIN	sections				sect
			ON		sect.id					=	ABS(cc.sectionid)
	INNER JOIN	teachers				t
			ON		t.id					=	sect.teacher
	INNER JOIN	courses				c
			ON		c.course_number			=	sect.course_number
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
		AND	ca_d_rn.date_value	<=	to_date('%param1%','MM/DD/YYYY') + 13
		AND	PSER.schoolid		IN	(%param3%)
		AND	PSER.grade_level	>=	'%param4%'
		AND	sect.exclude_ada	=	0
		AND	bsi.ada_code		=	1
		
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
		,	t.lastfirst
		,	c.course_name
		,	c.course_number
		,	sect.id
) cds

INNER JOIN	students			s
	ON			s.id				=	cds.studentid
INNER JOIN	schools				sch
	ON			sch.school_number	=	cds.schoolid

LEFT JOIN	attendance			att_cd							/* Join on attendance data on count day, identify pop-groups. */
	ON			att_cd.att_date		=	cds.count_date
	AND			att_cd.schoolid		=	cds.schoolid
	AND			att_cd.studentid	=	cds.studentid
	AND			att_cd.periodid		=	cds.periodid
LEFT JOIN	Attendance_Code		ac_cd
	ON			ac_cd.id			=	att_cd.Attendance_CodeID
	AND			ac_cd.Calculate_ADA_YN = 1
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
	AND			ac.Calculate_ADA_YN = 1
	
GROUP BY
	cds.schoolid
	,	sch.name
	,	cds.sectionid
	,	cds.studentid
	,	s.student_number
	,	s.lastfirst
	,	cds.grade_level
	,	cds.entrydate
	,	cds.exitdate
	,	cds.expression
	,	cds.teacher_name
	,	cds.course_name
	,	cds.course_number
	,	ac_cd.att_code