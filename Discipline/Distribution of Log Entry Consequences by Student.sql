SELECT
	sch.name
	,	s.lastfirst
	,	MAX(PSER.grade_level)
	,	COUNT(DISTINCT l.dcid)																AS	total_count
	,	SUM(	CASE	WHEN	l.consequence	=	'AA'	THEN	1	ELSE	0	END)	AS	AA_count
	,	SUM(	CASE	WHEN	l.consequence	=	'AC'	THEN	1	ELSE	0	END)	AS	AC_count
	,	SUM(	CASE	WHEN	l.consequence	=	'BS'	THEN	1	ELSE	0	END)	AS	BS_count
	,	SUM(	CASE	WHEN	l.consequence	=	'CC'	THEN	1	ELSE	0	END)	AS	CC_count
	,	SUM(	CASE	WHEN	l.consequence	=	'DA'	THEN	1	ELSE	0	END)	AS	DA_count
	,	SUM(	CASE	WHEN	l.consequence	=	'DL'	THEN	1	ELSE	0	END)	AS	DL_count
	,	SUM(	CASE	WHEN	l.consequence	=	'DS'	THEN	1	ELSE	0	END)	AS	DS_count
	,	SUM(	CASE	WHEN	l.consequence	=	'INCL'	THEN	1	ELSE	0	END)	AS	INCL_count
	,	SUM(	CASE	WHEN	l.consequence	=	'ISI'	THEN	1	ELSE	0	END)	AS	ISI_count
	,	SUM(	CASE	WHEN	l.consequence	=	'ISS'	THEN	1	ELSE	0	END)	AS	ISS_count
	,	SUM(	CASE	WHEN	l.consequence	=	'ISSL'	THEN	1	ELSE	0	END)	AS	ISSL_count
	,	SUM(	CASE	WHEN	l.consequence	=	'LP'	THEN	1	ELSE	0	END)	AS	LP_count
	,	SUM(	CASE	WHEN	l.consequence	=	'MC'	THEN	1	ELSE	0	END)	AS	MC_count
	,	SUM(	CASE	WHEN	l.consequence	=	'MS'	THEN	1	ELSE	0	END)	AS	MS_count
	,	SUM(	CASE	WHEN	l.consequence	=	'O'		THEN	1	ELSE	0	END)	AS	O_count
	,	SUM(	CASE	WHEN	l.consequence	=	'OSS'	THEN	1	ELSE	0	END)	AS	OSS_count
	,	SUM(	CASE	WHEN	l.consequence	=	'OSSL'	THEN	1	ELSE	0	END)	AS	OSSL_count
	,	SUM(	CASE	WHEN	l.consequence	=	'PCA'	THEN	1	ELSE	0	END)	AS	PCA_count
	,	SUM(	CASE	WHEN	l.consequence	=	'PCT'	THEN	1	ELSE	0	END)	AS	PCT_count
	,	SUM(	CASE	WHEN	l.consequence	=	'R'		THEN	1	ELSE	0	END)	AS	R_count
	,	SUM(	CASE	WHEN	l.consequence	=	'RCTR'	THEN	1	ELSE	0	END)	AS	RCTR_count
	,	SUM(	CASE	WHEN	l.consequence	=	'SCP'	THEN	1	ELSE	0	END)	AS	SCP_count
	,	SUM(	CASE	WHEN	l.consequence	=	'SS'	THEN	1	ELSE	0	END)	AS	SS_count
	,	SUM(	CASE	WHEN	l.consequence	=	'T'		THEN	1	ELSE	0	END)	AS	T_count
	,	SUM(	CASE	WHEN	l.consequence	=	'TAC'	THEN	1	ELSE	0	END)	AS	TAC_count
	,	SUM(	CASE	WHEN	l.consequence	=	'W1'	THEN	1	ELSE	0	END)	AS	W1_count
	,	SUM(	CASE	WHEN	l.consequence	=	'W2'	THEN	1	ELSE	0	END)	AS	W2_count
	,	SUM(	CASE	WHEN	l.consequence	=	'WAP'	THEN	1	ELSE	0	END)	AS	WAP_count
	,	SUM(	CASE	WHEN	l.consequence	=	'WAS'	THEN	1	ELSE	0	END)	AS	WAS_count
	,	SUM(	CASE	WHEN	l.consequence	IS	NULL	THEN	1	ELSE	0	END)	AS	NULL_count
	,	SUM(	CASE	WHEN	NVL(l.consequence,0)	NOT IN	
													('AA','AC','BS','CC','DA','DL','DS',
													'INCL','ISI','ISS','ISSL','LP','MC',
													'MS','O','OSS','OSSL','PCA','PCT',
													'R','RCTR','SCP','SS','T','TAC','W1',
													'W2','WAP','WAS',0)
															THEN	1	ELSE	0	END)	AS	other_count

FROM		students			s
INNER JOIN	ps_enrollment_reg	PSER
		ON		PSER.studentid		=	s.id
		AND		PSER.entrydate		<=	'%param2%'
		AND		PSER.exitdate		>	'%param2%'
LEFT JOIN	schools			sch
		ON		sch.school_number	=	PSER.schoolid
LEFT JOIN	log				l
		ON		l.studentid			=	PSER.studentid
		AND		l.schoolid			=	PSER.schoolid

~[if#cursel.%param3%=Yes]
	INNER JOIN ~[temp.table.current.selection:students] stusel ON stusel.dcid = s.dcid
[/if#cursel]


WHERE	((l.Discipline_IncidentDate	>=	'%param1%'
	AND	l.Discipline_IncidentDate	<=	'%param2%')
	OR	(l.entry_date			>=	'%param1%'
	AND	l.entry_date			<=	'%param2%'
	AND	l.Discipline_IncidentDate	IS	NULL))
~[if.is.a.school]
	AND	PSER.schoolid				=	~(curschoolid)
[/if]

GROUP BY
		sch.name
	,	s.lastfirst