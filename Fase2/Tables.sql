drop database fase2

create database Fase2;
use Fase2;

create table Languages(
	id tinyint primary key identity,
	[language] varchar(2)
)

create table YesNo(
	id tinyint identity primary key,
	descript varchar(3)
)

create table HighLow(
	id tinyint primary key,
)

create table HighLowTrans(
	id tinyint references HighLow(id),
	idlang tinyint references Languages(id),
	descript varchar(15)
)

create table ErrorLog(
	id int identity primary key,
	[user] varchar(100),
	error varchar(100),
	[timestamp] datetime2
)

create table [User](
	id int identity primary key,
	sex char check(sex in ('M', 'F')),
	birth date,
	[name] varchar(100)
)

create table TimeGaps(
	id tinyint identity primary key,
	gap varchar(30)
)

create table Student( 
	id int primary key references [User](id),
	studentNr int unique not null,
	failures tinyint,			
	traveltime tinyint references TimeGaps(id),
	studytime tinyint references TimeGaps(id),	
	goout tinyint references HighLow(id), 
	DayAlc tinyint references HighLow(id), 
	WkndAlc tinyint references HighLow(id), 
	freetime tinyint references HighLow(id), 
	health tinyint references HighLow(id), 
	absences tinyint,
	schoolsup tinyint references YesNo(id),	
	paid tinyint references YesNo(id),
	activities tinyint references YesNo(id),
	nursery tinyint references YesNo(id),
	higher tinyint references YesNo(id),
	internet tinyint references YesNo(id),
	romantic tinyint references YesNo(id)
)

create table FamSize(
	id tinyint primary key,
)

create table FamSizeTrans(
	id tinyint references FamSize(id),
	idLanguage tinyint references languages(id),
	[size] varchar(30)
)

create table ParntStatus(
	id tinyint primary key,
)

create table ParntStatusTrans(
	id tinyint references ParntStatus(id),
	idLanguage tinyint references languages(id),
	[status] varchar(30)
)

create table StudentFamilyInfo(
	idStudent int references Student(id) not null,
	parentstatus tinyint references ParntStatus(id),
	famsize	tinyint references FamSize(id),
	famsup tinyint references YesNo(id),
	famrel tinyint references HighLow(id), 
	primary key(idStudent)
)

create table FamType(
	id tinyint primary key,
)

create table FamTypeTranslation(
	id tinyint references FamType(id),
	idLanguage tinyint references languages(id),
	[type] varchar(50)
)

create table Education(
	id tinyint primary key
)

create table EducationTranslation(
	id tinyint references Education(id),
	idLanguage tinyint references languages(id),
	education varchar(40)
)

create table Job(
	id tinyint primary key
)

create table JobTranslation(
	id tinyint references Job(id),
	idLanguage tinyint references languages(id),
	job varchar(50)
)

create table FamilyMember(
	idStudent int references [Student](id),	
	[type] tinyint not null references FamType(id),
	job tinyint references Job(id),
	education tinyint references Education(id),
	primary key (idStudent, [type])
)

create table Guardian(
	id int references [User](id),
	idStudent int references [Student](id),
	[type] tinyint references FamType(id),
	primary key (id)	
)

create table [Address](
	id int identity primary key,
	[description] varchar(50),
	[type] varchar(6)
)

create table UserAddress(	
	idUser int references [User] (id),
	idAddress int references [Address] (id),
	mainAddress tinyint references YesNo(id),	
	primary key (idUser, idAddress)
)

create table Discipline(
	id tinyint identity primary key,
	[name] varchar(30) not null unique
)

create table School(
	id tinyint identity primary key,
	[name] varchar(30) unique not null,
)

create table Reason(
	id tinyint primary key,	
)

create table ReasonTranslation(
	id tinyint references Reason(id),
	idLang tinyint references dbo.Languages(id),
	reason varchar(50)
	primary key (id, idLang)
)

create table SchoolStudent(
	id int identity primary key,
	idStudent int references Student(id),
	idSchool tinyint references school(id),
	schoolYear smallint not null,
	reason tinyint references Reason(id)
)

create table ClosedRegistrations(
	id int identity primary key,
	idSchoolStudent int references SchoolStudent(id),
	idDiscipline tinyint references Discipline(id)
)

create table ClosedGrades(
	grade1 tinyint,
	grade2 tinyint,
	grade3 tinyint,
	registid int references ClosedRegistrations(id),
	primary key(registid)		
)

create table LoginDetails(
	email varchar(100) primary key,
	pass varchar(128),	
	userID int references [User](id)
)

create table Token(
	id int identity primary key,
	token int,
	[time] datetime2,
	email varchar(100)
)

create table PasswordUpdateEmail(
	id int identity primary key,
	msg varchar(50),
	email varchar(100) references loginDetails(email)
)


