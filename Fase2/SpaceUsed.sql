

select sum(max_length)
from sys.columns
where object_NAME(object_id) = 'studentfamilyinfo' 

use fase2
exec sp_spaceused 'dbo.SchoolStudent' -- reserved 8152 kb
exec sp_spaceused 'dbo.Student' -- 3536 kb
exec sp_spaceused 'dbo.LoginDetails' -- 8584 kb
exec sp_spaceused 'dbo.User' -- 5320 kb
exec sp_spaceused 'dbo.Guardian' -- 1288 kb
exec sp_spaceused 'dbo.Discipline' -- 144 kb -- read only
exec sp_spaceused 'dbo.ClosedRegistrations' -- 9808 kb -- read only
exec sp_spaceused 'dbo.ClosedGrades' -- 11480 kb -- read only
exec sp_spaceused 'dbo.School' -- 144 kb -- read only
exec sp_spaceused 'dbo.discipline' -- 144 kb -- read only

use Projeto
exec sp_spaceused 'Parntstatus'
exec sp_spaceused 'dbo.education'
exec sp_spaceused 'dbo.educationtranslation'
exec sp_spaceused 'dbo.errorlog'
exec sp_spaceused 'Passwordupdateemail'
exec sp_spaceused 'YesNo'
exec sp_spaceused 'Address'
exec sp_spaceused 'dbo.useraddress'
exec sp_spaceused 'dbo.studentFamilyInfo'
exec sp_spaceused 'dbo.familyMember'


select count(*) from projeto.dbo.address
select count(*) from fase2.dbo.student
select count(*) from FamilyMember

-- Regra de 3 simples
--Adress
1947___136kb
120.000*1.5____x       x=8382

--SudentFamilyInfo
1947___40kb
80.000____x       x=1643

--FamilyMember
3894___64kb
160.000____x       x=2629



