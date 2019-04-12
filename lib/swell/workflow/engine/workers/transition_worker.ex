defmodule Swell.Workflow.Engine.Workers.TransitionWorker do
  use GenServer
  use Swell.Queue.Consumer
  use Swell.Queue.Publisher
  use Swell.Workflow.Engine.Workers.WorkerHelper
  alias Swell.Workflow.Definition.StepDef
  alias Swell.Workflow.Messages.Transition
  alias Swell.Workflow.Messages.Workflow
  alias Swell.Workflow.Messages.Step
  alias Swell.Workflow.Engine.WorkflowError

  def start_link(queue) do
    GenServer.start_link(__MODULE__, queue)
  end

  @impl GenServer
  def init({binding_keys, queue}) do
    init_consumer(binding_keys, queue)
  end

  def consume({:transition, transition} = message, channel) do
    try do
      transition(transition)
    rescue
      error in _ ->
        handle_error(message, error, __STACKTRACE__)
    end
    |> publish(channel)
  end

  defp transition(%Transition{
         step_name: step_name,
         workflow: %Workflow{definition: workflow_def} = workflow,
         document: document,
         result: result
       }) do
    step_def = workflow_def.steps[step_name]
    if !step_def, do: raise(WorkflowError, message: "Invalid step: [#{step_name}]")
    next_step_name = next_step_name(step_name, step_def, result)
    {
      :step,
      %Step{
        step_name: next_step_name,
        workflow: workflow,
        document: document
      }
    }
  end

  defp next_step_name(current_step_name, %StepDef{transitions: transitions}, result) do
    next_step_name = transitions[result]
    if !next_step_name,
      do:
        raise(WorkflowError,
          message: "No transition in step [#{current_step_name}] for result with code [#{result}]"
        )
    next_step_name
  end
end
