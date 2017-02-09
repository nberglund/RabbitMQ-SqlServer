using System;
using System.Collections.Generic;
using System.Data.SqlClient;
using System.Linq;
using System.Text;
using System.Threading.Tasks;

namespace RabbitMQSqlClr.HelperClasses
{
  internal class RemoteEndpoint
  {
    internal int EndpointId { get; set;}
    internal string AliasName { get; set; }
    internal string ServerName { get; set; }
    internal int Port { get; set; }
    internal string VHost { get; set; }
    internal string LoginName { get; set; }
    internal string LoginPassword { get; set; }
    internal string Exchange { get; set; }
    internal string RoutingKey { get; set; }
    internal int ConnectionChannels { get; set; }
    internal bool IsEnabled { get; set; }

    public string ConnectionString { get { return CreateConnectionString(); } }


    internal RemoteEndpoint()
    {

    }

    internal RemoteEndpoint(SqlDataReader dr)
    {

      EndpointId = dr.GetInt32(0);
      AliasName = dr.GetString(1);
      ServerName = dr.GetString(2);
      Port = dr.GetInt32(3);
      VHost = dr.GetString(4);
      LoginName = dr.GetString(5);
      LoginPassword = dr.GetString(6);
      Exchange = dr.GetString(7);
      RoutingKey = dr[8] != DBNull.Value ? dr.GetString(8) : null;
      ConnectionChannels = dr.GetInt32(9);
      IsEnabled = dr.GetBoolean(10);

    }

    string CreateConnectionString()
    {

      //"amqp://rabbitAdmin:rabbitAdminPwd@fpnieberg2/operator6000";
      StringBuilder connBuilder = new StringBuilder();
      connBuilder.Append("amqp://");
      connBuilder.Append(LoginName);
      connBuilder.Append(":");
      connBuilder.Append(LoginPassword);
      connBuilder.Append("@");
      connBuilder.Append(ServerName);
      connBuilder.Append(":");
      connBuilder.Append(Port.ToString());
      connBuilder.Append("/");
      connBuilder.Append(VHost);

      return connBuilder.ToString();

    }

  }
}
