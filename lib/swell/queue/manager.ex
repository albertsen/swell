defmodule Swell.Queue.Manager do

  @me __MODULE__
  @queues ~w{steps transitions errors done}
  use GenServer
  require Logger

  def start_link(_) do
    GenServer.start(@me, nil, name: @me)
  end

  def open_channel() do
    GenServer.call(@me, :open_channel)
  end

  def consume(channel, queue) do
    {:ok, _} = AMQP.Basic.consume(channel, queue)
  end

  def publish(channel, queue, payload) do
    :ok = AMQP.Basic.publish(
      channel,
      "",
      queue,
      :erlang.term_to_binary(payload),
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
    @queues |> Enum.each(&(AMQP.Queue.declare(channel, &1, durable: true)))
    {:ok, connection}
  end

  @impl GenServer
  def handle_call(:open_channel, _from, connection) do
    {:ok, channel} = AMQP.Channel.open(connection)
    AMQP.Basic.qos(channel, prefetch_count: 1)
    {:reply, channel, connection}
  end

end
