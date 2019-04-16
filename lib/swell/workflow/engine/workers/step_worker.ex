defmodule Swell.Workflow.Engine.Workers.StepWorker do
  use GenServer
  use Swell.Queue.Consumer
  use Swell.Queue.Publisher
  use Swell.Workflow.Engine.Workers.ErrorHelper
  alias Swell.Workflow.Definition.StepDef
  alias Swell.Workflow.State.Workflow
  alias Swell.Workflow.Engine.WorkflowError
  alias Swell.Workflow.Engine.ActionExecutor

  def start_link(queue) do
    GenServer.start_link(__MODULE__, queue)
  end

  @impl GenServer
  def init({binding_keys, queue}) do
    init_consumer(binding_keys, queue)
  end

  def consume({:step, workflow} = payload, channel) do
    try do
      execute_step(workflow)
    rescue
      error in _ ->
        handle_error(payload, error, __STACKTRACE__)
    end
    |> publish(channel)
  end

  defp execute_step(%Workflow{definition: definition, step: step} = workflow) do
    step_def = definition.steps[step]
    if !step_def, do: raise(WorkflowError, message: "Invalid step: [#{step}]")
    do_execute_step(workflow, step_def)
  end

  defp do_execute_step(%Workflow{document: document} = workflow, %StepDef{action: action}) do
    {result, document} = ActionExecutor.execute(action, document)
    {:transition, %Workflow{workflow | result: result, document: document}}
  end

  defp do_execute_step(workflow, final_result) when is_map(workflow) and is_atom(final_result) do
    {:done, %Workflow{workflow | result: final_result, status: :done}}
  end
end
