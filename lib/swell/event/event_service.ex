defmodule Swell.Event.EventService do
  use GenServer
  use Swell.Queue.Publisher
  alias Swell.Event.WorkerSupervisor
  require Logger
  @me __MODULE__

  def start_link(_) do
    GenServer.start_link(@me, nil, name: @me)
  end

  def send_event(event) do
    GenServer.call(@me, {:send_event, event})
  end

  @impl GenServer
  def init(_) do
    send(self(), :start_workers)
    channel = Swell.Queue.Manager.open_channel()
    {:ok, channel}
  end

  @impl GenServer
  def handle_call({:send_event, event}, _from, channel) do
    publish(event, channel)
    {:reply, :ok, channel}
  end

  @impl GenServer
  def handle_info(:start_workers, channel) do
    Application.get_env(:swell, :workers)
    |> Enum.each(&WorkerSupervisor.start_workers(&1))

    {:noreply, channel}
  end
end
