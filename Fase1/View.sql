create view Regists_Grades
as
	select a.idSchoolStudent as ss, b.idStudent, b.idSchool, a.idDiscipline as discipline, c.grade1, c.grade2, 
			c.grade3, b.schoolYear
	from ClosedRegistrations a 
	join SchoolStudent b on a.idSchoolStudent = b.id
	join ClosedGrades c on a.id = c.registid 
go