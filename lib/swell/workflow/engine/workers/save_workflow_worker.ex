defmodule Swell.Workflow.Engine.Workers.WorkflowPersistenceWorker do
  use GenServer
  use Swell.Queue.Consumer

  def start_link(queue) do
    GenServer.start_link(__MODULE__, queue)
  end

  @impl GenServer
  def init({binding_keys, queue}) do
    init_consumer(binding_keys, queue)
  end

  def consume({_routing_key, payload} = message, channel) do
    save_workflow(message)
  end

  defp save_workflow(message) do
    :ok
  end
end
