SELECT
	s.dcid
	,	sch.name
	,	sch.abbreviation
	,	sch.school_number
	,	s.student_number
	,	s.id
	,	s.lastfirst
	,	s.grade_level
	,	CAST(	SUM(CASE sg.credit_type WHEN 'ELA1' THEN sg.EarnedCrHrs ELSE NULL END)/1	AS	DECIMAL (4,2))
	,	CAST(	SUM(CASE sg.credit_type WHEN 'ELA2' THEN sg.EarnedCrHrs ELSE NULL END)/1	AS	DECIMAL (4,2))
	,	CAST(	SUM(CASE sg.credit_type WHEN 'ELA3' THEN sg.EarnedCrHrs ELSE NULL END)/1	AS	DECIMAL (4,2))
	,	CAST(	SUM(CASE sg.credit_type WHEN 'ELA4' THEN sg.EarnedCrHrs ELSE NULL END)/1	AS	DECIMAL (4,2))
	,	CAST(	SUM(CASE sg.credit_type WHEN 'ALG1' THEN sg.EarnedCrHrs ELSE NULL END)/1	AS	DECIMAL (4,2))
	,	CAST(	SUM(CASE sg.credit_type WHEN 'ALG2' THEN sg.EarnedCrHrs ELSE NULL END)/1	AS	DECIMAL (4,2))
	,	CAST(	SUM(CASE sg.credit_type WHEN 'GEOM' THEN sg.EarnedCrHrs ELSE NULL END)/1	AS	DECIMAL (4,2))
	,	CAST(	(SUM(CASE sg.credit_type WHEN 'MTH' THEN sg.EarnedCrHrs ELSE NULL END)
				+	NVL(CASE WHEN (SUM(CASE sg.credit_type WHEN 'ALG1' THEN sg.EarnedCrHrs ELSE NULL END)) > 1 THEN (SUM(CASE sg.credit_type WHEN 'ALG1' THEN sg.EarnedCrHrs ELSE NULL END) - 1) ELSE NULL END,0)
				+	NVL(CASE WHEN (SUM(CASE sg.credit_type WHEN 'ALG2' THEN sg.EarnedCrHrs ELSE NULL END)) > 1 THEN (SUM(CASE sg.credit_type WHEN 'ALG2' THEN sg.EarnedCrHrs ELSE NULL END) - 1) ELSE NULL END,0)
				+	NVL(CASE WHEN (SUM(CASE sg.credit_type WHEN 'GEOM' THEN sg.EarnedCrHrs ELSE NULL END)) > 1 THEN (SUM(CASE sg.credit_type WHEN 'GEOM' THEN sg.EarnedCrHrs ELSE NULL END) - 1) ELSE NULL END,0)
				)/1	AS	DECIMAL (4,2))
	,	CAST(	SUM(CASE sg.credit_type WHEN 'BIO' THEN sg.EarnedCrHrs ELSE NULL END)/1	AS	DECIMAL (4,2))
	,	CAST(	SUM(CASE WHEN sg.credit_type IN ('PHYS','CHEM','PHCM') THEN sg.EarnedCrHrs ELSE NULL END)/1	AS	DECIMAL (4,2))
	,	CAST(	(SUM(CASE sg.credit_type WHEN 'SCI' THEN sg.EarnedCrHrs ELSE NULL END)
				+	NVL(CASE WHEN (SUM(CASE sg.credit_type WHEN 'BIO' THEN sg.EarnedCrHrs ELSE NULL END)) > 1 THEN (SUM(CASE sg.credit_type WHEN 'BIO' THEN sg.EarnedCrHrs ELSE NULL END) - 1) ELSE NULL END,0)
				+	NVL(CASE WHEN (SUM(CASE WHEN sg.credit_type IN ('PHYS','CHEM','PHCM') THEN sg.EarnedCrHrs ELSE NULL END)) > 1 THEN (SUM(CASE WHEN sg.credit_type IN ('PHYS','CHEM','PHCM') THEN sg.EarnedCrHrs ELSE NULL END) - 1) ELSE NULL END,0)
				)/1	AS	DECIMAL (4,2))
	,	CAST(	SUM(CASE sg.credit_type WHEN 'CIV' THEN sg.EarnedCrHrs ELSE NULL END)/0.5	AS	DECIMAL (4,2))
	,	CAST(	SUM(CASE sg.credit_type WHEN 'ECO' THEN sg.EarnedCrHrs ELSE NULL END)/0.5	AS	DECIMAL (4,2))
	,	CAST(	SUM(CASE sg.credit_type WHEN 'USH' THEN sg.EarnedCrHrs ELSE NULL END)/1	AS	DECIMAL (4,2))
	,	CAST(	SUM(CASE sg.credit_type WHEN 'WHG' THEN sg.EarnedCrHrs ELSE NULL END)/1	AS	DECIMAL (4,2))
	,	CAST(	SUM(CASE sg.credit_type WHEN 'PE' THEN sg.EarnedCrHrs ELSE NULL END)/1	AS	DECIMAL (4,2))
	,	CAST(	SUM(CASE sg.credit_type WHEN 'FL' THEN sg.EarnedCrHrs ELSE NULL END)/1	AS	DECIMAL (4,2))
	,	CAST(	SUM(CASE sg.credit_type WHEN 'VPA' THEN sg.EarnedCrHrs ELSE NULL END)/1	AS	DECIMAL (4,2))
	,	CAST(	SUM(sg.EarnedCrHrs)/23	AS	DECIMAL (4,2))
	,	CASE
			WHEN (
				SUM(CASE sg.credit_type WHEN 'ELA1' THEN sg.EarnedCrHrs ELSE NULL END)/1 < 1
				 OR	SUM(CASE sg.credit_type WHEN 'ELA2' THEN sg.EarnedCrHrs ELSE NULL END)/1 < 1
				 OR	SUM(CASE sg.credit_type WHEN 'ELA3' THEN sg.EarnedCrHrs ELSE NULL END)/1 < 1
				 OR	SUM(CASE sg.credit_type WHEN 'ELA4' THEN sg.EarnedCrHrs ELSE NULL END)/1 < 1
				 OR	SUM(CASE sg.credit_type WHEN 'ALG1' THEN sg.EarnedCrHrs ELSE NULL END)/1 < 1
				 OR	SUM(CASE sg.credit_type WHEN 'ALG2' THEN sg.EarnedCrHrs ELSE NULL END)/1 < 1
				 OR	SUM(CASE sg.credit_type WHEN 'GEOM' THEN sg.EarnedCrHrs ELSE NULL END)/1 < 1
				 OR	(SUM(CASE sg.credit_type WHEN 'MTH' THEN sg.EarnedCrHrs ELSE NULL END)
					+	NVL(CASE WHEN (SUM(CASE sg.credit_type WHEN 'ALG1' THEN sg.EarnedCrHrs ELSE NULL END)) > 1 THEN (SUM(CASE sg.credit_type WHEN 'ALG1' THEN sg.EarnedCrHrs ELSE NULL END) - 1) ELSE NULL END,0)
					+	NVL(CASE WHEN (SUM(CASE sg.credit_type WHEN 'ALG2' THEN sg.EarnedCrHrs ELSE NULL END)) > 1 THEN (SUM(CASE sg.credit_type WHEN 'ALG2' THEN sg.EarnedCrHrs ELSE NULL END) - 1) ELSE NULL END,0)
					+	NVL(CASE WHEN (SUM(CASE sg.credit_type WHEN 'GEOM' THEN sg.EarnedCrHrs ELSE NULL END)) > 1 THEN (SUM(CASE sg.credit_type WHEN 'GEOM' THEN sg.EarnedCrHrs ELSE NULL END) - 1) ELSE NULL END,0)
					)/1 < 1
				 OR	SUM(CASE sg.credit_type WHEN 'BIO' THEN sg.EarnedCrHrs ELSE NULL END)/1 < 1
				 OR	SUM(CASE WHEN sg.credit_type IN ('PHYS','CHEM','PHCM') THEN sg.EarnedCrHrs ELSE NULL END)/1 < 1
				 OR	(SUM(CASE sg.credit_type WHEN 'SCI' THEN sg.EarnedCrHrs ELSE NULL END)
					+	NVL(CASE WHEN (SUM(CASE sg.credit_type WHEN 'BIO' THEN sg.EarnedCrHrs ELSE NULL END)) > 1 THEN (SUM(CASE sg.credit_type WHEN 'BIO' THEN sg.EarnedCrHrs ELSE NULL END) - 1) ELSE NULL END,0)
					+	NVL(CASE WHEN (SUM(CASE WHEN sg.credit_type IN ('PHYS','CHEM','PHCM') THEN sg.EarnedCrHrs ELSE NULL END)) > 1 THEN (SUM(CASE WHEN sg.credit_type IN ('PHYS','CHEM','PHCM') THEN sg.EarnedCrHrs ELSE NULL END) - 1) ELSE NULL END,0)
					)/1 < 1
				 OR	SUM(CASE sg.credit_type WHEN 'CIV' THEN sg.EarnedCrHrs ELSE NULL END)/0.5 < 1
				 OR	SUM(CASE sg.credit_type WHEN 'ECO' THEN sg.EarnedCrHrs ELSE NULL END)/0.5 < 1
				 OR	SUM(CASE sg.credit_type WHEN 'USH' THEN sg.EarnedCrHrs ELSE NULL END)/1 < 1
				 OR	SUM(CASE sg.credit_type WHEN 'WHG' THEN sg.EarnedCrHrs ELSE NULL END)/1 < 1
				 OR	SUM(CASE sg.credit_type WHEN 'PE' THEN sg.EarnedCrHrs ELSE NULL END)/1 < 1
				 OR	SUM(CASE sg.credit_type WHEN 'VPA' THEN sg.EarnedCrHrs ELSE NULL END)/1 < 1
				 OR	SUM(sg.EarnedCrHrs)/23 < 1)
				THEN 'No' ELSE 'Yes' END
	,	SUM(CASE sg.credit_type WHEN 'ELA1' THEN sg.EarnedCrHrs ELSE NULL END)
	,	SUM(CASE sg.credit_type WHEN 'ELA2' THEN sg.EarnedCrHrs ELSE NULL END)
	,	SUM(CASE sg.credit_type WHEN 'ELA3' THEN sg.EarnedCrHrs ELSE NULL END)
	,	SUM(CASE sg.credit_type WHEN 'ELA4' THEN sg.EarnedCrHrs ELSE NULL END)
	,	SUM(CASE sg.credit_type WHEN 'ALG1' THEN sg.EarnedCrHrs ELSE NULL END)
	,	SUM(CASE sg.credit_type WHEN 'ALG2' THEN sg.EarnedCrHrs ELSE NULL END)
	,	SUM(CASE sg.credit_type WHEN 'GEOM' THEN sg.EarnedCrHrs ELSE NULL END)
	,	(SUM(CASE sg.credit_type WHEN 'MTH' THEN sg.EarnedCrHrs ELSE NULL END)
			+	NVL(CASE WHEN (SUM(CASE sg.credit_type WHEN 'ALG1' THEN sg.EarnedCrHrs ELSE NULL END)) > 1 THEN (SUM(CASE sg.credit_type WHEN 'ALG1' THEN sg.EarnedCrHrs ELSE NULL END) - 1) ELSE NULL END,0)
			+	NVL(CASE WHEN (SUM(CASE sg.credit_type WHEN 'ALG2' THEN sg.EarnedCrHrs ELSE NULL END)) > 1 THEN (SUM(CASE sg.credit_type WHEN 'ALG2' THEN sg.EarnedCrHrs ELSE NULL END) - 1) ELSE NULL END,0)
			+	NVL(CASE WHEN (SUM(CASE sg.credit_type WHEN 'GEOM' THEN sg.EarnedCrHrs ELSE NULL END)) > 1 THEN (SUM(CASE sg.credit_type WHEN 'GEOM' THEN sg.EarnedCrHrs ELSE NULL END) - 1) ELSE NULL END,0))
	,	SUM(CASE sg.credit_type WHEN 'BIO' THEN sg.EarnedCrHrs ELSE NULL END)
	,	SUM(CASE WHEN sg.credit_type IN ('PHYS','CHEM','PHCM') THEN sg.EarnedCrHrs ELSE NULL END)
	,	(SUM(CASE sg.credit_type WHEN 'SCI' THEN sg.EarnedCrHrs ELSE NULL END)
				+	NVL(CASE WHEN (SUM(CASE sg.credit_type WHEN 'BIO' THEN sg.EarnedCrHrs ELSE NULL END)) > 1 THEN (SUM(CASE sg.credit_type WHEN 'BIO' THEN sg.EarnedCrHrs ELSE NULL END) - 1) ELSE NULL END,0)
				+	NVL(CASE WHEN (SUM(CASE WHEN sg.credit_type IN ('PHYS','CHEM','PHCM') THEN sg.EarnedCrHrs ELSE NULL END)) > 1 THEN (SUM(CASE WHEN sg.credit_type IN ('PHYS','CHEM','PHCM') THEN sg.EarnedCrHrs ELSE NULL END) - 1) ELSE NULL END,0))
	,	SUM(CASE sg.credit_type WHEN 'CIV' THEN sg.EarnedCrHrs ELSE NULL END)
	,	SUM(CASE sg.credit_type WHEN 'ECO' THEN sg.EarnedCrHrs ELSE NULL END)
	,	SUM(CASE sg.credit_type WHEN 'USH' THEN sg.EarnedCrHrs ELSE NULL END)
	,	SUM(CASE sg.credit_type WHEN 'WHG' THEN sg.EarnedCrHrs ELSE NULL END)
	,	SUM(CASE sg.credit_type WHEN 'PE' THEN sg.EarnedCrHrs ELSE NULL END)
	,	SUM(CASE sg.credit_type WHEN 'FL' THEN sg.EarnedCrHrs ELSE NULL END)
	,	SUM(CASE sg.credit_type WHEN 'VPA' THEN sg.EarnedCrHrs ELSE NULL END)
	,	SUM(sg.EarnedCrHrs)

FROM		students	s
INNER JOIN	~[temp.table.current.selection:students] stusel ON stusel.dcid = s.dcid
INNER JOIN	schools		sch
	ON			sch.school_number		=	s.schoolid
LEFT JOIN	storedgrades	sg
	ON			sg.studentid			=	s.id
	
GROUP BY
	s.dcid
	,	sch.name
	,	sch.abbreviation
	,	sch.school_number
	,	s.student_number
	,	s.id
	,	s.lastfirst
	,	s.grade_level