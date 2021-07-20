
--insert static data
insert into dbo.Discipline(name) select 'Português'
insert into dbo.Discipline(name) select 'Inglês'
insert into dbo.Discipline(name) select 'Francês'
insert into dbo.Discipline(name) select 'Matemática'
insert into dbo.Discipline(name) select 'Ciências'
insert into dbo.Discipline(name) select 'Físico-Química'
insert into dbo.Discipline(name) select 'Educação-Visual'
insert into dbo.Discipline(name) select 'TIC'
insert into dbo.Discipline(name) select 'Educação Física'

insert into school(name) values ('Fernando Pessoa'), ('José Saramago'), ('Eça de Queirós'), ('Bocage')
go


create or alter procedure GenerateStudents
as
begin
	declare @repCount smallint; -- number of repeat students
	declare @number smallint; --number of students
	declare @name1 varchar(20);
	declare @name2 varchar(20);
	declare @idschool char;
	declare @globalCount int;
	declare @localCount int;
	declare @idStudent int;
	declare @idGuardian int;
	declare @year smallint;
	declare @idDiscipline tinyint;
	declare @regist int;
	declare @pass varchar(15);

	set @globalCount = 0;
	set @year = 1959;

	while (@year < 2020)
		begin
			set @localCount=0
			set @year= @year + 1;
			exec dbo.OpenSchoolYear @yr = @year

			exec dbo.getCurRegistsCount @count=@repCount output;

			set @number = (SELECT ABS(CHECKSUM(NEWID()) % (2500 - 2000 - 1)) + 2000) - @repcount;

			while(@localCount<@number)
				begin
					set @globalCount = @globalCount + 1
					set @localCount = @localCount + 1
					set @name1 = 'Estudante_'+ convert(varchar(10), @globalCount)
					set @name2 = 'Encarregado_'+ + convert(varchar(10), @globalCount)
					set @pass = 'Pass_'+convert(varchar(10), @globalCount)
					set @idschool = (select TOP 1 id FROM dbo.School ORDER BY NEWID());			

					insert into dbo.[User]([name]) select @name1;
					set @idStudent = SCOPE_IDENTITY()
					insert into dbo.LoginDetails select @name1, @pass, @idStudent					
					insert into dbo.Student(id, studentNr) select @idStudent, @globalCount;
					insert into dbo.[User]([name]) select @name2;
					set @idGuardian = SCOPE_IDENTITY()
					insert into dbo.LoginDetails select @name2, @pass, @idGuardian
					insert into dbo.Guardian(id, idStudent) select @idGuardian, @idStudent;								
			
					insert into dbo.SchoolStudent(idStudent, idSchool, schoolYear) select @idStudent, @idschool, @year
					set @idStudent = SCOPE_IDENTITY()
					exec dbo.registerStudentDisciplines @schstd = @idStudent, @yr=@year				
				end
				exec generateGrades
				exec dbo.CloseSchoolYear @yr = @year
		end
end
go

exec GenerateStudents

-- Verificar número correto de alunos em cada ano
select schoolYear, count(*) from dbo.SchoolStudent group by schoolYear order by schoolYear







--Delete all data and reseed
EXEC sp_MSForEachTable 'DISABLE TRIGGER ALL ON ?'
GO
EXEC sp_MSForEachTable 'ALTER TABLE ? NOCHECK CONSTRAINT ALL'
GO
EXEC sp_MSForEachTable 'DELETE FROM ?'
GO
EXEC sp_MSForEachTable 'ALTER TABLE ? CHECK CONSTRAINT ALL'
GO
EXEC sp_MSForEachTable 'ENABLE TRIGGER ALL ON ?'
GO

exec sp_MSforeachtable @command1 = 'DBCC CHECKIDENT(''?'', RESEED, 0)'
------------





