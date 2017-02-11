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


IF NOT EXISTS(SELECT 1 FROM sys.procedures WHERE object_id = OBJECT_ID('dbo.pr_SomeProcessingStuff'))
BEGIN
  EXEC('CREATE PROCEDURE dbo.pr_SomeProcessingStuff AS SET NOCOUNT ON;');
END
GO

ALTER PROCEDURE dbo.pr_SomeProcessingStuff @id int
AS
BEGIN
  SET NOCOUNT ON;
  BEGIN TRY
    --create a variable for the endpoint
    DECLARE @endPointId int;
    --create a variable for the message
    DECLARE @msg nvarchar(max) = '{'
    --do important stuff, and collect data for the message
    SET @msg = @msg + '"Id":' + CAST(@id AS varchar(10)) + ','
    -- do some more stuff
    SET @msg = @msg + '"FName":"Hello",';
    SET @msg = @msg + '"LName":"World"';
    SET @msg = @msg + '}';

    --do more stuff
    -- get the endpoint id from somewhere, based on something
    SELECT @endPointId = 1;
    --here is the hook-point
    --call the procedure to send the message
    EXEC rmq.pr_PostRabbitMsg @Message = @msg, @EndpointID = @endPointId;
  END TRY
  BEGIN CATCH
    DECLARE @errMsg nvarchar(max);
    DECLARE @errLine int;
    SELECT @errMsg = ERROR_MESSAGE(), @errLine = ERROR_LINE();
    RAISERROR('Error: %s at line: %d', 16, -1, @errMsg, @errLine);
  END CATCH
END