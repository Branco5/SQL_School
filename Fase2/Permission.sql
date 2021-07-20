-- Create role and login for administrator

CREATE ROLE AdminRole
GO

grant select, insert, update, delete on database :: Fase2 to AdminRole

CREATE LOGIN Principal 
    WITH PASSWORD = 'pass';  
GO  
  
CREATE USER [Admin] FOR LOGIN Principal;  
GO 

EXEC sp_addrolemember @rolename='AdminRole', @membername='Admin';
GO
-------------------------------------------------------------

-- Creates the user roles
create or alter procedure CreateUserRoles
as
begin	
	declare @isOpen varchar(5)
	set @isOpen = dbo.yearIsOpen()

	CREATE ROLE UserRole1
	grant select on object :: dbo.ClosedUserView1 to UserRole1
	CREATE ROLE UserRole2
	grant select on object :: dbo.ClosedUserView2 to UserRole2
	CREATE ROLE UserRole3
	grant select on object :: dbo.ClosedUserView3 to UserRole3
	CREATE ROLE UserRole4
	grant select on object :: dbo.ClosedUserView4 to UserRole4

	if (@isOpen='true')
	begin
		grant select on object :: dbo.OpenUserView1 to UserRole1
		grant select on object :: dbo.OpenUserView2 to UserRole2
		grant select on object :: dbo.OpenUserView3 to UserRole3
		grant select on object :: dbo.OpenUserView4 to UserRole4
	end
end
go

exec CreateUserRoles
go

-- Grants a user their permissions in the database
create or alter procedure GrantUserPermissions
	@userid int
as
begin
	declare @mail varchar(40)
	declare @pass varchar(40)
	declare @sql varchar(max)
	declare @schoolid char

	-- Caso utilizador seja estudante
	if exists (select id from Student where @userid = id)
	begin
		set @schoolid = (select distinct idSchool from dbo.SchoolStudent where idStudent = @userid)
	end
	-- Caso utilizador seja o encarregado pelo estudante
	else
	begin
		set @schoolid = (select distinct idSchool from dbo.SchoolStudent a
		join dbo.Guardian b on a.idStudent = b.idStudent where b.id = @userid)
	end

	set @mail = (select email from dbo.LoginDetails where userid=@userid)
	set @pass = (select pass from dbo.LoginDetails where userid=@userid)

	set @sql = N'Create Login '+@mail+' WITH PASSWORD = '+''''+@pass+''''+'   
	CREATE USER User'+convert(varchar(15), isnull(@userid, 'BLA'))+' FOR LOGIN '+@mail+' 

	EXEC sp_addrolemember @rolename=UserRole'+convert(varchar(15), isnull(@schoolid, 'BLi'))+', @membername=User'+convert(varchar(15), isnull(@userid, 'BLA'))

	print (@sql)
	
	exec (@sql)
end
go

--Teste
select b.name, c.id, d.idSchool, d.schoolYear, e.email, e.pass from LoginDetails a 
					join [User] b on a.userID = b.id 
					join Student c on c.id = b.id 
					join SchoolStudent d on c.id = d.idStudent 
					join logindetails e on e.userid=b.id
					where b.id=1

exec GrantUserPermissions @userid = 1
go

-- SQL server authentication: email/pass
-- Selecionar view da escola respetiva ao utilizador





































