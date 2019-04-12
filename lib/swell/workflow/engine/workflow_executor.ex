defmodule Swell.Workflow.Engine.WorkflowExecutor do
  use GenServer
  use Swell.Queue.Publisher
  alias Swell.Workflow.Engine.Workers.WorkerSupervisor
  alias Swell.Workflow.Messages.Step
  alias Swell.Workflow.Messages.Workflow
  require Logger
  @me __MODULE__

  def start_link(worker_count) do
    GenServer.start_link(@me, worker_count, name: @me)
  end

  def execute(workflow_def, document) do
    GenServer.call(@me, {:execute, workflow_def, document})
  end

  @impl GenServer
  def init(worker_count) do
    send(self(), :start_workers)
    channel = Swell.Queue.Manager.open_channel()
    {:ok, {worker_count, channel}}
  end

  @impl GenServer
  def handle_call({:execute, workflow_def, document}, _from, {worker_count, channel}) do
    id = UUID.uuid4()
    message = {
      :step,
      %Step{
        step_name: :start,
        workflow: %Workflow{
          id: id,
          definition: workflow_def
        },
        document: document
      }
    }
    publish(message, channel)
    {:reply, id, {worker_count, channel}}
  end

  @impl GenServer
  def handle_info(:start_workers, {worker_count, channel}) do
    WorkerSupervisor.start_workers(worker_count)
    {:noreply, {worker_count, channel}}
  end
end
