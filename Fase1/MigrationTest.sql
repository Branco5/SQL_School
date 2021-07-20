

--Teste média de notas no ano letivo por escola:
select year, school, avg((P1+P2+P3) / 3.0) from OldData.dbo.Student group by school, year order by year, school

select b.name, a.schoolYear, avg((grade1+grade2+grade3)/3.0) from Projeto.dbo.SchoolStudent a
join school b on b.id = a.idSchool
join ClosedRegistrations c on c.idSchoolStudent = a.id 
join ClosedGrades d on d.registid = c.id
group by b.name, a.schoolYear order by a.schoolYear, b.name

--Teste média de notas por ano letivo e período letivo por escola:
select year, avg(P1/1.0), avg(P2/1.0), avg(P3/1.0) from OldData.dbo.Student group by year order by year

select a.schoolYear, avg(grade1/1.0), avg(grade2/1.0), avg(grade3/1.0)
from Projeto.dbo.SchoolStudent a
join school b on b.id = a.idSchool
join ClosedRegistrations c on c.idSchoolStudent = a.id 
join ClosedGrades d on d.registid = c.id
group by a.schoolYear order by a.schoolYear


--Teste total de alunos por escola/ano letivo:
select school, [year], count (distinct StudentNumber) from OldData.dbo.Student group by school, [year]

select c.name, b.schoolYear, count(*) from Projeto.dbo.Student a
join Projeto.dbo.SchoolStudent b on b.idStudent=a.id
join Projeto.dbo.School c on c.id=b.idSchool
group by c.name, b.schoolYear

