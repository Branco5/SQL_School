
CREATE MASTER KEY ENCRYPTION 
BY PASSWORD = 'Master';
GO


CREATE CERTIFICATE LoginCert
With subject='Login';
GO


CREATE SYMMETRIC KEY LoginKey
WITH Algorithm = AES_256  
ENCRYPTION BY CERTIFICATE LoginCert;
GO

-- Ecriptar
ALTER TABLE dbo.LoginDetails ADD EncryptedEmail VarBinary(256), EncryptedPass VarBinary(256);
GO
SELECT * FROM dbo.LoginDetails;


OPEN SYMMETRIC KEY LoginKey DECRYPTION BY CERTIFICATE LoginCert;


UPDATE dbo.LoginDetails
SET EncryptedEmail = 
	ENCRYPTBYKEY(KEY_GUID('LoginKey'),Email),
	EncryptedPass = ENCRYPTBYKEY(KEY_GUID('LoginKey'), Pass)

CLOSE SYMMETRIC KEY LoginKey;
GO



--Apagar colunas sensíveis
alter table dbo.LoginDetails
drop column pass, email

SELECT * FROM dbo.LoginDetails;



-- Obter informação encriptada
OPEN SYMMETRIC KEY LoginKey DECRYPTION BY CERTIFICATE LoginCert;
GO

SELECT CONVERT(VARCHAR(50),DECRYPTBYKEY(EncryptedEmail)) 'Decrypted Email', CONVERT(VARCHAR(50),DECRYPTBYKEY(EncryptedPass)) as 'Decrypted Pass'
FROM dbo.LoginDetails

CLOSE SYMMETRIC KEY LoginKey;
GO