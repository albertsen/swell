defmodule Swell.Messaging.Topology do
  require Logger
  alias Swell.Messaging.Manager

  def set_up() do
    {:ok, channel} = Manager.open_channel()

    try do
      Application.get_env(:swell, :messaging)
      |> set_up(channel)
    rescue
      err in _ ->
        Logger.error(Exception.format(:error, err, __STACKTRACE__))
        raise err
    after
      Manager.close_channel(channel)
    end

    :ok
  end

  defp set_up(_opts = [topology: topology], chann), do: set_up_topology(topology, chann)

  defp set_up_topology(toploogy, chann) when is_map(toploogy) do
    Enum.each(toploogy, fn {exchange, queues} ->
      :ok = AMQP.Exchange.declare(chann, exchange, :fanout, durable: true)

      Enum.each(queues, fn {queue, consumer_module, worker_count} ->
        {:ok, _} = AMQP.Queue.declare(chann, queue, durable: true)
        :ok = AMQP.Queue.bind(chann, queue, exchange)

        Swell.WorkerSupervisor.start_workers(
          Swell.Messaging.Consumer,
          {queue, consumer_module},
          worker_count
        )
      end)
    end)
  end
end
