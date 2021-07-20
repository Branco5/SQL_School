use OldData;
create database OldData;

create table Student( 
	StudentNumber int,	
	school varchar(5),
	[year] int,		
	class varchar(30),
	sex char,
	birthdate varchar(20),
	[address] char,
	famsize	varchar(3),
	Pstatus char,
	Medu int,
	Fedu int,
	Mjob varchar(40),
	Fjob varchar(40),
	reason varchar(40),
	guardian varchar(20),
	traveltime int,
	studytime int,	
	failures int,
	schoolsup varchar(3),
	famsup varchar(3),
	paid varchar(3),
	activities varchar(3),
	nursery varchar(3),
	higher	varchar(3),
	internet varchar(3),
	romantic varchar(3),
	famrel int,
	freetime int,
	goout int,
	Dalc int,	
	Walc int,
	health int, 
	absences int,
	P1 int,
	P2 int,
	P3 int
)

-- Para cada ficheiro
-- Mudar diretório para diretório local da pasta students e respetivo ficheiro
bulk insert dbo.student
from 'C:\Users\tiago\Documents\SQL Server Management Studio\student\2017 student-MAT1.csv'
with (
	firstrow = 2,
	fieldterminator = ';',
	rowterminator = '\n'
)

select count(*) from dbo.Student
select * from dbo.Student

