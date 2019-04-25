defmodule Swell.Workflow.Engine.Workers.WorkflowUpdateWorker do
  use GenServer
  use Swell.Queue.Consumer
  use Swell.Queue.Publisher
  alias Swell.DB.Repos.WorkflowRepo

  def start_link(queue) do
    GenServer.start_link(__MODULE__, queue)
  end

  @impl GenServer
  def init({binding_keys, queue}) do
    init_consumer(binding_keys, queue)
  end

  def consume({{:event, key}, workflow}, channel) do
    {{:update, key}, WorkflowRepo.save(workflow)}
    |> publish(channel)
  end

end
