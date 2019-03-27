defmodule Swell.Engine.StepExecutor do
  alias Swell.Engine.ActionExecutor
  alias Swell.Engine.WorkflowError
  alias Swell.Definition.Step

  def execute_step(workflow, step_name, document) do
    step = workflow.steps[step_name]
    if !step, do: raise(WorkflowError, message: "Invalid step: [#{step_name}]")
    {result_code, document} = execute_step(step, document)
    next_step_name = next_step_name(step_name, step, result_code)
    {result_code, document, next_step_name}
  end

  defp execute_step(final_result, document) when is_atom(final_result) and final_result != nil do
    {final_result, document}
  end

  defp execute_step(%Step{action: action} = step, document) when is_map(step) do
    ActionExecutor.execute(action, document)
  end

  defp next_step_name(current_step_name, %Step{transitions: transitions}, result_code)  do
    next_step_name = transitions[result_code]
    if !next_step_name,
      do:
        raise(
          WorkflowError,
          message: "No transition in step [#{current_step_name}] for result with code [#{result_code}]")
    next_step_name
  end

  defp next_step_name(_current_step_name, final_result, _result_code) when is_atom(final_result), do: nil
end
