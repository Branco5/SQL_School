use projeto
go


-- Gera um token de 5 dígitos para dado email
create or alter procedure GenerateToken
	@email varchar(100)
as
begin
	if not exists (select * from dbo.loginDetails a where @email = a.Email)
		begin		
			insert into errorLog values(current_user, 'email does not exist', sysdatetime());
			throw 50000, 'email does not exist', 1
		end	
	else
		begin
			insert into token(token, time, email)
			select ABS(CHECKSUM(NEWID()) % (99999 - 10000 - 1)) + 10000, sysdatetime(), @email
		end
end
go

-- Processo para mudar a password em loginDetails dado o token correto em menos de 1 hora
create or alter procedure RecoverPassword
	@tok int,
	@email varchar(100),
	@newPass varchar(100)
as
begin
	declare @aux table(
		[time] datetime2,
		token int
	)
	insert into @aux
	select top 1 t.[time], t.token from token t where @email = t.email order by t.[time] desc

	if not exists (select * from token a where @email = a.Email)
		begin
			insert into errorLog values(current_user, 'no token sent to this email', sysdatetime());
			throw 50000, 'no token sent to this email', 1;				
		end	
	else if (datediff (HOUR, (select time from @aux), sysdatetime()) > 1 or @tok != (select token from @aux))
		begin
			insert into errorLog values(current_user, 'invalid token', sysdatetime());
			throw 50000, 'invalid token', 1;
		end	
	else
		begin			
			update LoginDetails	set pass = @newPass where @email = email
		end
end
go

-- Mudar a password em loginDetails dada a passe antiga correta
create or alter procedure UpdatePassword
	@email varchar(50),
	@oldPass varchar(50),
	@newPass1 varchar(50),
	@newPass2 varchar(50)
as
begin
	if not exists (select * from loginDetails a where @email = a.Email)
		begin
			insert into errorLog values(current_user, 'email does not exist', getdate());
			throw 50000, 'email does not exist', 1			
			--rollback transaction
		end	
	
	else if not exists (select * from loginDetails a where @oldPass = a.pass and @email = a.Email)
		begin
			insert into errorLog values(current_user, 'incorrect password', getdate());
			throw 50000, 'incorrect password', 1	
		end	
	
	else if (@newPass1 != @newPass2)
		begin
			insert into errorLog values(current_user, 'new password verification failed', getdate());
			throw 50000, 'new password verification failed', 1	
		end	

	else
		begin
			update LoginDetails	set pass = @newPass1 where @email = email
		end
end
go

-- Insere mensagem de confirmação na tabela PasswordUpdateEmail
create trigger trPasswordUpdateEmail
on loginDetails
after update
as
begin
	insert into PasswordUpdateEmail select 'Password updated successfully', inserted.email from inserted
end
go

-- Returns table with final grades in given year and associated data
create or alter function FinalGradeYr(@year int)
returns table
as
return (select a.idSchoolStudent, a.idDiscipline, c.grade3 as grade, b.idSchool, b.idStudent, b.schoolYear
	from ClosedRegistrations a 
	join SchoolStudent b on a.idSchoolStudent = b.id
	join ClosedGrades c on a.id = c.registid
	where b.schoolYear=@year)
go

-- Returns students and associated data with final grade < 10 in given year
create or alter function getFailedStdtsDisc(@year int)
returns table
as
	return (select * from FinalGradeYr(@year) where grade < 10)
go

create or alter procedure insertRepeatStudents
	 @year varchar(4),
	 @table varchar(30)
as
begin
	declare @sql varchar(300)
	insert into dbo.SchoolStudent(idStudent, idSchool, schoolYear) 
				select distinct idStudent, idSchool, @year from getFailedStdtsDisc(@year-1)

	set @sql = 'insert into '+@table+'(idSchoolStudent, idDiscipline)
						select b.id, a.idDiscipline from 
						getFailedStdtsDisc('+@year+'-1) a join 
						dbo.SchoolStudent b on a.idStudent = b.idStudent 
						where b.schoolYear = '+@year+'
						order by b.id'						
	print @sql
	exec (@sql)
end
go

-- Opens new year if there's no year open already
create or alter procedure OpenSchoolYear
	@yr int
as
begin
	if exists(select distinct TABLE_NAME from INFORMATION_SCHEMA.COLUMNS where table_name like 'Grades%')
	begin
		insert into dbo.ErrorLog values (current_user, 'School year already open', sysdatetime());
		throw 50000, 'School year already open', 1
	end
	declare @tblname varchar(40)
	declare @tblname2 varchar(40)
	declare @sql varchar(max)
	set @sql = ''

	set @tblname = 'Registrations' + convert(varchar(5), @yr)

	SET ANSI_NULLS ON

	SET QUOTED_IDENTIFIER ON

	set @sql = 
	'CREATE TABLE [dbo].'+@tblname+'(
		[id] [int] IDENTITY(1,1) NOT NULL,
		[idDiscipline] [tinyint] NULL,
		[idSchoolStudent] [int] NULL,
	PRIMARY KEY CLUSTERED 
	(
		[id] ASC
	)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON, OPTIMIZE_FOR_SEQUENTIAL_KEY = OFF) ON [PRIMARY]
	) ON [PRIMARY]
	

	ALTER TABLE [dbo].'+@tblname+'  WITH CHECK ADD FOREIGN KEY([idDiscipline])
	REFERENCES [dbo].[Discipline] ([id])
	

	ALTER TABLE [dbo].'+@tblname+'  WITH CHECK ADD FOREIGN KEY([idschoolStudent])
	REFERENCES [dbo].[SchoolStudent] ([id])'

	exec (@sql)

	set @tblname2 = 'Grades' + convert(varchar(5), @yr)
	
	set @sql = 'CREATE TABLE [dbo].'+@tblname2+'(
	[grade1] [tinyint] NULL,
	[grade2] [tinyint] NULL,
	[grade3] [tinyint] NULL,
	[registid] [int] NOT NULL,
	PRIMARY KEY CLUSTERED 
	(
		[registid] ASC
	)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON, OPTIMIZE_FOR_SEQUENTIAL_KEY = OFF) ON [PRIMARY]
	) ON [PRIMARY]

	ALTER TABLE [dbo].'+@tblname2+'  WITH CHECK ADD FOREIGN KEY([registid])
	REFERENCES [dbo].'+@tblname+' ([id])'
	
	exec (@sql)
	
	exec dbo.insertRepeatStudents @year = @yr, @table = @tblname

end
go

-- Closes school year if there is one open and transfers data to history
create or alter procedure CloseSchoolYear	
	@yr int
as
begin		
	if not exists(select distinct * from INFORMATION_SCHEMA.COLUMNS a where table_name = 'Grades' + convert(varchar(5), @yr)) 
		begin
			insert into errorLog values(current_user, 'Year not open', getdate());
			throw 50000, 'Year not open', 1	
		end
	declare @res int
	declare @regist varchar(30)
	declare @grades varchar(25)
	declare @sql varchar(max)

	set @regist = 'dbo.Registrations'+convert(varchar(5), @yr)
	set @grades = 'dbo.Grades'+convert(varchar(5), @yr)

	set @sql = N'
	declare @grade1 tinyint
	declare @grade2 tinyint
	declare @grade3 tinyint
	declare @discipline tinyint
	declare @schstd int
	declare @scopeid int

	declare gcursor cursor for 
	select idSchoolStudent, idDiscipline, grade1, grade2, grade3
	from '+@regist +' r join '+@grades+' g on g.registid = r.id

	open gcursor
	fetch next from gcursor into @schstd, @discipline, @grade1, @grade2, @grade3

	while(@@FETCH_STATUS=0)
		begin			
			insert into [dbo].[ClosedRegistrations]([idSchoolStudent], [idDiscipline])
			select @schstd, @discipline

			set @scopeid = SCOPE_IDENTITY()

			insert into ClosedGrades(grade1, grade2, grade3, registid)
				select @grade1, @grade2, @grade3, @scopeid	
				
			fetch next from gcursor into @schstd, @discipline, @grade1, @grade2, @grade3
		end

	close gcursor
	deallocate gcursor	
	drop table '+@grades+'
	drop table '+@regist   			
	
	exec (@sql)

end
go

--Returns true if school year is open
create or alter function yearIsOpen()
	returns varchar(5)
as
begin
	if exists (select distinct * from INFORMATION_SCHEMA.COLUMNS a where table_name = 'Grades%')
	begin
		return 'true'
	end

	return 'false'
end

-- Associates school with student in open school year
create or alter procedure RegisterStudentSchool
	@idStudent int,
	@idSchool tinyint
as
begin
	declare @openYear varchar(30)
	set @openYear = (select dbo.yearIsOpen())

	if (@openYear = 'false') 
		begin
			insert into errorLog values(current_user, 'Ano não aberto', getdate());
			throw 50000, 'Ano não aberto', 1	
		end

	set @openYear = (select distinct table_name from INFORMATION_SCHEMA.COLUMNS a where table_name like 'Registrations%')

	declare @year smallint
	set @year = (select RIGHT(@openYear,4))

	insert into dbo.SchoolStudent(idSchool, idStudent, schoolYear) select @idSchool, @idStudent, @year
	
end
go

-- Associates student with discipline in given year
create or alter procedure RegisterStudentDiscipline
	@idStudentSchool varchar(8),
	@year int,
	@idDiscipline char
as
begin	
	declare @tablename varchar(50)
	set @tablename = 'dbo.Registrations' + convert(varchar(5), @year)

	declare @sql nvarchar(max)

	if not exists (select * from dbo.schoolStudent where id=@idStudentSchool)
		begin
			insert into errorLog values(current_user, 'Estudante inválido', getdate());
			throw 50000, 'Estudante inválido', 1
		end
	else if not exists(select * from INFORMATION_SCHEMA.COLUMNS a where table_name = 'Registrations' + convert(varchar(5), @year)) 
		begin
			insert into errorLog values(current_user, 'Ano não aberto', getdate());
			throw 50000, 'Ano não aberto', 1
		end
	set @sql= 'if exists(select * from '+@tablename+ ' a join dbo.SchoolStudent b on b.id=a.idSchoolStudent where idDiscipline = '+@idDiscipline+' and  '+@idStudentSchool+' = idSchoolStudent)
		begin
			insert into errorLog values(current_user, ''Aluno já inscrito na disciplina'', getdate());
			throw 50000, ''Aluno já inscrito na disciplina'', 1	
		end
	else
		begin
			insert into '+@tablename+' (idDiscipline, idschoolStudent) select '+@idDiscipline+', '+@idStudentSchool+' 
		end'
	exec (@sql)	
end
go

-- Inserts/updates given grade
create or alter procedure UpdateGrade
	@grade varchar(2),
	@period char,
	@idRegistration varchar(8),
	@year smallint
as
begin
	declare @grades varchar(50)
	declare @regist varchar(50)
	declare @registsName varchar(50)
	declare @gradeperiod varchar(7)
	set @gradeperiod = 'grade'+@period
	
	declare @sql1 nvarchar(max)
	declare @sql2 nvarchar(max)

	set @grades = 'dbo.Grades' + convert(varchar(5), @year)
	set @regist = 'dbo.Registrations' + convert(varchar(5), @year)

	if not exists(select distinct * from INFORMATION_SCHEMA.COLUMNS a where table_name = 'Grades' + convert(varchar(5), @year)) 
		begin
			insert into errorLog values(current_user, 'Ano não aberto', getdate());
			throw 50000, 'Ano não aberto', 1	
		end
	declare @res int
	
	set @sql1 = N'select @x = (select count(*) from '+@grades+' where registid = '+ @idRegistration+')'	
	
	exec sp_executesql @sql1, N'@x int out', @res out
	
	if @res = 0 
		begin
			set @sql2= 'insert into '+@grades+'('+@gradeperiod+', registid) values('+@grade+', '+@idRegistration+')'
			exec (@sql2)
		end
	else
		begin
			set @sql2= 'update '+@grades+' set grade'+@period+' = '+@grade+' where registid = '+@idRegistration
			exec (@sql2)
		end		
end
go

--Total de alunos de alunos inscritos em cada uma das disciplinas no ano aberto face ao ano
--anterior e a respetiva taxa de crescimento. 
create or alter procedure TotalOpenRegistrations
as
begin
	declare @sql nvarchar(max)
	set @sql = ''	

	declare @sql2 nvarchar(max)
	set @sql2 = ''	

	declare @currentRegists int
	set @currentRegists = 0
	declare @lastYrRegists int
	set @lastyrregists = 0
	declare @registsName varchar(50)

	set @registsName = (select distinct table_name from INFORMATION_SCHEMA.COLUMNS a where table_name like 'Registrations%')

	set @sql = N'
	select @x = (select count (*) from dbo.'+@registsName+' a
	join SchoolStudent b on a.idschoolStudent = b.id
	where schoolyear = (select right('''+@registsName+''', 4)))'

	set @sql2 = N'
	select @y = (select count (*) from dbo.ClosedRegistrations a
	join SchoolStudent b on a.idschoolStudent = b.id
	where schoolyear = (select right('''+@registsName+''', 4))-1)'
		
	exec sp_executesql @sql, N'@x int out', @currentRegists out
	exec sp_executesql @sql2, N'@y int out', @lastYrRegists out

	select @currentRegists as cur, @lastYrRegists as [last], (@currentRegists*1.0-@lastYrRegists*1.0)/(@lastYrRegists*1.0) as rate		
end
go

-- Selects grade average of given year and comparison with last year
create or alter procedure AverageGrades
	@year int
as
begin
	declare @avrLast decimal(4,2)
	declare @avrYear decimal(4,2)

	set @avrYear = (select avg((grade1+grade2+grade3)/3.0) from dbo.ClosedGrades a join dbo.ClosedRegistrations b on b.id=a.registid
	join dbo.schoolStudent c on b.idSchoolStudent=c.id where schoolyear = @year)

	set @avrLast = (select avg((grade1+grade2+grade3)/3.0) from dbo.ClosedGrades a join dbo.ClosedRegistrations b on b.id=a.registid
	join dbo.schoolStudent c on b.idSchoolStudent=c.id where schoolyear = (@year-1))

	select (@avrYear - @avrLast) / @avrLast as GrowthRate, @avrYear as [current], @avrLast as [last]
end
go




























----------------------------------------------









create function getOpenRegists()
returns varchar(30)
as
begin
	return (select distinct * from INFORMATION_SCHEMA.COLUMNS a where table_name like 'Registrations%')
end

create procedure ConfirmRepeatStdts
as
begin
	declare @open varchar(5)
	set @open = (select yearisOpen())

	if(@open=true)
	begin
	select a.idSchoolStudent as new_sch_std_id, b.idStudent, a.idDiscipline, c.grade3, c.schoolYear from dbo.Registrations2020 a 
		join dbo.SchoolStudent b on a.idSchoolStudent = b.id
		join (select idStudent, idDiscipline, grade3, schoolYear from dbo.ClosedRegistrations a 
		join dbo.SchoolStudent b on a.idSchoolStudent = b.id
		join dbo.ClosedGrades c on a.id=c.registid where schoolYear=2019) c  
		on c.idStudent = b.idStudent and a.idDiscipline = c.idDiscipline
	end

end
