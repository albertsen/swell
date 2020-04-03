defmodule Swell.Messaging.Manager do
  @me __MODULE__
  use GenServer
  require Logger
  alias Swell.Messaging.ConnectionFactory

  def start_link(_) do
    GenServer.start(@me, nil, name: @me)
  end

  def consume(channel, queue) when is_binary(queue) do
    {:ok, _} = AMQP.Basic.consume(channel, queue)
  end

  def cancel(channel, consumer_tag) do
    AMQP.Basic.cancel(channel, consumer_tag)
  end

  def publish(channel, exchange, message) do
    :ok =
      AMQP.Basic.publish(
        channel,
        exchange,
        "",
        message,
        persistent: true
      )
  end

  def ack(channel, delivery_tag) do
    AMQP.Basic.ack(channel, delivery_tag)
  end

  @impl GenServer
  def init(_) do
    channel = ConnectionFactory.open_channel()

    try do
      Application.get_env(:swell, :messaging)
      |> setup(channel)
    rescue
      err in _ ->
        Logger.error(Exception.format(:error, err, __STACKTRACE__))
        AMQP.Channel.close(channel)
        raise err
    end

    {:ok, nil}
  end

  defp setup(_opts = [topology: topology], chann), do: setup_topology(topology, chann)

  defp setup_topology(toploogy, chann) when is_map(toploogy) do
    Enum.each(toploogy, fn {exchange, queues} ->
      exchange = to_string(exchange)
      :ok = AMQP.Exchange.declare(chann, exchange, :fanout, durable: true)

      Enum.each(queues, fn {queue, consumer_module, worker_count} ->
        queue = to_string(queue)
        {:ok, _} = AMQP.Queue.declare(chann, queue, durable: true)
        :ok = AMQP.Queue.bind(chann, queue, exchange)

        Swell.WorkerSupervisor.start_workers(
          Swell.Messaging.ComsumerWorker,
          {queue, consumer_module},
          worker_count
        )
      end)
    end)
  end
end
