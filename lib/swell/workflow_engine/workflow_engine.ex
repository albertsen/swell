defmodule Swell.WorkflowEngine do
  use GenServer
  alias Swell.WorkflowEngine.StepWorkerSupervisor
  @me __MODULE__

  def start_link(worker_count) do
    GenServer.start_link(@me, worker_count, name: @me)
  end

  def execute(workflow, document) do
    GenServer.cast(@me, {:execute, workflow, document})
  end

  @impl GenServer
  def init(worker_count) do
    Process.send_after(self(), :start_workers, 0)
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
