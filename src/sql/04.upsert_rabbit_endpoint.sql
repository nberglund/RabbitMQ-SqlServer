

-- SCRIPT for adding RabbitMQ endpoint


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

EXEC rmq.pr_UpsertRabbitEndpoint @Alias = 'rabbitEp1',
								 @ServerName = 'RabbitServer',
								 @Port = 5672,
								 @VHost = 'testHost',
								 @LoginName = 'rabbitAdmin',
								 @LoginPassword = 'some_secret_password',
								 @Exchange = 'amq.topic',
								 @RoutingKey = '#',
								 @ConnectionChannels = 5,
								 @IsEnabled = 1