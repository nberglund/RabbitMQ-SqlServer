using System;
using System.Collections.Generic;
using System.Linq;
using System.Text;
using System.Threading.Tasks;
using RabbitMQ.Client;
using System.Threading;
using System.Collections.Concurrent;

namespace RabbitMQSqlClr
{
  internal class RabbitPublisher
  {

    internal IConnection RabbitConn;
    ConnectionFactory _connFactory;
    private string _connString;
    private int _channels;
    internal int RabbitEndpointId;

    readonly ConcurrentStack<IModel> _rabbitChannels = new ConcurrentStack<IModel>();


    internal RabbitPublisher(string amqpConnString, int endPointId, int channels = 5)
    {
      _connString = amqpConnString;
      _channels = channels;
      RabbitEndpointId = endPointId;
    }

    internal bool InternalConnect()
    {
      try
      {
        _connFactory = new ConnectionFactory();
        _connFactory.Uri = _connString;
        _connFactory.AutomaticRecoveryEnabled = true;
        _connFactory.TopologyRecoveryEnabled = true;
        RabbitConn = _connFactory.CreateConnection();
        

        for (int x = 0; x < _channels; x++)
        {
          var ch = RabbitConn.CreateModel();
          _rabbitChannels.Push(ch);
        }

        return true;
      }
      catch(Exception ex)
      {
        return false;
      }
    }


    internal bool Post(string exchange, byte[] msg, string topic)
    {
      IModel value = null;
      int channelTryCount = 0;
      try
      {
   

        while ((!_rabbitChannels.TryPop(out value)) && channelTryCount < 100)
        {
          channelTryCount += 1;
          Thread.Sleep(50);
        }

        if (channelTryCount == 100)
        {
          var errMsg = $"Channel pool blocked when trying to post message to Exchange: {exchange}.";
          throw new ApplicationException(errMsg);
          }

        value.BasicPublish(exchange, topic, false, null, msg);
        _rabbitChannels.Push(value);
        return true;

      }

     
      catch (Exception ex)
      {
        if (value != null)
        {
          _rabbitChannels.Push(value);
        }
        throw;
      }

    }

    internal void Shutdown()
    {
      try
      {
        IModel value;
        while (_rabbitChannels.Count > 0)
        {
          if (!_rabbitChannels.TryPop(out value)) continue;
          value.Close();
          value = null;
        }

        RabbitConn.Close();
      }
      finally
      {
        _rabbitChannels.Clear();
      }
    }

  }
}
