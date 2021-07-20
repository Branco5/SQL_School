-- CMD
cd C:\Program Files\MongoDB\Server\4.4\bin
use STBWeb
db.createCollection("Grades") 


Comando 1 - db.Grades.find({"Guardian":"Encarregado 1"}).pretty()
Comando 2 - db.Grades.find({"StudentID": 1,  "SchoolYear": 1960}, { grade1: 1, grade2: 1, grade3: 1, Mean:1, SchoolYear:1, _id: 0 }).pretty()
Comando 3 - db.Grades.find({"Discipline":"TIC"}, {grade1: 1, grade2: 1, grade3: 1, Mean:1, SchoolYear:1, _id: 0}).pretty()

create or alter procedure JsonGrades
as
begin
select top 10000 d.studentNr as StudentID, g.[name] Guardian, f.[name] as Discipline, c.grade1, c.grade2, 
			c.grade3, convert(tinyint, avg((c.grade1+c.grade2+c.grade3)/3.0)) as Mean, b.schoolYear as SchoolYear
	from ClosedRegistrations a 
	join SchoolStudent b on a.idSchoolStudent = b.id
	inner join ClosedGrades c on a.id = c.registid
	join Student d on d.id = b.idStudent
	join (select [name], a.idStudent from Guardian a join Student b on a.idStudent = b.id
	join [User] c on c.id = a.id) g on g.idStudent = d.id
	join [User] e on e.id = d.id
	join Discipline f on f.id = a.idDiscipline group by d.studentNr, f.[name], g.[name], b.schoolYear, c.grade1, c.grade2, 
			c.grade3 order by schoolYear, Studentid for json path
end
go

-- Exemplo insert manual
db.grades.insert({
	_id:1,
	studentNr:1,
	guardianID:2,
	schoolYear:[{
		year:2016,
		Discipline:[{
			Name: "TIC"
			Grades: [{
				Grade1:8
				Grade2:6
				Grade3:7
				Mean:7
			},
			Name: "Math"
			Grades: [{
				Grade1:10
				Grade2:11
				Grade3:12
				Mean:11
			}]			
		},
		year:2017,
		Discipline:[{
			Name: "TIC"
			Grades: [{
				Grade1:12
				Grade2:10
				Grade3:14
				Mean:12
			}]
		}]
	}]	
})
