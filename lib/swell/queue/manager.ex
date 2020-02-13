defmodule Swell.Queue.Manager do
  @me __MODULE__
  use GenServer
  require Logger
  @exchange "events"

  def start_link(_) do
    GenServer.start(@me, nil, name: @me)
  end

  def open_channel() do
    GenServer.call(@me, :open_channel)
  end

  def consume(channel, queue) when is_binary(queue) do
    {:ok, _} = AMQP.Queue.declare(channel, queue, durable: true)

    AMQP.Queue.bind(channel, queue, @exchange)

    {:ok, _} = AMQP.Basic.consume(channel, queue)
  end

  def cancel(channel, consumer_tag) do
    AMQP.Basic.cancel(channel, consumer_tag)
  end

  def publish(channel, payload) do
    :ok =
      AMQP.Basic.publish(
        channel,
        @exchange,
        "",
        payload,
        persistent: true
      )
  end

  def ack(channel, delivery_tag) do
    AMQP.Basic.ack(channel, delivery_tag)
  end

  # Server (callbacks)

  @impl GenServer
  def init(_) do
    {:ok, connection} = AMQP.Connection.open()
    {:ok, channel} = AMQP.Channel.open(connection)
    AMQP.Exchange.declare(channel, @exchange, :fanout)
    {:ok, connection}
  end

  @impl GenServer
  def handle_call(:open_channel, _from, connection) do
    {:ok, channel} = AMQP.Channel.open(connection)
    AMQP.Basic.qos(channel, prefetch_count: 1)
    {:reply, channel, connection}
  end
end
