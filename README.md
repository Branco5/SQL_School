# Ordem de execução dos ficheiros

Fase1: OldData (mudar diretório de bulk insert para diretório local da pasta students e respetivo ficheiro) 
      - Tables - Migrate - MigrateTest - Program - View - ProgramTest

Fase2: Tables - Program - GenerateData - Index - IndexTest - Views - Permission - Encryption

Extras: MongoDB, Filegroups, Backups
