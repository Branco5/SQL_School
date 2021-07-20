use Projeto
go


create or alter procedure MigrateDisciplines
as
begin
	declare @class varchar(40)
	declare @aux table(
		[name] varchar(150)
	)

	declare classCursor cursor for
	select class from OldData.dbo.Student	

	open classCursor 
	fetch next from classCursor into @class
		
	while(@@FETCH_STATUS=0)
	begin
		if not exists(select * from @aux where [name] = @class)
			begin
				insert into @aux([name]) select @class
				declare @pos int
				declare @len int
				declare @name varchar(60)		
				declare @prev int		
		
				set @pos = 0
				set @len = 0
				set @prev = 0
				set @class = @class + '/'

				while CHARINDEX('/', @class, @pos+1)>0
				begin
					set @len = CHARINDEX('/', @class, @pos+1) - @pos
					set @name = SUBSTRING(@class, @pos, @len)            
				
					if @pos=0
						begin
							insert into projeto.dbo.Discipline([name]) select @name;							
						end
					else
						begin
							insert into projeto.dbo.Discipline(parentid, [name]) select @@IDENTITY, @name
						end						 
					set @pos = CHARINDEX('/', @class, @pos+@len) +1			
					end				
				end
			fetch next from classCursor into @class
	end
	close classCursor
	deallocate classCursor
end
go


create or alter procedure insertStaticData
as
begin
	insert into Projeto.dbo.Languages([language]) select 'EN'
	insert into Projeto.dbo.Languages([language]) select 'PT'

	insert into dbo.YesNo values('Yes'), ('No')

	insert into dbo.HighLow values(1),(2),(3),(4),(5)
	insert into dbo.HighLowTrans values(1, 1, 'Very Low'), (2,1,'Low'),(3,1,'Average'), (4,1,'High'),(5,1,'Very High')
	insert into dbo.HighLowTrans values(1, 2, 'Muito Baixo'), (2,2,'Baixo'),(3,2,'Médio'), (4,2,'Alto'),(5,2,'Muito Alto')

	insert into TimeGaps values ('<15 min'),('15-30 min'),('30 min-1 hr'),('>1 hr'),
							('<2 hrs'),('2 - 5 hrs'),('5 to 10 hrs'), ('>10 hrs')

	insert into FamSize values(1),(2)
	insert into FamSizeTrans values (1,1,'less or equal to 3'), (2,1,'greater than 3')
	insert into FamSizeTrans values (1,2,'menor ou igual a 3'), (2,2,'maior que 3')

	insert into FamType values (1), (2), (3)
	insert into FamTypeTranslation values (1,1,'Father'), (2,1,'Mother'), (3,1,'Other'), (1,2,'Pai'),(2,2,'Mãe'), (3,2,'Outro')

	insert into Education values(1),(2),(3),(4),(5)
	insert into EducationTranslation values (1, 1, 'none'), (2,1,'4th grade'),(3,1,'5th-9th grade'), (4,1,'secondary'),(5,1,'higher')
	insert into EducationTranslation values (1, 2, 'nenhuma'), (2,2,'4º ano'),(3,2,'5º-9º ano'), (4,2,'secundária'),(5,2,'superior')

	insert into ParntStatus values(1),(2)
	insert into ParntStatusTrans values (1,1,'living together'), (2,1,'separated')
	insert into ParntStatusTrans values (1,2,'juntos'), (2,2,'separados')

	insert into Job values (1), (2), (3), (4), (5)
	insert into JobTranslation values(1,1,'teacher'), (2,1,'health'), (3,1,'services'),(4,1,'at home'), (5,1,'other'),
							(1,2,'professor'), (2,2,'saúde'), (3,2,'serviços'),(4,2,'em casa'), (5,2,'outro')

	insert into school(name)
	values ('Gabriel Pereira'), ('Mousinho da Silveira')

	insert into reason(id) values (1), (2), (3), (4)
	insert into reasonTranslation(id, idLang, reason) values (1,1,'close to home'),(2,1,'school reputation'),(3,1,'course preference'),(4,1,'other'),
	(1,2,'perto de casa' ),(2,2,'reputação da escola'),(3,2,'preferência de curso'),(4,2,'outro')
end
go


create or alter procedure MigrateStudents
as 
begin
	declare @name varchar(50)
	declare @sex char
	declare @birth varchar(20)

	declare @number int
	declare @travel int
	declare @studytime int
	declare @failures int
	declare @freetime int
	declare @goout int
	declare @Dalc int
	declare @Walc int
	declare @health int
	declare @absences int
	declare @schoolsup varchar(3)
	declare @paid varchar(3)
	declare @actvities varchar(3)
	declare @nursery varchar(3)
	declare @higher varchar(3)
	declare @internet varchar(3)
	declare @romantic varchar(3)

	declare @reason varchar(40)
	
	declare @count int
	set @count = 0
	
	declare @id int

	set @name = ''

	declare studentCursor cursor for
	select sex, birthdate, StudentNumber, [traveltime], [studytime], [failures], [freetime], [goout], [Dalc], [Walc], [health], [absences], reason,
			schoolsup, paid, activities, nursery, higher, internet, romantic 	
			from OldData.dbo.Student	

	open studentCursor 
	fetch next from studentCursor into @sex, @birth, @number, @travel, @studytime, @failures, @freetime, @goout, @Dalc, @Walc, @health, @absences, @reason, 
										@schoolsup, @paid, @actvities, @nursery, @higher, @internet, @romantic 

	while @@FETCH_STATUS=0
		begin
			if not exists (select * from Projeto.dbo.Student where studentNr = @number)
			begin
				set @count = @count + 1
				set @name = N'Nome Aluno '+ convert(varchar(10), @count)
				
				insert into Projeto.dbo.[User](sex, birth, [name]) 
					select @sex, convert(date, @birth, 103), @name

				set @id = SCOPE_IDENTITY()

				insert into Projeto.dbo.Student(id, studentNr, travelTime,failures, studytime, [freetime], [goout], [DayAlc], [WkndAlc], [health], [absences], schoolsup, paid, activities, nursery, higher, internet, romantic ) 
					select @id, @number, @travel, @failures, 
					(case when @studytime = 1 then 5 when @studytime = 2 then 6 when @studytime = 3 then  7 when @studytime = 4 then 8 end), @freetime, @goout, @Dalc, @Walc, @health, @absences,					
					(case when @schoolsup = 'Yes' then 1 when @schoolsup='No' then 2 end),
					(case when @paid = 'Yes' then 1 when @paid='No' then 2 end),
					(case when @actvities = 'Yes' then 1 when @actvities='No' then 2 end),
					(case when @nursery = 'Yes' then 1 when @nursery='No' then 2 end),
					(case when @higher = 'Yes' then 1 when @higher='No' then 2 end),
					(case when @internet = 'Yes' then 1 when @internet='No' then 2 end),
					(case when @romantic = 'Yes' then 1 when @romantic='No' then 2 end)
				
			end
			
			fetch next from studentCursor into @sex, @birth, @number, @travel,@studytime, @failures, @freetime, @goout, @Dalc, @Walc, @health, @absences, @reason,
												@schoolsup, @paid, @actvities, @nursery, @higher, @internet, @romantic 												
		end
		close studentCursor
		deallocate studentCursor
end
go

create or alter procedure MigrateSchools
as
begin
	
	declare @name varchar(2)
	declare @idStudent int
	declare @reason varchar(20)
	declare @schoolYear int

	declare schoolCursor cursor
	for select distinct o.school, p.id, o.reason, o.year from OldData.dbo.Student o 
	join Projeto.dbo.Student p on o.StudentNumber = p.studentNr order by p.id

	open schoolCursor
	fetch next from schoolCursor into @name, @idStudent, @reason, @schoolYear

	while(@@FETCH_STATUS = 0)
		begin
			insert into Projeto.dbo.SchoolStudent(idStudent, idSchool, schoolYear, reason)
			select @idStudent, (case when @name = 'GP' then 1 when @name = 'MS' then 2 end), @schoolYear, 
			(case when @reason = 'home' then 1 when @reason = 'reputation' then 2 when @reason = 'course' then  3 when @reason = 'other' then 4 end)
			
			fetch next from schoolCursor into @name, @idStudent, @reason, @schoolYear
		end

end
go

create or alter procedure MigrateFamilyInfo
as
begin
	
	declare @pstatus char
	declare @famsize varchar (50)
	declare @famsup varchar(3)
	declare @famrel tinyint
	declare @number int

	declare familyCursor cursor
	for select distinct o.pstatus, o.famsize, o.famsup, o.famrel, p.id from OldData.dbo.Student o 
	join Projeto.dbo.Student p on o.StudentNumber = p.studentNr order by p.id
	

	open familyCursor
	fetch next from familyCursor into @pstatus, @famsize, @famsup, @famrel, @number

	while(@@FETCH_STATUS = 0)
		begin
			insert into Projeto.dbo.StudentFamilyInfo(parentstatus, famsize, famsup, famrel, idStudent)
			select (case when @pstatus='T' then 1 when @pstatus='A' then 2 end),
			(case when @famsize = 'LE3' then 1 when @famsize = 'GT3' then 2 end),
			(case when @famsup = 'Yes' then 1 when @famsup='No' then 2 end),
			@famrel, @number
			
			fetch next from familyCursor into @pstatus, @famsize, @famsup, @famrel, @number
		end
		close familyCursor
		deallocate familyCursor
end
go


create or alter procedure MigrateFamilyMember
as
begin

	declare @mjob varchar(40)
	declare @fjob varchar(40)
	declare @medu int
	declare @fedu int
	declare @id int

	declare familyCursor cursor
	for select distinct o.Mjob, o.Fjob, o.Fedu, o.Medu, p.id from OldData.dbo.Student o 
	join Projeto.dbo.Student p on o.StudentNumber = p.studentNr order by p.id	

	open familyCursor
	fetch next from familyCursor into @mjob, @fjob, @fedu, @medu, @id

	while(@@FETCH_STATUS = 0)
		begin

			insert into Projeto.dbo.FamilyMember (idStudent, [type], job, education)
			select @id, 1,
			(case when @fjob = 'teacher' then 1 when @fjob='health' then 2 when @fjob = 'services' then 3 when @fjob = 'at home' then 4
				when @fjob = 'other' then 4 end),
			(case when @fedu = 0 then 1 when @fedu = 1 then 2 when @fedu = 2 then 3 
				when @fedu = 3 then 4 when @fedu = 4 then 5 end)

			
			
			insert into Projeto.dbo.FamilyMember (idStudent, [type], job, education)
			select @id, 2,
			(case when @mjob = 'teacher' then 1 when @mjob='health' then 2 when @mjob = 'services' then 3 when @mjob = 'at home' then 4
				when @mjob = 'other' then 4 end),
			(case when @medu = 0 then 1 when @medu = 1 then 2 when @medu = 2 then 3 
				when @medu = 3 then 4 when @medu = 4 then 5 end)		
			
			fetch next from familyCursor into @mjob, @fjob, @fedu, @medu, @id
		end
		close familyCursor
		deallocate familyCursor
end
go
	


create or alter procedure MigrateGuardian
as
begin
	declare @guardian varchar(10)	
	declare @id int
	
	declare familyCursor cursor
	for select distinct o.guardian, p.id 
	from OldData.dbo.Student o 
	join Projeto.dbo.Student p on o.StudentNumber = p.studentNr order by p.id	

	open familyCursor
	fetch next from familyCursor into @guardian, @id

	declare @name varchar(40)
	declare @count int
	set @count = 0
	set @name = ''

	while(@@FETCH_STATUS = 0)
		begin
			set @count = @count + 1
			set @name = N'Nome guardian '+ convert(varchar(10), @count)

			insert into Projeto.dbo.[user]([name]) select @name
			insert into Projeto.dbo.Guardian(id, [type], idStudent) select SCOPE_IDENTITY(), 
			(case when @guardian = 'father' then 1 when @guardian='mother' then 2 when @guardian='other' then 3 end), @id
			
			fetch next from familyCursor into @guardian, @id
		end
		close familyCursor
		deallocate familyCursor
end
go


	
create or alter procedure migrateGrades
as
begin
	declare @schoolYear int
	declare @discipline varchar(50)
	declare @schoolstdid int
	declare @g1 int
	declare @g2 int
	declare @g3 int
	declare @id int	

	declare disCursor cursor
	for select o.p1, o.p2, o.p3, p.id, o.class, ss.id
	from OldData.dbo.Student o 
	join Projeto.dbo.Student p on o.StudentNumber = p.studentNr 
	join Projeto.dbo.schoolStudent ss on ss.idStudent = p.id order by p.id

	open disCursor
	fetch next from disCursor into @g1, @g2, @g3, @id, @discipline, @schoolstdid
	
	declare @idRegist int
	while (@@FETCH_STATUS=0) 
		begin
			insert into ClosedRegistrations(idschoolStudent, idDiscipline)
				select @schoolstdid, (case when @discipline like '%CBD' then 6 when @discipline like '%BD' then 3 when @discipline like '%MAT1' then 9 end)
									
			set @idRegist = SCOPE_IDENTITY()

			insert into ClosedGrades(grade1, grade2, grade3, registid)
				values (@g1,@g2, @g3, @idRegist)
			
			fetch next from disCursor into @g1, @g2, @g3, @id, @discipline, @schoolstdid
		end
		
		close disCursor
		deallocate disCursor
end
go
	


create or alter procedure CreateLoginDetails
as
begin
	declare @email varchar(100)
	declare @pass varchar(50)
	declare @userID int

	declare logCursor cursor 
	for select id from Projeto.dbo.[User]

	open logCursor
	fetch next from logCursor into @userID

	declare @count int
	set @count = 0

	while(@@FETCH_STATUS = 0)
		begin
			set @count = @count + 1
			set @email = 'email ' + convert(varchar(10), @count)
			set @pass = 'pass ' + convert(varchar(10), @count)

			insert into Projeto.dbo.LoginDetails(email, pass, userID)
				select @email, @pass, @userID
			fetch next from logCursor into @userID
		end
		close logCursor
		deallocate logCursor
end
go
	


create or alter procedure CreateAddress
as
begin
	declare @userid int
	declare @type char
	declare @description varchar(100)

	declare addressCursor cursor 
	for select distinct p.id, o.[address] from Projeto.dbo.[User] p 
	join Projeto.dbo.Student p2 on p.id = p2.id
	join OldData.dbo.Student o on o.StudentNumber = p2.studentNr 

	open addressCursor
	fetch next from addressCursor into @userID, @type

	declare @count int
	set @count = 0

	declare @idAdd int

	while(@@FETCH_STATUS = 0)
		begin
			set @count = @count + 1
			set @description = 'address ' + convert(varchar(10), @count)			

			insert into Projeto.dbo.[Address]([description], [type])
				select @description, (case when @type = 'U' then 'urban' when @type = 'R' then 'rural' end)

			set @idAdd = SCOPE_IDENTITY()

			insert into Projeto.dbo.UserAddress(idUser, idAddress, mainAddress)
				select @userid, @idAdd, 1		

			fetch next from addressCursor into @userID, @type
		end
		close addressCursor
		deallocate addressCursor
end
go


	
exec MigrateDisciplines
exec insertStaticData
exec MigrateStudents
exec MigrateSchools
exec MigrateFamilyInfo
exec MigrateFamilyMember
exec migrateGuardian
exec migrateGrades	
exec CreateLoginDetails
exec CreateAddress

