-- SCRIPT for setting local connection string
-- SettingID HAS to be 1


USE RabbitMQTest;
GO

SET ANSI_PADDING            ON
SET ANSI_WARNINGS           ON
SET ARITHABORT              ON
SET CONCAT_NULL_YIELDS_NULL ON
SET ANSI_NULLS              ON
SET QUOTED_IDENTIFIER       ON
SET NUMERIC_ROUNDABORT      OFF 
GO

SET NOCOUNT ON;

--set here the connection string, in real life it should be encrypted, but ...
DECLARE @connString nvarchar(256) = 'server=PCMDb1; database=RabbitMQTest; uid=sa; pwd=secret_stuff';

DECLARE @tb_Setting TABLE(SettingID int, SettingIntValue int, SettingStringValue nvarchar(4000));

INSERT INTO @tb_Setting(SettingID, SettingStringValue)
VALUES(1, @connString);

MERGE rmq.tb_RabbitSetting AS tgt
USING(SELECT SettingID, SettingStringValue FROM @tb_Setting) AS src
ON(tgt.SettingID = src.SettingID)
WHEN NOT MATCHED THEN
  INSERT(SettingID, SettingStringValue)
  VALUES(src.SettingID, src.SettingStringValue)
WHEN MATCHED THEN
  UPDATE
    SET tgt.SettingStringValue = src.SettingStringValue;
GO


/*

SELECT * FROM rmq.tb_RabbitSetting

*/