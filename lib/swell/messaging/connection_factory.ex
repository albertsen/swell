defmodule Swell.Messaging.ConnectionFactory do
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

  @impl GenServer
  def init(_) do
    {:ok, _connection} = AMQP.Connection.open()
  end

  @impl GenServer
  def handle_call(:open_channel, _from, connection) do
    {:ok, channel} = AMQP.Channel.open(connection)
    AMQP.Basic.qos(channel, prefetch_count: 1)
    {:reply, channel, connection}
  end

  @impl GenServer
  def handle_call({:close_channel, channel}, _from, connection) do
    AMQP.Channel.close(channel)
    {:reply, nil, connection}
  end

  @impl GenServer
  def terminate(_reason, connection) do
    AMQP.Connection.close(connection)
  end
end
