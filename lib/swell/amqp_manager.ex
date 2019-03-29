defmodule Swell.AmqpManager do

  @me __MODULE__
  use GenServer
  require Logger

  def start_link(name) do
    GenServer.start(@me, nil, name: @me)
  end

  def open_channel(queues) do
    GenServer.call(@me, {:open_channel, queues})
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
    {:ok, connection}
  end

  @impl GenServer
  def handle_call({:open_channel, queues}, _from, connection) do
    {:ok, channel} = AMQP.Channel.open(connection)
    AMQP.Basic.qos(channel, prefetch_count: 1)
    queues |> Enum.each(&(AMQP.Queue.declare(channel, &1, durable: true)))
    {:reply, channel, connection}
  end

end
