defmodule Swell.Queue.Manager do

  @me __MODULE__
  @exchange "workflow"
  use GenServer
  require Logger

  def start_link(_) do
    GenServer.start(@me, nil, name: @me)
  end

  def open_channel() do
    GenServer.call(@me, :open_channel)
  end
  def consume(channel, routing_keys, queue)
    when is_list(routing_keys) and is_binary(queue) do
      {:ok, _} = AMQP.Queue.declare(channel, queue, durable: true)
      for key <- routing_keys do
        AMQP.Queue.bind(channel, queue, @exchange, routing_key: key)
      end
    {:ok, _} = AMQP.Basic.consume(channel, queue)
  end

  def cancel(channel, consumer_tag) do
    AMQP.Basic.cancel(channel, consumer_tag)
  end

  def publish(channel, routing_key, payload) do
    msg = :erlang.term_to_binary(payload)
    Logger.debug("Message size: #{byte_size(msg)}")
    :ok = AMQP.Basic.publish(
      channel,
      @exchange,
      routing_key,
      msg,
      persistent: true)
  end

  def ack(channel, delivery_tag) do
    AMQP.Basic.ack(channel, delivery_tag)
  end

  # Server (callbacks)

  @impl GenServer
  def init(_) do
    {:ok, connection} = AMQP.Connection.open()
    {:ok, channel} = AMQP.Channel.open(connection)
    AMQP.Exchange.declare(channel, "workflow", :direct)
    {:ok, connection}
  end

  @impl GenServer
  def handle_call(:open_channel, _from, connection) do
    {:ok, channel} = AMQP.Channel.open(connection)
    AMQP.Basic.qos(channel, prefetch_count: 1)
    {:reply, channel, connection}
  end

end
