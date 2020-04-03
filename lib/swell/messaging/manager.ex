defmodule Swell.Messaging.Manager do
  @me __MODULE__
  use GenServer
  require Logger

  def start_link(_) do
    GenServer.start(@me, nil, name: @me)
  end

  def open_channel() do
    GenServer.call(@me, :open_channel)
  end

  def close_channel(channel) do
    GenServer.call(@me, {:close_channel, channel})
  end

  def consume(channel, queue) when is_binary(queue) do
    {:ok, _} = AMQP.Basic.consume(channel, queue)
  end

  def cancel(channel, consumer_tag) do
    {:ok, _} = AMQP.Basic.cancel(channel, consumer_tag)
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
    :ok = AMQP.Basic.ack(channel, delivery_tag)
  end

  @impl GenServer
  def init(_) do
    {:ok, _connection} = AMQP.Connection.open()
  end

  @impl GenServer
  def handle_call(:open_channel, _from, connection) do
    res = {:ok, channel} = AMQP.Channel.open(connection)
    :ok = AMQP.Basic.qos(channel, prefetch_count: 1)
    {:reply, res, connection}
  end

  @impl GenServer
  def handle_call({:close_channel, channel}, _from, connection) do
    res = AMQP.Channel.close(channel)
    {:reply, res, connection}
  end

  @impl GenServer
  def terminate(_reason, connection) do
    AMQP.Connection.close(connection)
  end
end
