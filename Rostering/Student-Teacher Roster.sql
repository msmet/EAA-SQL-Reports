SELECT
	t.dcid
	,	sch.abbreviation
	,	sch.name
	,	ter.id
	,	ter.abbreviation
	,	t.id
	,	t.teachernumber
	,	t.lastfirst
	,	t.SIF_StatePrid
	,	rd.name
	,	c.course_number
	,	c.course_name
	,	CASE	SMCTX.NCESsubjectArea
			WHEN	'00'	THEN		'State Approved CTE Course'
			WHEN	'01'	THEN		'English Language and Literature Secondary'
			WHEN	'02'	THEN		'Mathematics Secondary'
			WHEN	'03'	THEN		'Life and Physical Sciences Secondary'
			WHEN	'04'	THEN		'Social Sciences Secondary'
			WHEN	'05'	THEN		'Fine and Performing Arts Secondary'
			WHEN	'06'	THEN		'Foreign Language and Literature Secondary'
			WHEN	'07'	THEN		'Religious Education and Theology Secondary'
			WHEN	'08'	THEN		'Physical'|| CHR(44) || ' Health'|| CHR(44) || ' and Safety Education Secondary'
			WHEN	'09'	THEN		'Military Science Secondary'
			WHEN	'10'	THEN		'Computer and Information Sciences Secondary'
			WHEN	'11'	THEN		'Communication and Audio Video Technology Secondary'
			WHEN	'12'	THEN		'Business and Marketing Secondary'
			WHEN	'13'	THEN		'Manufacturing Secondary'
			WHEN	'14'	THEN		'Health Care Sciences Secondary'
			WHEN	'15'	THEN		'Public'|| CHR(44) || ' Protective'|| CHR(44) || ' and Government Services Secondary'
			WHEN	'16'	THEN		'Hospitality and Tourism Secondary'
			WHEN	'17'	THEN		'Architecture and Construction Secondary'
			WHEN	'18'	THEN		'Agriculture and Natural Resources Secondary'
			WHEN	'19'	THEN		'Human Services Secondary'
			WHEN	'20'	THEN		'Transportation'|| CHR(44) || ' Distribution'|| CHR(44) || ' and Logistics Secondary'
			WHEN	'21'	THEN		'Engineering and Technology Secondary'
			WHEN	'22'	THEN		'Miscellaneous Secondary'
			WHEN	'51'	THEN		'English Language and Literature prior to secondary'
			WHEN	'52'	THEN		'Mathematics prior to secondary'
			WHEN	'53'	THEN		'Life and Physical Sciences prior to secondary'
			WHEN	'54'	THEN		'Social Sciences and History prior to secondary'
			WHEN	'55'	THEN		'Fine and Performing Arts prior to secondary'
			WHEN	'56'	THEN		'Foreign Language and Literature prior to secondary'
			WHEN	'57'	THEN		'Religious Education and Theology prior to secondary'
			WHEN	'58'	THEN		'Physical'|| CHR(44) || ' Health'|| CHR(44) || ' and Safety Education prior to secondary'
			WHEN	'60'	THEN		'Computer and Information Sciences prior to secondary'
			WHEN	'61'	THEN		'Communication and Audio Video Technology prior to secondary'
			WHEN	'62'	THEN		'Business and Marketing prior to secondary'
			WHEN	'63'	THEN		'Manufacturing prior to secondary'
			WHEN	'64'	THEN		'Health Care Sciences prior to secondary'
			WHEN	'65'	THEN		'Public'|| CHR(44) || ' Protective'|| CHR(44) || ' and Government Services prior to secondary'
			WHEN	'66'	THEN		'Hospitality and Tourism prior to secondary'
			WHEN	'67'	THEN		'Architecture and Construction prior to secondary'
			WHEN	'68'	THEN		'Agriculture'|| CHR(44) || ' Food'|| CHR(44) || ' and Natural Resources prior to secondary'
			WHEN	'69'	THEN		'Human Services prior to secondary'
			WHEN	'70'	THEN		'Transportation'|| CHR(44) || ' Distribution'|| CHR(44) || ' and Logistics prior to secondary'
			WHEN	'71'	THEN		'Engineering and Technology prior to secondary'
			WHEN	'72'	THEN		'Miscellaneous prior to secondary'
			WHEN	'73'	THEN		'Nonsubject Specific prior to secondary'
			WHEN	NULL	THEN		'Not Defined'
			ELSE						'Unknown'
			END
	,	SMCTX.NCESsubjectArea || SMCTX.NCEScourseID
	,	nvl(SMCTX.NCESsubjectArea,'NULL')
	,	nvl(SMCTX.NCEScourseID,'NULL')
	,	sect.dcid
	,	sect.id
	,	sect.section_number
	,	s.dcid
	,	s.id
	,	s.student_number
	,	s.lastfirst
	,	PSER.grade_level
	,	TO_CHAR(PSER.entrydate,'MM/DD/YYYY')
	,	TO_CHAR(PSER.exitdate,'MM/DD/YYYY')
	,	TO_CHAR(cc.dateenrolled,'MM/DD/YYYY')
	,	TO_CHAR(cc.dateleft,'MM/DD/YYYY')
	,	TO_CHAR(ter.firstday,'MM/DD/YYYY')
	,	TO_CHAR(ter.lastday,'MM/DD/YYYY')
	,	TO_CHAR(st.start_date,'MM/DD/YYYY')
	,	TO_CHAR(st.end_date,'MM/DD/YYYY')
	,	TO_CHAR(GREATEST(PSER.entrydate, cc.dateenrolled, st.start_date),'MM/DD/YYYY')
	,	TO_CHAR(LEAST(PSER.exitdate - 1, cc.dateleft - 1, st.end_date),'MM/DD/YYYY')
	,	CASE GREATEST(PSER.entrydate, cc.dateenrolled, st.start_date)
			WHEN	PSER.entrydate THEN 'Sch. Entry Date'
			WHEN	cc.dateenrolled THEN 'CC Entry Date'
			WHEN	st.start_date THEN 'Tea Start Date'
			END
	,	CASE LEAST(PSER.exitdate - 1, cc.dateleft - 1, st.end_date)
			WHEN	PSER.exitdate - 1 THEN 'Sch. Exit Date'
			WHEN	cc.dateleft - 1 THEN 'CC Left Date'
			WHEN	st.end_date THEN 'Tea End Date'
			END
	,	COUNT(DISTINCT ca_d.date_value)
	,	CASE	WHEN	sect.ExcludeFromStoredGrades	= 1 THEN 'Exclude'
				WHEN	sect.ExcludeFromStoredGrades	= 2 THEN 'Include'
				WHEN	c.ExcludeFromStoredGrades		= 1 THEN 'Exclude'
				WHEN	c.ExcludeFromStoredGrades		= 0 THEN 'Include'
				ELSE	'Unknown'
			END
	,	SMCTX.virtualDelivery
	,	CASE WHEN (SUBSTR(c.course_number,3,2) = SMCTX.NCESsubjectArea) AND (SUBSTR(c.course_number,5,3) = SMCTX.NCEScourseID) THEN 'Valid course-SCED match' ELSE 'Potential course-SCED mistmatch' END

FROM		calendar_day		ca_d
INNER JOIN	schools				sch
	ON			sch.school_number		=	ca_d.schoolid
INNER JOIN	ps_enrollment_reg	PSER
	ON			PSER.schoolid			=	ca_d.schoolid
	AND			PSER.entrydate			<=	ca_d.date_value
	AND			PSER.exitdate			>	ca_d.date_value
	AND			PSER.grade_level		>=	%param4%
	AND		(	(PSER.track IS NULL)
		OR		(PSER.track = 'A'	AND		ca_d.A = 1)
		OR		(PSER.track = 'B'	AND		ca_d.B = 1)
		OR		(PSER.track = 'C'	AND		ca_d.C = 1)
		OR		(PSER.track = 'D'	AND		ca_d.D = 1)
		OR		(PSER.track = 'E'	AND		ca_d.E = 1)
		OR		(PSER.track = 'F'	AND		ca_d.F = 1))
INNER JOIN	students			s
		ON		s.id				=	PSER.studentid
INNER JOIN	bell_schedule		bs
		ON		bs.id				=	ca_d.bell_schedule_id
INNER JOIN	bell_schedule_items bsi
		ON		bsi.bell_schedule_id=	bs.id
INNER JOIN	cycle_day			cy_d
		ON		cy_d.id				=	ca_d.cycle_day_id
		AND		cy_d.schoolid		=	ca_d.schoolid
INNER JOIN	section_meeting		sm
		ON		sm.schoolid			=	ca_d.schoolid
		AND		sm.cycle_day_letter	=	cy_d.letter
		AND		sm.year_id			=	cy_d.year_id
INNER JOIN	period				p
		ON		p.schoolid			=	ca_d.schoolid
		AND		p.year_id			=	cy_d.year_id
		AND		p.period_number		=	sm.period_number
		AND		p.id				=	bsi.period_id
INNER JOIN	sections			sect
		ON		sect.id				=	sm.sectionid
LEFT JOIN	sectionteacher		st
	ON			st.sectionid		=	sect.id
	AND			st.start_date		<=	ca_d.date_value
	AND			st.end_date			>=	ca_d.date_value
LEFT JOIN	roledef				rd
	ON			rd.id				=	st.roleid
LEFT JOIN	teachers			t
	ON			t.id				=	st.teacherid
INNER JOIN	courses				c
		ON		c.course_number		=	sect.course_number
LEFT JOIN	S_MI_CRS_TSDL_X		SMCTX
		ON		smctx.coursesdcid	=	c.dcid
LEFT JOIN	terms				ter
		ON		ter.id				=	sect.termid
		AND		ter.schoolid		=	sect.schoolid
INNER JOIN	cc
		ON		cc.studentid		=	PSER.studentid
		AND		ABS(cc.sectionid)	=	sect.id
		AND		cc.schoolid			=	ca_d.schoolid
		AND		cc.dateenrolled		<=	ca_d.date_value
		AND		cc.dateleft			>	ca_d.date_value
LEFT JOIN	attendance			att
		ON		att.studentid		=	cc.studentid
		AND		att.att_date		=	ca_d.date_value
		AND		att.ccid			=	cc.id
		AND		att.periodid		=	p.id
LEFT JOIN	attendance_code		ac
		ON		ac.id				=	att.attendance_codeid
		AND		(ac.calculate_ada_yn	=	1
			OR	ac.att_code		=	'NCH')

WHERE	ca_d.date_value	>=	'%param1%'
	AND	ca_d.date_value	<=	'%param2%'
	AND	ca_d.insession	=	1
	AND ca_d.schoolid	IN (%param3%)
	AND	(ac.att_code		!=	'NCH'
		OR	ac.att_code		IS	NULL)

GROUP BY
	t.dcid
	,	sch.abbreviation
	,	sch.name
	,	ter.id
	,	ter.abbreviation
	,	t.id
	,	t.teachernumber
	,	t.lastfirst
	,	t.SIF_StatePrid
	,	rd.name
	,	c.course_number
	,	c.course_name
	,	SMCTX.coursetype
	,	SMCTX.NCEScourseID
	,	SMCTX.NCESsubjectArea
	,	SMCTX.virtualDelivery
	,	sect.dcid
	,	sect.id
	,	sect.section_number
	,	s.dcid
	,	s.id
	,	s.student_number
	,	s.lastfirst
	,	PSER.grade_level
	,	PSER.entrydate
	,	PSER.exitdate
	,	cc.dateenrolled
	,	cc.dateleft
	,	st.start_date
	,	st.end_date
	,	sect.ExcludeFromStoredGrades
	,	c.ExcludeFromStoredGrades
	,	ter.firstday
	,	ter.lastday