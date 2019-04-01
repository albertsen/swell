defmodule Swell.AmqpManager do

  @me __MODULE__
  @queues ~w{steps results errors}
  use GenServer
  require Logger

  def start_link(_) do
    GenServer.start(@me, nil, name: @me)
  end

  def open_channel() do
    GenServer.call(@me, :open_channel)
  end

  def consume(channel, queue) do
    AMQP.Basic.consume(channel, queue)
  end

  def publish(channel, queue, payload) do
    AMQP.Basic.publish(channel, "", queue, payload, persistent: true)
  end

  # Server (callbacks)

  @impl GenServer
  def init(_) do
    {:ok, connection} = AMQP.Connection.open()
    {:ok, channel} = AMQP.Channel.open(connection)
    @queues |> Enum.each(&(AMQP.Queue.declare(channel, &1, durable: true)))
    {:ok, {connection, channel}}
  end

  @impl GenServer
  def handle_call(:open_channel, _from, {connection, channel}) do
    {:ok, channel} = AMQP.Channel.open(connection)
    AMQP.Basic.qos(channel, prefetch_count: 1)
    {:reply, channel, {connection, channel}}
  end

end
