
namespace RabbitMQSqlClr
{
  public partial class RabbitMQSqlServer
  {
    public static void pr_clr_ReloadRabbitEndpoints()
    {
      try
      {
        if(!_isInitialised)
        {
          pr_clr_InitialiseRabbitMq();
          return;
        }
        LoadRabbitEndpoints();
      }
      catch
      {
        throw;
      }

    }
  }
}
