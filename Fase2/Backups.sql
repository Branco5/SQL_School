--EXEMPLO PROCESSO DE BACKUP/RESTORE

-- Full backup
BACKUP DATABASE [Fase2] 
TO  DISK = N'C:\Program Files\Microsoft SQL Server\MSSQL15.MSSQLSERVER\MSSQL\Backup\Fase2.bak' 
WITH NOFORMAT, NOINIT,  NAME = N'Fase2-Full Database Backup', SKIP, NOREWIND, NOUNLOAD,  STATS = 10
GO

--transação 1
insert into dbo.languages values ('l1'),  ('l2'),  ('l3'),  ('l4'),  ('l5')

--Backup parcial
BACKUP DATABASE [Fase2] TO  DISK = 
N'C:\Program Files\Microsoft SQL Server\MSSQL15.MSSQLSERVER\MSSQL\Backup\Fase2Diferential.bak' 
WITH  DIFFERENTIAL , NOFORMAT, NOINIT,  
NAME = N'Fase2-Full Database Backup', SKIP, NOREWIND, NOUNLOAD,  STATS = 10
GO

--transação 2
insert into dbo.languages values ('l6'),  ('l7')

-- log backup
BACKUP LOG [Fase2] TO  DISK = 
N'C:\Program Files\Microsoft SQL Server\MSSQL15.MSSQLSERVER\MSSQL\Backup\Fase2Log.trn' 
WITH NOFORMAT, NOINIT,  NAME = N'Fase2Log1', SKIP, NOREWIND, NOUNLOAD,  STATS = 10
GO

--transação 3
insert into dbo.languages values ('l8'),  ('l9')

-- PROCESSO DE RECUPERAÇÃO

-- Backup do tail log
USE [master]
BACKUP LOG [Fase2] TO  
DISK = N'C:\Program Files\Microsoft SQL Server\MSSQL15.MSSQLSERVER\MSSQL\Backup\Fase2_tail.trn' 
WITH NO_TRUNCATE, NOFORMAT, NOINIT,  NAME = N'Fase2_LogBackup_2021-02-18_05-09-03', NOSKIP, NOREWIND, NOUNLOAD,  NORECOVERY ,  STATS = 5

-- Recuperar até ao full backup
RESTORE DATABASE [Fase2] FROM  DISK = N'C:\Program Files\Microsoft SQL Server\MSSQL15.MSSQLSERVER\MSSQL\Backup\Fase2.bak' 
WITH  FILE = 2,  NORECOVERY,  NOUNLOAD,  STATS = 5

-- Recuperar até ao partial backup (transação 1)
RESTORE DATABASE [Fase2] FROM  DISK = N'C:\Program Files\Microsoft SQL Server\MSSQL15.MSSQLSERVER\MSSQL\Backup\Fase2Diferential.bak' 
WITH  FILE = 1,  NORECOVERY,  NOUNLOAD,  STATS = 5

-- Recuperar até ao log backup (transação 2)
RESTORE LOG [Fase2] FROM  DISK = N'C:\Program Files\Microsoft SQL Server\MSSQL15.MSSQLSERVER\MSSQL\Backup\Fase2Log.trn' 
WITH  FILE = 1,  NOUNLOAD,  STATS = 5
GO

--Recuperar até ao tail (transação 3)
RESTORE LOG [Fase2] FROM  DISK = N'C:\Program Files\Microsoft SQL Server\MSSQL15.MSSQLSERVER\MSSQL\Backup\Fase2_tail.trn' 
WITH RECOVERY