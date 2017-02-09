using System;
using System.Text;

namespace RabbitMQSqlClr
{
  public partial class RabbitMQSqlServer
  {
    public static void pr_clr_PostRabbitMsg(int endPointId, string msgToPost)
    {
      try
      {
        if(endPointId == 0)
        {
          throw new ApplicationException("EndpointId cannot be 0");
        }

        if (!_isInitialised)
        {
          pr_clr_InitialiseRabbitMq();
        }

        var msg = Encoding.UTF8.GetBytes(msgToPost);
        if (endPointId == -1)
        {
          foreach (var rep in _remoteEndpoints)
          {
            var exch = rep.Value.Exchange;
            var topic = rep.Value.RoutingKey;
            foreach (var pub in _rabbitPublishers.Values)
            {
              pub.Post(exch, msg, topic);
            }
          }
        }
        else
        {
          RabbitPublisher pub;

          if (_rabbitPublishers.TryGetValue(endPointId, out pub))
          {
            pub.Post(_remoteEndpoints[endPointId].Exchange, msg, _remoteEndpoints[endPointId].RoutingKey);
          }
          else
          {
            throw new ApplicationException($"EndpointId: {endPointId}, does not exist");
          }
        }

      }
      catch
      {
        throw;
      }


    }

  }
}
