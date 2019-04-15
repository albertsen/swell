defmodule Swell.Workflow.Engine.Workers.SaveWorkflowWorker do
  use GenServer
  use Swell.Queue.Consumer
  use Swell.Queue.Publisher
  use Swell.Workflow.Engine.Workers.WorkerHelper
  alias Swell.Workflow.Definition.StepDef
  alias Swell.Workflow.Messages.Step
  alias Swell.Workflow.Messages.Workflow
  alias Swell.Workflow.Messages.Transition
  alias Swell.Workflow.Messages.Done
  alias Swell.Workflow.Engine.WorkflowError
  alias Swell.Workflow.Engine.ActionExecutor

  def start_link(queue) do
    GenServer.start_link(__MODULE__, queue)
  end

  @impl GenServer
  def init({binding_keys, queue}) do
    init_consumer(binding_keys, queue)
  end

  def consume({:step, step} = message, channel) do
    try do
      execute_step(step)
    rescue
      error in _ ->
        handle_error(message, error, __STACKTRACE__)
    end
    |> publish(channel)
  end

  defp execute_step(
         %Step{step_name: step_name, workflow: %Workflow{definition: workflow_def}} = step
       ) do
    step_def = workflow_def.steps[step_name]
    if !step_def, do: raise(WorkflowError, message: "Invalid step: [#{step_name}]")
    do_execute_step(step, step_def)
  end

  defp do_execute_step(%Step{document: document, workflow: workflow} = step, %StepDef{
         action: action
       }) do
    {result, document} = ActionExecutor.execute(action, document)

    {
      :transition,
      %Transition{
        step_name: step.step_name,
        workflow: workflow,
        document: document,
        result: result
      }
    }
  end

  defp do_execute_step(%Step{document: document, workflow: workflow}, final_result)
       when is_atom(final_result) do
    {
      :done,
      %Done{
        workflow: workflow,
        document: document,
        result: final_result
      }
    }
  end
end
