defmodule Swell.Workflow.Engine.WorkflowExecutor do
  use GenServer
  use Swell.Queue.Publisher
  alias Swell.Workflow.Engine.Workers.WorkerSupervisor
  alias Swell.Workflow.Messages.Step
  alias Swell.Workflow.Messages.Workflow
  require Logger
  @me __MODULE__

  def start_link(_) do
    GenServer.start_link(@me, nil, name: @me)
  end

  def execute(workflow_def, %{id: _id} = document) do
    GenServer.call(@me, {:execute, workflow_def, document})
  end

  @impl GenServer
  def init(_) do
    send(self(), :start_workers)
    channel = Swell.Queue.Manager.open_channel()
    {:ok, channel}
  end

  @impl GenServer
  def handle_call({:execute, workflow_def, document}, _from, channel) do
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
    {:reply, id, channel}
  end

  @impl GenServer
  def handle_info(:start_workers, channel) do
    Application.get_env(:swell, :workers)
    |> Enum.each(&(WorkerSupervisor.start_workers(&1)))
    {:noreply, channel}
  end
end
