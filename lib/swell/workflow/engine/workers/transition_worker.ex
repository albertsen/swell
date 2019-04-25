defmodule Swell.Workflow.Engine.Workers.TransitionWorker do
  use GenServer
  use Swell.Queue.Consumer
  use Swell.Queue.Publisher
  use Swell.Workflow.Engine.Workers.ErrorHelper
  alias Swell.Workflow.Definition.StepDef
  alias Swell.Workflow.State.Workflow
  alias Swell.Workflow.Engine.WorkflowError

  def start_link(queue) do
    GenServer.start_link(__MODULE__, queue)
  end

  @impl GenServer
  def init({binding_keys, queue}) do
    init_consumer(binding_keys, queue)
  end

  def consume({{:event, :transition}, workflow} = payload, channel) do
    try do
      transition(workflow)
    rescue
      error in _ ->
        handle_error(payload, error, __STACKTRACE__)
    end
    |> publish(channel)
  end

  defp transition(%Workflow{definition: definition, step: step, result: result} = workflow) do
    step_def = definition.steps[step]
    if !step_def, do: raise(WorkflowError, message: "Invalid step: [#{step}]")
    next_step = next_step(step, step_def, result)
    {{:event, :step}, %Workflow{workflow | step: next_step}}
  end

  defp next_step(current_step, %StepDef{transitions: transitions}, result) do
    next_step = transitions[result]

    if !next_step,
      do:
        raise(WorkflowError,
          message: "No transition in step [#{current_step}] for result with code [#{result}]"
        )

    next_step
  end
end
