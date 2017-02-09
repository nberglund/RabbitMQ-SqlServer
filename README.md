# RabbitMQ SqlServer

This is demo code how messages can be sent from Microsoft SQL Server (2005+) to a [RabbitMQ][1] message broker. 

The way it is implemented is by using SQLCLR, .NET running inside the SQL Server engine (SQLCLR was introduced in SQL Server 2005). The code is intended to give an idea how sending messages to RabbitMQ can be implemented. The code is bare minimum, so do not use it in production as is.

## Dependencies

A RabbitMQ client for .NET needs to be referenced, and in the lib folder are sub folders for RabbitMQ clients for [.NET 3.5 (SQL Server 2005, 2008, 2012)][5] and [.NET 4 (SQL Server 2014+)][4] respectively.

### SQL Server 2005 - 2012 (.NET 3.5)

The .NET 3.5 client has been built from source, and compiled for .NET 3.5, as the later .NET clients are all .NET 4. The source for the .NET 3.5 client is [here][2]. The .NET 3.5 client needs the System.Threading.dll for .NET 3.5, which can be found together with the client.

### SQL Server 2014+ (.NET 4)

For SQL Server 2014 and later versions the latest version of [RabbitMQ.Client][3] can be used directly. The lib folder for .NET 4 contains version 4.1.1 (latest stable version at time of writing). For .NET 4 the threading dll is not needed as it is part of the base CLR.

## Source Code

In the *src* folder you find the source code for everything necessary. The Visual Studio  solution file `RabbitMQSqlClr.sln` contains C# SQLCLR solutions for both .NET 3.5 (SQL 2005 - 2012) as well as .NET 4 (SQL 2014+).

> **NOTE: This is demo code, to give an idea how SQL Server can call RabbitMQ. This is NOT production ready code in any shape or form. If the code burns down your house and kills you cat - don't blame me - it is DEMO code.**

The solution contains a test app: `RabbitMQTestApp`, which can be used to test the code outside of SQLCLR.

### SQL

The *src\sql* folder has scripts to:

* Create the test database
* Create the T-SQL database objects
* Create a *localhost* connection string. This is used by the SQLCLR assembly
* Create a connection string for a RabbitMQ endpoint
* Create .NET 3.5 / .NET 4 assemblies.
* Create SQLCLR objects (stored procedures)
* Test the code and send a message.

## Installation

You can install without building the Visual Studio projects, as the script files in the *src\sql* folder contain all you need. To install, run the install scripts in order (01- 06). The 03 and 04 scripts need some manual editing to add an ADO.NET connection string to the local database in 03, and in 04 to enter the RabbitMQ endpoint.

To deploy the SQLCLR assembly you run the 05.5x scripts for SQL Server 2005 - 2012 and 05.14x scripts for SQL Server 2014+. To create the SQLCLR procedures you run the 06 script.

Finally to test it, execute the 99 script


[1]: http://www.rabbitmq.com/
[2]: https://github.com/nberglund/rabbitmq-dotnet-client-3.6.6-stable_net_3.5
[3]: https://www.nuget.org/packages/RabbitMQ.Client/
[4]: https://github.com/nberglund/RabbitMQ-SqlServer/tree/master/lib/NET4
[5]: https://github.com/nberglund/RabbitMQ-SqlServer/tree/master/lib/NET3.5