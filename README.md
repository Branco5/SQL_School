# Description

Files used in the development of an SQL Server database to store and manipulate mock student data.

Besides the tables themselves I also implemented different stored procedures, functions, views, triggers, user permissions, custom table indexations to improve performance of data retrieval, transaction isolation levels and experimented with different types of backups.


# File execution order

Fase1: OldData (change directory of bulk insert to local directory of students folder and respective file) 
      - Tables - Migrate - MigrateTest - Program - View - ProgramTest

Fase2: Tables - Program - GenerateData - Index - IndexTest - Views - Permission - Encryption
