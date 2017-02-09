SET ANSI_PADDING            ON
SET ANSI_WARNINGS           ON
SET ARITHABORT              ON
SET CONCAT_NULL_YIELDS_NULL ON
SET ANSI_NULLS              ON
SET QUOTED_IDENTIFIER       ON
SET NUMERIC_ROUNDABORT      OFF 
GO

SET NOCOUNT ON;
GO

USE RabbitMQTest;
GO

IF EXISTS(SELECT 1 FROM sys.procedures WHERE object_id = OBJECT_ID('rmq.pr_clr_InitialiseRabbitMq'))
BEGIN
  DROP PROCEDURE rmq.pr_clr_InitialiseRabbitMq;
END
GO

CREATE PROCEDURE rmq.pr_clr_InitialiseRabbitMq
AS
EXTERNAL NAME  [RabbitMQ.SqlServer].[RabbitMQSqlClr.RabbitMQSqlServer].[pr_clr_InitialiseRabbitMq];
GO

IF EXISTS(SELECT 1 FROM sys.procedures WHERE object_id = OBJECT_ID('rmq.pr_clr_ReloadRabbitEndpoints'))
BEGIN
  DROP PROCEDURE rmq.pr_clr_ReloadRabbitEndpoints;
END
GO

CREATE PROCEDURE rmq.pr_clr_ReloadRabbitEndpoints
AS
EXTERNAL NAME  [RabbitMQ.SqlServer].[RabbitMQSqlClr.RabbitMQSqlServer].[pr_clr_ReloadRabbitEndpoints];
GO

IF EXISTS(SELECT 1 FROM sys.procedures WHERE object_id = OBJECT_ID('rmq.pr_clr_PostRabbitMsg'))
BEGIN
  DROP PROCEDURE rmq.pr_clr_PostRabbitMsg;
END
GO

CREATE PROCEDURE rmq.pr_clr_PostRabbitMsg @EndpointID int, @Message nvarchar(max)
AS
EXTERNAL NAME  [RabbitMQ.SqlServer].[RabbitMQSqlClr.RabbitMQSqlServer].[pr_clr_PostRabbitMsg];
GO


--finally a wrapper Post Message proc, not really necessary, but useful for catching errors etc.

IF NOT EXISTS(SELECT 1 FROM sys.procedures WHERE object_id = OBJECT_ID('rmq.pr_PostRabbitMsg'))
BEGIN
  EXEC('CREATE PROCEDURE rmq.pr_PostRabbitMsg AS SET NOCOUNT ON;');
END
GO

ALTER PROCEDURE rmq.pr_PostRabbitMsg @Message nvarchar(max), @EndpointID int = -1
AS
BEGIN
  SET NOCOUNT ON;
  BEGIN TRY
    EXEC rmq.pr_clr_PostRabbitMsg  @EndpointID = @EndpointID, @Message = @Message;
  END TRY
  BEGIN CATCH
    DECLARE @errMsg nvarchar(max);
    DECLARE @errLine int;
    SELECT @errMsg = ERROR_MESSAGE(), @errLine = ERROR_LINE();
    RAISERROR('Error: %s at line: %d', 16, -1, @errMsg, @errLine);
  END CATCH
END