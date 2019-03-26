defmodule Swell.Queue do
  use GenServer
  require Logger

  def start_link(name) do
    GenServer.start(__MODULE__, :queue.new(), name: name)
  end

  def enqueue(queue_name, item) do
    GenServer.cast(queue_name, {:enqueue, item})
  end

  def dequeue(queue_name) do
    GenServer.call(queue_name, :dequeue)
  end

  # Server (callbacks)

  @impl GenServer
  def init(queue) do
    {:ok, queue}
  end

  @impl GenServer
  def handle_cast({:enqueue, item}, queue) do
    queue = :queue.in(item, queue)
    {:noreply, queue}
  end

  @impl GenServer
  def handle_call(:dequeue, _from, queue) do
    {result, queue} = :queue.out(queue)
    {:reply, result, queue}
  end

end
