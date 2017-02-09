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
--drop table evt.tb_RemoteServer
SET NOCOUNT ON;

-- table for various settings, in our example will just hold a connection-string to the
-- local database
IF NOT EXISTS(SELECT 1 FROM sys.tables WHERE object_id = OBJECT_ID('rmq.tb_RabbitSetting'))
BEGIN
  CREATE TABLE rmq.tb_RabbitSetting
  (
    SettingID int NOT NULL,
	SettingIntValue int NULL,
	SettingStringValue nvarchar(4000) NULL,
	CONSTRAINT [pk_RabbitSetting] PRIMARY KEY CLUSTERED
    (
      [SettingID]
    )
  )
END
GO

-- table to hold rabbit endpoints, i.e. what and how to connect to
IF NOT EXISTS (SELECT 1 FROM sys.tables WHERE object_id = OBJECT_ID('rmq.tb_RabbitEndpoint'))
BEGIN
  CREATE TABLE rmq.tb_RabbitEndpoint
  (
    EndpointID int identity not null,
    AliasName nvarchar(128) NOT NULL,
    ServerName varchar(512) NOT null,
    Port int NOT NULL CONSTRAINT df_RabbitEndpoint_Port DEFAULT 5672, 
    VHost nvarchar(256) NOT NULL CONSTRAINT df_RabbitEndpoint_VHost DEFAULT '/', 
    LoginName varchar(256) NOT NULL,
    LoginPassword varbinary(128) NOT NULL,
    Exchange varchar(128) NOT NULL,
    RoutingKey varchar(256) NULL, -- if the exchange is amq.topic, we should have a routing key
	ConnectionChannels int NOT NULL CONSTRAINT df_RabbitEndpoint_ConnectionChannels DEFAULT 5,-- how many channels per connection
	IsEnabled bit NOT NULL CONSTRAINT df_RemoteServer_IsEnabled DEFAULT 1,
    CONSTRAINT [pk_EndpointID] PRIMARY KEY CLUSTERED
    (
      [EndpointID]
    )
  )
END
GO

--Create proc if it does not exist
-- proc for getting local connection-string (local conn string should have an ID of 1)
IF (OBJECT_ID(N'[rmq].[pr_GetLocalDBConnString]') IS NULL)
BEGIN
  EXEC('CREATE PROCEDURE [rmq].[pr_GetLocalDBConnString] AS SET NOCOUNT ON;');
END
GO	

ALTER PROCEDURE rmq.pr_GetLocalDBConnString @ConnString nvarchar(512) OUT
AS

SET NOCOUNT ON;

 SELECT @ConnString = SettingStringValue
 FROM rmq.tb_RabbitSetting
 WHERE SettingID = 1;

GO



--proc to create / update a rabbit endpoint - i.e. a connection on where to send data to
IF (OBJECT_ID(N'[rmq].[pr_UpsertRabbitEndpoint]') IS NULL)
BEGIN
  EXEC('CREATE PROCEDURE [rmq].[pr_UpsertRabbitEndpoint] AS SET NOCOUNT ON;');
END
GO

ALTER PROCEDURE rmq.pr_UpsertRabbitEndpoint   @Alias varchar(256), 
											  @ServerName varchar(512),
											  @Port int = 5672,
											  @VHost nvarchar(256) = '/',
											  @LoginName varchar(256),
											  @LoginPassword nvarchar(256),
											  @Exchange varchar(128),
											  @RoutingKey varchar(256),
											  @ConnectionChannels int = 5,
											  @IsEnabled bit = 1
AS

SET NOCOUNT ON;

DECLARE @errMsg nvarchar(max); /*this is used to set an explanatory error message BEFORE you call something, 
                                 it is what we previously used to put inside our RAISERROR's*/


BEGIN TRY

--vary basic proc, no validations etc.

--poor mans encryption
DECLARE @pwd varbinary(128) = CAST(@LoginPassword AS varbinary(128));

SET @errMsg = 'Merging into rmq.tb_RabbitEndpoint';
MERGE rmq.tb_RabbitEndpoint AS tgt
USING(SELECT @Alias AS AliasName, @ServerName AS ServerName, @Port AS Port, @VHost AS VHost, 
             @LoginName AS LoginName, @pwd AS LoginPassword, @Exchange AS Exchange, 
			 @RoutingKey AS RoutingKey, @ConnectionChannels AS ConnectionChannels, @IsEnabled AS IsEnabled) AS src
ON(tgt.AliasName = src.AliasName)
WHEN NOT MATCHED THEN
  INSERT(AliasName, ServerName, Port, VHost, LoginName, LoginPassword, Exchange, RoutingKey, ConnectionChannels, IsEnabled)
  VALUES(src.AliasName, src.ServerName, src.Port, src.VHost, src.LoginName, src.LoginPassword, src.Exchange, src.RoutingKey, 
         src.ConnectionChannels, src.IsEnabled)
WHEN MATCHED THEN
  UPDATE
    SET ServerName = src.ServerName, 
	    Port = src.Port, 
		VHost = src.VHost, 
		LoginName = src.LoginName, 
		LoginPassword = src.LoginPassword, 
		Exchange = src.Exchange, 
		RoutingKey = src.RoutingKey, 
		ConnectionChannels = src.ConnectionChannels, 
		IsEnabled = src.IsEnabled;

END TRY
BEGIN CATCH
  DECLARE @thisProc nvarchar(256) = 'rmq.pr_UpsertRabbitEndpoint'; --used for error messages
  DECLARE @sysErrMsg varchar(max);  -- used to set customised error messages
  DECLARE @errSev int; -- error severity
  DECLARE @errState int; -- error state

  --error handling code
  SELECT @sysErrMsg = ERROR_MESSAGE(), @errSev = ERROR_SEVERITY(), @errState = ERROR_STATE()
     
  --re-raise upstream
  RAISERROR('Error in %s: %s. %s.', @errSev, @errState, @thisProc, @errMsg, @sysErrMsg)


END CATCH
GO

--proc to retrieve rabbit endpoints
IF (OBJECT_ID(N'[rmq].[pr_GetRabbitEndpoints]') IS NULL)
BEGIN
  EXEC('CREATE PROCEDURE [rmq].[pr_GetRabbitEndpoints] AS SET NOCOUNT ON;');
END
GO	

ALTER PROCEDURE rmq.pr_GetRabbitEndpoints
AS

SET NOCOUNT ON;

SELECT EndpointID, 
       AliasName, 
	   ServerName, 
	   Port, 
	   VHost, 
	   LoginName, 
	   CAST(LoginPassword AS nvarchar(256)) AS LoginPassword, 
	   Exchange, 
	   RoutingKey, 
	   ConnectionChannels, 
	   IsEnabled
FROM rmq.tb_RabbitEndpoint
WHERE IsEnabled = 1;

GO
 									  