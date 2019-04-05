defmodule Swell.Workflow.Engine.Workers.StepWorker do

  use GenServer
  use Swell.Queue.Consumer
  use Swell.Queue.Publisher
  alias Swell.Workflow.Definition.StepDef
  alias Swell.Workflow.Engine.WorkflowError
  alias Swell.Workflow.Engine.ActionExecutor


  def start_link(queue) do
    GenServer.start_link(__MODULE__, queue)
  end

  @impl GenServer
  def init(queue) do
    init_consumer(queue)
  end

  def consume_message({:step, {id, workflow_def, step_name, document} = step}, channel) do
    try do
      execute_step(step)
    rescue
      error in _ ->
        Logger.error(inspect(error))
        {:error, {id, workflow_def, document, step_name, error}}
    end
    |> publish_message(channel)
  end

  defp execute_step({id, workflow_def, step_name, document}) do
    step = workflow_def.steps[step_name]
    if !step, do: raise(WorkflowError, message: "Invalid step: [#{step_name}]")
    execute_step(id, workflow_def, step_name, step, document)
  end

  defp execute_step(id, workflow_def, step_name, %StepDef{action: action}, document) do
    {result, document} = ActionExecutor.execute(action, document)
    {:transition, {id, workflow_def, document, step_name, result}}
  end

  defp execute_step(id, workflow_def, _step_name, :done, document) do
    {:done, {id, workflow_def, document}}
  end

end
