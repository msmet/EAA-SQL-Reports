SELECT First_Name, Last_Name, Student_Number, to_char(DOB, 'MM/DD/YYYY'), '%param1%' as graduation_year  FROM Students WHERE enroll_status = 0 AND grade_level = '%param2%'
~[if.is.a.school] 
	AND	Schoolid = ~(curschoolid)
[/if]