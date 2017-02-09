
/*
  This script creates a test database
  for testing of sending data to RabbitMQ
*/

USE master;
GO

SET NOCOUNT ON;
GO

IF EXISTS(SELECT 1 FROM sys.databases WHERE name = 'RabbitMQTest')
BEGIN
  DROP DATABASE RabbitMQTest;
END

CREATE DATABASE RabbitMQTest;
GO

USE RabbitMQTest;

ALTER DATABASE RabbitMQTest
SET TRUSTWORTHY ON;

/*
  This role will be used as authorization (owner)
  for the RabbitMq assemblies.
*/
IF NOT EXISTS(SELECT 1 FROM sys.database_principals WHERE name = 'rmq')
BEGIN
  CREATE ROLE rmq
  AUTHORIZATION dbo;
END


IF NOT EXISTS(SELECT 1 FROM  sys.schemas WHERE name = 'rmq')
BEGIN
  EXECUTE('CREATE SCHEMA rmq;');
END

-- check whether CLR is enabled
DECLARE @isCLREnabled int;
DECLARE @spConfigureTab TABLE (name varchar(256), minimum int, maximum int, config_value int, run_value int)

--check if clr is enabled, if not return out - as it cannot be done dynamically
INSERT INTO @spConfigureTab
EXEC sp_Configure 'CLR Enabled';

SELECT @isCLREnabled = run_value
FROM @spConfigureTab;

IF(@isCLREnabled = 0)
BEGIN
  RAISERROR('The database has been created, BUT CLR is not enabled on this Sql Server instance. To enable, execute "sp_configure ''CLR Enabled'', 1 GO RECONFIGURE GO".', 16, -1)
  RETURN;
END

PRINT 'Database created without any issues!'
GO

