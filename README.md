# RabbitMQ SqlServer

This is demo code how messages can be sent from Microsoft SQL Server (2005+) to a [RabbitMQ][1] message broker. 

The way it is implemented is by using SQLCLR, .NET running inside the SQL Server engine (SQLCLR was introduced in SQL Server 2005). The code is intended to give an idea how sending messages to RabbitMQ can be implemented. The code is bare minimum, so do not use it in production as is.

## Dependencies

A RabbitMQ client for .NET needs to be referenced, and in the lib folder are sub folders for RabbitMQ clients for .NET 3.5 (SQL Server 2005, 2008, 2012) and .NET 4 (SQL Server 2014+) respectively.

### SQL Server 2005 - 2012 (.NET 3.5)

The .NET 3.5 client has been built from source, and compiled for .NET 3.5, as the later .NET clients are all .NET 4. The source for the .NET 3.5 client is [here][2]. The .NET 3.5 client needs the System.Threading.dll for .NET 3.5 which can be found together with the client.

### SQL Server 2014+ (.NET 4)

For SQL Server 2014 and later versions the latest version of [RabbitMQ.Client][3] can be used directly. The lib folder for .NET 4 contains version 4.1.1 (latest stable version at time of writing). For .NET 4 the threading dll is not needed as it is part of the base CLR.


[1]: http://www.rabbitmq.com/
[2]: https://github.com/nberglund/rabbitmq-dotnet-client-3.6.6-stable_net_3.5
[3]: https://www.nuget.org/packages/RabbitMQ.Client/