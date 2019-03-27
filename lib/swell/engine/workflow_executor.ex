defmodule Swell.Engine.WorkflowExecutor do
  use GenServer
  alias Swell.Engine.StepWorkerSupervisor
  require Logger
  @me __MODULE__

  def start_link(worker_count) do
    GenServer.start_link(@me, worker_count, name: @me)
  end

  def execute(workflow, document) do
    GenServer.cast(@me, {:execute, workflow, document})
  end

  @impl GenServer
  def init(worker_count) do
    send(self(), :start_workers)
    {:ok, worker_count}
  end

  @impl GenServer
  def handle_cast({:execute, workflow, document}, worker_count) do
    Swell.Queue.enqueue(
      :steps,
      {workflow, :start, document}
    )
    {:noreply, worker_count}
  end

  @impl GenServer
  def handle_info(:start_workers, worker_count) do
    StepWorkerSupervisor.start_workers(worker_count)
    {:noreply, worker_count}
  end
end
