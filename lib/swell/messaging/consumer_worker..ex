defmodule Swell.Messaging.ComsumerWorker do
  use GenServer
  use Swell.Messaging.Consumer
  require Logger

  def start_link(opts) do
    GenServer.start_link(__MODULE__, opts)
  end

  @impl GenServer
  def init({queue, consumer}) do
    {:ok, channel} = init_consumer(queue)
    {:ok, {channel, consumer}}
  end

  def consume(message, {_channel, consumer}) do
    consumer.consume(message)
  end
end
