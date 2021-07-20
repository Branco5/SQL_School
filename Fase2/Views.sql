-- Gets all final grades for each student and associated data from history tables
create or alter function FinalGrade()
returns table
as
return (select a.idSchoolStudent as ss, b.idStudent, b.idSchool, a.idDiscipline as discipline, c.grade3 as grade, b.schoolYear
	from ClosedRegistrations a 
	join SchoolStudent b on a.idSchoolStudent = b.id
	join ClosedGrades c on a.id = c.registid)
go

-- Gets count of grades above 15 in given year
create or alter function GrdsAbv15Yr(@yr int)
returns decimal
as
begin
	return (select count(grade) from FinalGrade() where grade>=15 and schoolYear=@yr)
end
go

-- Gets count of students in previous year
create or alter function getPrevCount(@yr int)
returns decimal
as
begin
	return (select count(*) from SchoolStudent where schoolYear=@yr-1)
end
go

-- Growth in number of students for each year
create view yrStdntGrowth
as
select schoolYear, count(*)-(select dbo.getPrevCount(schoolYear)) growth from SchoolStudent group by schoolYear

-- Rate of grades above 15 per year
create view Grd15Rate
as
select schoolYear, (select dbo.GrdsAbv15Yr(schoolYear))/count(*) as rate from FinalGrade() group by schoolYear


-- Devolve uma tabela com a melhor média por ano e escola
create function getAvgGrdYr()
returns table
as
return (select avg(grade/1.0) as media, s.[name] as escola, schoolYear from FinalGrade()
join School s on idSchool = s.id group by s.[name], schoolYear)
go

-- Mostra a escola com a melhor média em cada ano
create view SchoolBestAvg
as
select media, escola, a.schoolYear from
getAvgGrdYr() a inner join 
(select schoolYear, max(media) mm from getAvgGrdYr()
	group by schoolYear) b
	on a.schoolYear = b.schoolYear
	and a.media = b.mm
go

 -- Creates views for students and grades for each school
create or alter procedure CreateUserViews
as
begin
	declare @count tinyint
	set @count = 1;
	declare @sql varchar(max)

	while(@count<5)
	begin
		set @sql = N'
		create view ClosedUserView'+convert(char, @count)+' 
		as
		select idStudent, idDiscipline, schoolYear, Grade1, Grade2, Grade3 
		from ClosedRegistrations a join SchoolStudent b on a.idSchoolStudent=b.id
		join dbo.ClosedGrades c on c.registid = a.id
		where idSchool='+convert(char, @count)
		exec (@sql)
		set @count += 1
	end

	if exists(select distinct TABLE_NAME from INFORMATION_SCHEMA.COLUMNS where table_name like 'Grades%')
	begin
		set @count = 1
		declare @Gradestbl varchar(20)
		declare @Registstbl varchar(30)

		set @Gradestbl = (select distinct TABLE_NAME from INFORMATION_SCHEMA.COLUMNS where table_name like 'Grades%')
		set @Registstbl = (select distinct TABLE_NAME from INFORMATION_SCHEMA.COLUMNS where table_name like 'Registrations%')

		while @count<5
		begin
			set @sql = N'
			create view OpenUserView'+convert(char, @count)+' 
			as
			select idStudent, idDiscipline, schoolYear, Grade1, Grade2, Grade3 
			from '+@Registstbl+' a join SchoolStudent b on a.idSchoolStudent=b.id
			join '+@Gradestbl+' c on c.registid = a.id
			where idSchool='+convert(char, @count)
			exec (@sql)
			set @count += 1
		end
	end
end

exec createUserViews