using System;
using System.Collections.Generic;
using System.Linq;
using System.Text;
using System.Threading.Tasks;
using System.Data.SqlClient;
using System.Data;
using Microsoft.SqlServer.Server;
using RabbitMQSqlClr.HelperClasses;

namespace RabbitMQSqlClr
{
  public partial class RabbitMQSqlServer
  {
    public static bool _isInitialised = false;
    internal static Dictionary<int, RemoteEndpoint> _remoteEndpoints = new Dictionary<int, RemoteEndpoint>();
    internal static Dictionary<int, RabbitPublisher> _rabbitPublishers = new Dictionary<int, RabbitPublisher>();
    internal static object _lockInitialise = new object();

    //use this if you run from a test app - outside of SQLCLR
    private static string _localhostConnString;

    //so that the local connection string can be set from a calling app
    //only used when running outside of SQLCLR
    public static string LocalhostConnectionString
    {
      get { return _localhostConnString; }
      set { _localhostConnString = value; }

    }

    static RabbitMQSqlServer()
    {
      _isInitialised = false;
    }



    internal static void LoadLocalHost()
    {
      string connString;


      try
      {
        if (SqlContext.IsAvailable)
        {
          connString = "Context Connection = true";
        }
        else
        {
          connString = _localhostConnString;
        }

        using (SqlConnection conn = new SqlConnection(connString))
        {

          using (SqlCommand cmd = conn.CreateCommand())
          {
            cmd.CommandText = "rmq.pr_GetLocalDBConnString";
            cmd.CommandType = CommandType.StoredProcedure;
            cmd.Parameters.Add("@ConnString", SqlDbType.NVarChar, 512);
            cmd.Parameters[0].Direction = ParameterDirection.Output;
            conn.Open();

            cmd.ExecuteNonQuery();

            _localhostConnString = cmd.Parameters[0].Value.ToString();
                        
          }
        }
      }
      catch (Exception ex)
      {
        throw new ApplicationException(ex.Message);
      }
    }

    internal static void Initialise()
    {
      LoadLocalHost();
      LoadRabbitEndpoints();
    }

    internal static void LoadRabbitEndpoints()
    {

      try
      {
        string connString = _localhostConnString;
        var remoteEndpoints = new Dictionary<int, RemoteEndpoint>();
        var removedEndpoints = new List<int>();
        var newEndpoints = new List<int>();
        var oldEndpoints = _remoteEndpoints.Keys.ToList();


        using (SqlConnection conn = new SqlConnection(connString))
        {
          using (SqlCommand cmd = conn.CreateCommand())
          {
            cmd.CommandText = "rmq.pr_GetRabbitEndpoints";
            cmd.CommandType = CommandType.StoredProcedure;

            conn.Open();
            var dr = cmd.ExecuteReader();

            if (dr.HasRows)
            {

              while (dr.Read())
              {
                var re = new RemoteEndpoint(dr);
                remoteEndpoints.Add(re.EndpointId, re);
                _remoteEndpoints.Add(re.EndpointId, re);

              }
            }
          }

          //tear down rabbit publishers
          removedEndpoints = _remoteEndpoints.Keys.Except(remoteEndpoints.Keys).ToList();
          if(removedEndpoints.Any())
          {
            foreach(var id in removedEndpoints)
            {
              RemoteEndpoint e1;
              RabbitPublisher rp1;
              if(_rabbitPublishers.TryGetValue(id, out rp1))
              {
                rp1.Shutdown();
                _rabbitPublishers.Remove(id);
              }

              _remoteEndpoints.Remove(id);

            }
          }

          newEndpoints = _remoteEndpoints.Keys.Except(oldEndpoints).ToList();
          if(newEndpoints.Any())
          {
            foreach(var id in newEndpoints)
            {
             var rep = _remoteEndpoints.Where(ex => ex.Key == id).Select(r => r.Value).FirstOrDefault();
              var rp = new RabbitPublisher(rep.ConnectionString, id);
              _rabbitPublishers.Add(id, rp);
              rp.InternalConnect();
            }
          }


        }

        if (remoteEndpoints.Count == 0)
        {
          //TearDownConnections();
          throw new ApplicationException("No enabled rabbit endpoints exists");
          
        }

      }

      catch (Exception ex)
      {
        throw new ApplicationException(string.Format("Error in: RabbitMQSqlServer.LoadRabbitEndpoints. The error is: Error rabbit endpoints: {0}", ex.Message));
        
      }
    }

    private static void CreateRabbitPublishers()
    {

    }

  }
}
