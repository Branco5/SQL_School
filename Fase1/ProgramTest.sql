use projeto

select * from discipline
exec AverageGrades @year = 2019

select userid, studentNr, email, pass from dbo.Student a join LoginDetails b on a.id = b.userID order by studentNr

exec generateToken @email = 'email 1299'

select * from token

exec recoverPassword @tok = 80946, @email = 'email 2', @newPass = 'qdwqwdwqdwqd' -- no token sent to this email

exec recoverPassword @tok = 80946, @email = 'email 1299', @newPass = 'qdwqwdwqdwqd' -- invalid token

--Colocar token certo
exec recoverPassword @tok = 67487, @email = 'email 1299', @newPass = 'qdwqwdwqdwqd' 

select userid, studentNr, email, pass from dbo.Student a join LoginDetails b on a.id = b.userID order by studentNr 

exec updatePassword @email = 'email 99999', @oldpass = 'qdwqwdwqdwqd', @newPass1 = 'aa', @newPass2 = 'ab' -- email does not exist

exec updatePassword @email = 'email 1299', @oldpass = 'pass 1299', @newPass1 = 'aa', @newPass2 = 'ab' -- new pass fail

select * from errorlog

exec updatePassword @email = 'email 1299', @oldpass = 'pass 1299', @newPass1 = 'aa', @newPass2 = 'aa' -- new pass fail

select userid, studentNr, email, pass from dbo.Student a join LoginDetails b on a.id = b.userID order by studentNr

select * from PasswordUpdateEmail

exec openSchoolYear @yr = 2020

-- Confirmar alunos chumbados inscritos no novo ano
select a.idSchoolStudent as new_sch_std_id, b.idStudent, a.idDiscipline, c.grade3, c.schoolYear from dbo.Registrations2020 a 
join dbo.SchoolStudent b on a.idSchoolStudent = b.id
join (select idStudent, idDiscipline, grade3, schoolYear from dbo.ClosedRegistrations a 
				join dbo.SchoolStudent b on a.idSchoolStudent = b.id
				join dbo.ClosedGrades c on a.id=c.registid where schoolYear=2019) c  
				on c.idStudent = b.idStudent and a.idDiscipline = c.idDiscipline


exec TotalOpenRegistrations

exec RegisterStudentDiscipline @idStudentSchool = 1948, @year = 2020, @idDiscipline = 9 -- Aluno já inscrito na disciplina

exec UpdateGrade @grade = 10, @period = 2, @idRegistration = 1, @year = 2020

select * from Grades2020

exec RegisterStudentDiscipline @idStudentSchool = 3000, @year = 2020, @idDiscipline = 1 -- estudante inválido

exec closeSchoolYear @yr=2020

select * from dbo.Regists_Grades order by schoolYear desc

exec RegisterStudentSchool @idStudent = 1, @idSchool = 2 -- ano não aberto

