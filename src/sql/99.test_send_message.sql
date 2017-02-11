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


-- run the following statement after a deployment of the assembly
-- you only need to run it after the assembly has been deployed or altered
-- it is not entirely necessary to do it, but it improves performance for the
-- first call into the assembly 
EXEC rmq.pr_clr_InitialiseRabbitMq;


--before you send the message ensure you have a queue bound
--to the exchange you use as endpoint
--do some processing that will send message
EXEC dbo.pr_SomeProcessingStuff @id = 101




