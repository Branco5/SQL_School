--Outputs number of students in open registrations table
create or alter procedure getCurRegistsCount
	@count int output
as
begin
	set @count=0
	declare @tablename varchar(30)
	declare @sql nvarchar(100)
	set @tablename = (select distinct TABLE_NAME from INFORMATION_SCHEMA.COLUMNS where table_name like 'Registrations%')

	set @count = (select count (*) from dbo.SchoolStudent 
	where convert(varchar(4),schoolYear) = (select right(@tablename, 4)))	
end
go

-- Generates grades for the open year
create or alter procedure generateGrades
as
begin
	declare @sql varchar(max);
	declare @tablename varchar(30)
	declare @curRegists varchar(30)
	set @tablename = (select distinct TABLE_NAME from INFORMATION_SCHEMA.COLUMNS where table_name like 'Grades%')
	set @curRegists = (select distinct TABLE_NAME from INFORMATION_SCHEMA.COLUMNS where table_name like 'Registrations%')

	declare @registid varchar(20)
	
	set @sql= N'
	declare @registid varchar(20)
	declare @grade1 varchar(2);
	declare @grade2 varchar(2);
	declare @grade3 varchar(2);
	
	declare mycursor cursor
	for select convert(varchar(20), id) from '+isnull(@curRegists, 'bla')+'

	open mycursor 
	fetch next from mycursor into @registid

	while(@@FETCH_STATUS=0)
	begin
		set @grade1 = convert(varchar(2), (SELECT ABS(CHECKSUM(NEWID()) % (21))))
		set @grade2 = convert(varchar(2), (SELECT ABS(CHECKSUM(NEWID()) % (21))))
		set @grade3 = convert(varchar(2), (SELECT ABS(CHECKSUM(NEWID()) % (21 - 6 - 1)) + 6))
			
		insert into dbo.'+isnull(@tablename, 'bli')+'(grade1, grade2, grade3, registid)
		values (@grade1, @grade2, @grade3, @registid)
				
		fetch next from mycursor into @registid
	end
	close mycursor
	deallocate mycursor'
	exec(@sql)
end
go

--Associates student with 3 random disciplines
create or alter procedure registerStudentDisciplines
	@schstd int,
	@yr int
as
begin
	declare @regist int
	declare @disciplines TABLE (idDiscipline int)
	insert into @disciplines select TOP 3 id FROM dbo.Discipline ORDER BY NEWID()

	declare @tablename varchar(30)
	set @tablename = 'dbo.Registrations' + convert(varchar(5), @yr)
	--set @tablename = (select distinct TABLE_NAME from INFORMATION_SCHEMA.COLUMNS where table_name like 'Registrations%')
	
	declare @sql varchar(max)
	set @sql = ''
	declare @disciplineid int

	declare mycursor cursor
	for select idDiscipline from @disciplines

	open mycursor 
	fetch next from mycursor into @disciplineid

	while(@@FETCH_STATUS=0)
	begin
		set @sql = N'insert into '+@tablename+'(idSchoolStudent, idDiscipline) values('+convert(varchar(10), @schstd)+', '+convert(varchar(2), @disciplineid)+')'
		--print(@sql)
		exec (@sql)

		fetch next from mycursor into @disciplineid
	end
	close mycursor
	deallocate mycursor
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

-- Inserts failed students from past year in open registrations table
create or alter procedure InsertRepeatStudents
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
		[idschoolStudent] [int] NULL,
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

