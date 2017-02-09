
-- run the following statement after a deployment of the assembly
EXEC rmq.pr_clr_InitialiseRabbitMq;

--send message
EXEC rmq.pr_PostRabbitMsg @Message = 'Hello World', @EndpointID = 1

