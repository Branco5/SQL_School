drop index NONCI_year on [dbo].[SchoolStudent]
drop index NONCI_SchStd ON [dbo].[ClosedRegistrations]
drop index NONCI_Grade ON [dbo].[ClosedGrades]
drop index NONCI_Regist ON [dbo].[ClosedGrades]
drop index NONCI_SchoolYear ON [dbo].[SchoolStudent]

SET STATISTICS IO ON
SET STATISTICS time ON

--yrStdntGrowth
select schoolYear, count(*)-(select dbo.getPrevCount(schoolYear)) growth from SchoolStudent group by schoolYear

--Grd15Rate
select schoolYear, (select dbo.GrdsAbv15Yr(schoolYear))/count(*) as rate from FinalGrade() group by schoolYear

--SchoolBestAvg
select media, escola, a.schoolYear from
getAvgGrdYr() a inner join 
(select schoolYear, max(media) mm from getAvgGrdYr()
	group by schoolYear) b
	on a.schoolYear = b.schoolYear
	and a.media = b.mm

-- Executar Index.sql (fase2)

--yrStdntGrowth
select schoolYear, count(*)-(select dbo.getPrevCount(schoolYear)) growth from SchoolStudent group by schoolYear

--Grd15Rate
select schoolYear, (select dbo.GrdsAbv15Yr(schoolYear))/count(*) as rate from FinalGrade() group by schoolYear

--SchoolBestAvg
select media, escola, a.schoolYear from
getAvgGrdYr() a inner join 
(select schoolYear, max(media) mm from getAvgGrdYr()
	group by schoolYear) b
	on a.schoolYear = b.schoolYear
	and a.media = b.mm