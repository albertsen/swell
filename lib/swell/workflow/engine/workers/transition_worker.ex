defmodule Swell.Workflow.Engine.Workers.TransitionWorker do

  use GenServer
  use Swell.Queue.Consumer
  use Swell.Queue.Publisher
  alias Swell.Workflow.Definition.StepDef
  alias Swell.Workflow.Engine.WorkflowError


  def start_link(queue) do
    GenServer.start_link(__MODULE__, queue)
  end

  @impl GenServer
  def init({binding_keys, queue}) do
    init_consumer(binding_keys, queue)
  end

  def consume({:transition, {id, workflow_def, document, step_name, result}}, channel) do
    try do
      step_def = workflow_def.steps[step_name]
      if !step_def, do: raise(WorkflowError, message: "Invalid step: [#{step_name}]")
      next_step_name = next_step_name(step_name, step_def, result)
      {:step, {id, workflow_def, next_step_name, document}}
    rescue
      error in _ ->
        Logger.error(inspect(error))
        {:error, {id, workflow_def, document, step_name, error}}
    end
    |> publish(channel)
  end

  defp next_step_name(current_step_name, %StepDef{transitions: transitions}, result)  do
    next_step_name = transitions[result]
    if !next_step_name,
      do:
        raise(
          WorkflowError,
          message: "No transition in step [#{current_step_name}] for result with code [#{result}]")
    next_step_name
  end


end
