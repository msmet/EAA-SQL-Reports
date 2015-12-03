SELECT
	c.dcid
	,	'<a href=/admin/courses/edit.html?cn='||c.course_number||'&frn=002'||c.dcid||' target=_blank>Link</a>'
	,	c.id
	,	c.course_name
	,	c.course_number
	,	NVL(ps_customfields.getcf('Courses',c.id,'MI_Subject_Area_Code'),'NULL')
	,	NVL(ps_customfields.getcf('Courses',c.id,'MI_Course_ID'),'NULL')
	,	NVL(ps_customfields.getcf('Courses',c.id,'MI_Course_Type'),'NULL')
	,	NVL(ps_customfields.getcf('Courses',c.id,'MI_TSDL_Exclude'),0)
	,	NVL(ps_customfields.getcf('Courses',c.id,'MI_CRDC_Crs_Area'),0)
	,	NVL(ps_customfields.getcf('Courses',c.id,'MI_CRDC_AP'),0)
	,	NVL(ps_customfields.getcf('Courses',c.id,'MI_CRDC_IB'),0)
	,	COUNT(DISTINCT sect.dcid)
	,	MIN(st.grade_level)
	,	MAX(st.grade_level)

FROM		courses		c
INNER JOIN	sections	sect
	ON			sect.course_number		=	c.course_number
INNER JOIN	terms		ter
	ON			ter.id					=	sect.termid
	AND			ter.schoolid			=	sect.schoolid
INNER JOIN	cc
	ON			ABS(cc.sectionid)		=	sect.id
	AND			cc.dateleft				>=	cc.dateenrolled + 10
	AND			cc.dateenrolled			<=	'%param2%'
	AND			cc.dateleft				>	'%param1%'
LEFT JOIN	ps_enrollment_reg	st
	ON			st.studentid			=	cc.studentid
	AND			st.entrydate			<=	cc.dateenrolled
	AND			st.exitdate				>=	cc.dateleft

WHERE	ter.id		>=		2300
	AND	ter.id			<=		2306
	AND	ps_customfields.getcf('Sections',sect.id,'MI_TSDL_Exclude') IS NULL
	AND	sect.schoolid NOT IN (44541,777777,999999,6666666,666666,11111)

GROUP BY
	c.dcid
	,	c.id
	,	c.course_name
	,	c.course_number