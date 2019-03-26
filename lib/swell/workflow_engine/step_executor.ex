defmodule Swell.WorkflowEngine.StepExecutor do
  alias Swell.WorkflowEngine.ActionExecutor
  require Logger

  def execute_step(workflow, step_name, document) do
    step = workflow.steps[step_name]
    {result_code, document} = execute_step(step, document)
    next_step_name = next_step_name(step, result_code)
    {result_code, document, next_step_name}
  end

  defp execute_step(final_result, document) when is_atom(final_result) and final_result != nil do
    {final_result, document}
  end

  defp execute_step(%Swell.Workflow.Step{action: action} = step, document) when is_map(step) do
    ActionExecutor.execute(action, document)
  end

  defp next_step_name(%Swell.Workflow.Step{transitions: transitions} = step, result_code)  do
    next_step_name = transitions[result_code]
    if !next_step_name,
      do:
        raise("No transition in step #{inspect(step)} for result with result_code #{result_code}")
    next_step_name
  end

  defp next_step_name(final_result, _result_code) when is_atom(final_result), do: nil
end
