using System;
using System.Collections.Generic;
using System.Linq;
using System.Text;
using System.Threading.Tasks;
using RabbitMQSqlClr;

namespace RabbitMQTestApp
{
  class Program
  {
    static void Main(string[] args)
    {

      //set the local connection string
      RabbitMQSqlServer.LocalhostConnectionString = "";

      RabbitMQSqlServer.pr_clr_InitialiseRabbitMq();
      Console.WriteLine("Rabbit is initialised. Press any key to send msg");
      Console.ReadLine();
      RabbitMQSqlServer.pr_clr_PostRabbitMsg(-1, "Hello World");
      Console.WriteLine("Message posted. Press any key to exit");
      Console.ReadLine();




    }
  }
}
