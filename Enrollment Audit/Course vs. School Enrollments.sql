SELECT
	cc.dcid
	,	cc.id
	,	'<a href=/admin/students/editcc.html?frn=004'||to_char(cc.dcid)||CHR(38)||'breadcrumb=true target=_blank>Edit CC</a>'
	,	CASE 
			WHEN ps_customfields.getcf('CC',cc.id,'MI_TSDL_Exclude') = 1 THEN 'Exclude'
			ELSE 'Include'
			END
	,	s.dcid
	,	s.id
	,	'<a href=/admin/students/home.html?frn=001'||to_char(s.dcid)||' target=_blank>'||s.lastfirst||'</a>'
	,	s.enroll_status
	,	s.schoolid
	,	TO_CHAR(TO_DATE(s.entrydate),'MM/DD/YYYY')
	,	TO_CHAR(TO_DATE(s.exitdate),'MM/DD/YYYY')
	,	cc.schoolid
	,	cc.dateleft	-	cc.dateenrolled
	,	TO_CHAR(TO_DATE(cc.dateenrolled),'MM/DD/YYYY')
	,	TO_CHAR(TO_DATE(cc.dateleft),'MM/DD/YYYY')
	,	NVL(TO_CHAR(TO_DATE((SELECT MIN(att.att_date) FROM attendance att WHERE att.ccid = cc.id)),'MM/DD/YYYY'),'None')
	,	NVL(TO_CHAR(TO_DATE((SELECT MAX(att.att_date) FROM attendance att WHERE att.ccid = cc.id)),'MM/DD/YYYY'),'None')
	,	NVL(TO_CHAR(TO_DATE((SELECT MIN(att.att_date) FROM attendance att INNER JOIN attendance_code ac ON ac.id = att.attendance_codeid WHERE att.ccid = cc.id AND ac.presence_status_cd='Present' AND ac.att_code IS NOT NULL)),'MM/DD/YYYY'),'None')
	,	NVL(TO_CHAR(TO_DATE((SELECT MAX(att.att_date) FROM attendance att INNER JOIN attendance_code ac ON ac.id = att.attendance_codeid WHERE att.ccid = cc.id AND ac.presence_status_cd='Present' AND ac.att_code IS NOT NULL)),'MM/DD/YYYY'),'None')
	,	NVL(LISTAGG(TO_CHAR(TO_DATE(pser2.entrydate),'MM/DD/YYYY')||'_'||TO_CHAR(TO_DATE(pser2.exitdate),'MM/DD/YYYY'), '<br />') WITHIN GROUP (ORDER BY pser2.entrydate, pser2.exitdate),'None')
	,	NVL((SELECT LISTAGG(pser3.schoolid||'_'||TO_CHAR(TO_DATE(pser3.entrydate),'MM/DD/YYYY')||'_'||TO_CHAR(TO_DATE(pser3.exitdate),'MM/DD/YYYY'), '<br />') WITHIN GROUP (ORDER BY pser3.entrydate, pser3.exitdate) FROM PS_ENROLLMENT_REG pser3 WHERE pser3.studentid = cc.studentid AND pser3.schoolid != cc.schoolid AND pser3.exitdate >= cc.dateenrolled AND pser3.entrydate <= cc.dateleft),'None')
	,	CASE
			WHEN	cc.dateenrolled	=	cc.dateleft	THEN	1
			WHEN	cc.dateenrolled	>	cc.dateleft	THEN	2
			ELSE											0
			END	AS	cat
	,	(SELECT COUNT(att.dcid) FROM attendance att WHERE att.ccid = cc.id)
	,	(SELECT COUNT(att.dcid) FROM attendance att INNER JOIN attendance_code ac ON ac.id = att.attendance_codeid WHERE att.ccid = cc.id AND ac.presence_status_cd='Present')
	,	(SELECT COUNT(sg.dcid) FROM storedgrades sg WHERE sg.studentid = cc.studentid AND sg.sectionid = ABS(cc.sectionid))
	,	(SELECT COUNT(ccb.dcid) FROM cc ccb WHERE ccb.studentid = cc.studentid AND ABS(ccb.sectionid) = ABS(cc.sectionid) AND ccb.dateleft > cc.dateleft AND ccb.dcid <> cc.dcid)
	,	NVL((SELECT LISTAGG(TO_CHAR(TO_DATE(ccb.dateenrolled),'MM/DD/YYYY')||'-'||TO_CHAR(TO_DATE(ccb.dateleft),'MM/DD/YYYY'), '<br />') WITHIN GROUP (ORDER BY ccb.dateenrolled, ccb.dateleft) FROM cc ccb WHERE ccb.studentid = cc.studentid AND ABS(ccb.sectionid) = ABS(cc.sectionid) AND ccb.dateleft > cc.dateleft AND ccb.dcid <> cc.dcid),'None')
	,	NVL((SELECT MAX (NVL(pgfg.percent,0)) FROM pgfinalgrades pgfg WHERE pgfg.studentid = cc.studentid AND pgfg.sectionid = ABS(cc.sectionid)),0)
	,	'<a href=/admin/tech/usm/home.html'||CHR(63)||'ac=usm'||CHR(38)||'filenum=157'||CHR(38)||'fieldnum_1=7'||CHR(38)||'comparator1='||CHR(37)||'3D'||CHR(38)||'value='||cc.id||CHR(38)||'search=submit target=_blank>Att. Link</a>'||'<br />'||
			LISTAGG('<a href=/admin/tech/usm/home.html'||CHR(63)||'ac=usm'||CHR(38)||'filenum=157'||CHR(38)||'fieldnum_1=7'||CHR(38)||'comparator1='||CHR(37)||'3D'||CHR(38)||'value='||cc.id||CHR(38)||'fieldnum_2=18'||CHR(38)||'comparator2='||CHR(37)||'3C'||CHR(38)||'value='||TO_CHAR(TO_DATE(pser2.entrydate),'MM/DD/YYYY')||CHR(38)||'search=submit target=_blank>Att.Link_(Pre)</a>', '<br />') WITHIN GROUP (ORDER BY pser2.entrydate, pser2.exitdate)||'<br />'||
			LISTAGG('<a href=/admin/tech/usm/home.html'||CHR(63)||'ac=usm'||CHR(38)||'filenum=157'||CHR(38)||'fieldnum_1=7'||CHR(38)||'comparator1='||CHR(37)||'3D'||CHR(38)||'value='||cc.id||CHR(38)||'fieldnum_2=18'||CHR(38)||'comparator2='||CHR(37)||'3E'||CHR(37)||'3D'||CHR(38)||'value='||TO_CHAR(TO_DATE(pser2.exitdate),'MM/DD/YYYY')||CHR(38)||'search=submit target=_blank>Att.Link_(Post)</a>', '<br />') WITHIN GROUP (ORDER BY pser2.entrydate, pser2.exitdate)
	,	'<a href=/admin/tech/usm/home.html'||CHR(63)||'filenum=31'||CHR(38)||'fieldnum_1=1'||CHR(38)||'comparator1=%3D'||CHR(38)||'value='||cc.studentid||CHR(38)||'fieldnum_2=2'||CHR(38)||'comparator2=%3D'||CHR(38)||'value='||ABS(cc.sectionid)||CHR(38)||'ac=usm'||CHR(38)||'search=submit target=_blank>SG Link</a>'||'<br />'||
			(SELECT LISTAGG('<a href=/admin/tech/usm/home.html?mcr=031'||to_char(sg.dcid)||' target=_blank>'||sg.storecode||'_('||sg.percent||')</a>','<br />') WITHIN GROUP (ORDER BY sg.storecode, sg.percent) FROM storedgrades sg WHERE sg.studentid = cc.studentid AND sg.sectionid = ABS(cc.sectionid))
	,	'<a href=/admin/tech/usm/home.html'||CHR(63)||'filenum=95'||CHR(38)||'fieldnum_1=3'||CHR(38)||'comparator1=%3D'||CHR(38)||'value='||cc.studentid||CHR(38)||'fieldnum_2=2'||CHR(38)||'comparator2=%3D'||CHR(38)||'value='||ABS(cc.sectionid)||CHR(38)||'ac=usm'||CHR(38)||'search=submit target=_blank>PGFG Link</a>'

FROM		cc
LEFT JOIN	terms					t
	ON			t.id				=	ABS(cc.termid)
	AND			t.schoolid			=	cc.schoolid
LEFT JOIN	PS_ENROLLMENT_REG	pser
	ON			pser.studentid			=	cc.studentid
	AND			pser.schoolid			=	cc.schoolid
	AND			pser.exitdate			>=	cc.dateleft
	AND			pser.entrydate			<=	cc.dateenrolled
LEFT JOIN	PS_ENROLLMENT_REG	pser2
	ON			pser2.studentid			=	cc.studentid
	AND			pser2.schoolid			=	cc.schoolid
	AND			pser2.exitdate			>=	cc.dateenrolled
	AND			pser2.entrydate			<=	cc.dateleft
LEFT JOIN	students			s
	ON			s.id					=	cc.studentid

~[if#cursel.%param3%=Yes]
	INNER JOIN		~[temp.table.current.selection:students]	stusel
			ON			stusel.dcid				=	s.dcid
[/if#cursel]

WHERE	pser.studentid		IS NULL
	AND	t.yearid						=	%param1%
	AND	cc.schoolid						IN	(%param2%)

GROUP BY
	cc.dcid
	,	cc.id
	,	s.dcid
	,	s.id
	,	s.dcid
	,	s.lastfirst
	,	s.enroll_status
	,	s.schoolid
	,	s.entrydate
	,	s.exitdate
	,	cc.schoolid
	,	cc.dateleft
	,	cc.dateenrolled
	,	cc.sectionid
	,	cc.studentid