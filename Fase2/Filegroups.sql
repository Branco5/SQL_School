--Exemplo Filegroups

create database Fase2 
on 
PRIMARY
(FILENAME = 'C:\Users\tiago\Documents\Primary.mdf',
SIZE = 35,
MAXSIZE = 150,
FILEGROWTH = 2),
(NAME = Users, FILENAME = 'D:\Users\tiago\Documents\Users.ndf',
SIZE = 23,
MAXSIZE = 150,
FILEGROWTH = 1),
(NAME = [ReadOnly], FILENAME = 'C:\Users\tiago\Documents\ReadOnly.ndf',
SIZE = 7,
MAXSIZE = 50,
FILEGROWTH = 1),
(NAME = [History], FILENAME = 'E:\Users\tiago\Documents\History.ndf',
SIZE = 25,
MAXSIZE = 150,
FILEGROWTH = 1),
(NAME = UnpredictGrowth, FILENAME = 'E:\Users\tiago\Documents\UnpredictGrowth.ndf',
SIZE = 1,
MAXSIZE = 1000,
FILEGROWTH = 50%)
LOG ON
(NAME = log1, FILENAME = 'C:\Users\tiago\Documents\log.ldf',
SIZE = 100,
MAXSIZE = 1000,
FILEGROWTH = 20);
GO