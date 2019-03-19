defmodule Swell.WorkflowEngine do
  alias Swell.WorkflowEngine.StepExecutor

  @spec execute(Swell.WorkflowDef.t(), any()) :: any()
  def execute(workflow_def, document) when is_map(workflow_def) and is_map(document) do
    execute_all_steps(workflow_def, :start, document)
  end

  defp execute_all_steps(_workflow_def, nil, document) when is_map(document), do: document

  defp execute_all_steps(workflow_def, step_name, document)
       when is_map(workflow_def) and is_atom(step_name) and is_map(document) do
    step_def = workflow_def.steps[step_name]
    {code, document} = StepExecutor.execute_step(step_def, document)
    next_step_name = next_step_name(step_def, code)
    execute_all_steps(workflow_def, next_step_name, document)
  end

  @spec next_step_name(Swell.WorkflowDef.StepDef.t() | atom(), atom()) :: atom()
  def next_step_name(%Swell.WorkflowDef.StepDef{transitions: transitions} = step_def, code)
      when is_map(transitions) and is_atom(code) do
    next_step_name = transitions[code]

    if !next_step_name,
      do: raise("No transition in step #{inspect(step_def)} for result with code #{code}")

    next_step_name
  end

  def next_step_name(final_result, _code)
      when is_atom(final_result),
      do: nil
end

defmodule Swell.WorkflowEngine.StepExecutor do
  alias Swell.WorkflowEngine.ActionExecutor

  @spec execute_step(Swell.WorkflowDef.StepDef.t() | atom(), any()) :: {atom(), any()}
  def execute_step(step_def, document)
      when (is_map(step_def) or is_atom(step_def)) and is_map(document) do
    do_execute_step(step_def, document)
  end

  defp do_execute_step(
         final_result,
         document
       )
       when is_atom(final_result) and is_map(document) do
    {final_result, document}
  end

  defp do_execute_step(%Swell.WorkflowDef.StepDef{action: action} = _step_def, document)
       when is_map(document) do
    ActionExecutor.execute(action, document)
  end
end

defmodule Swell.WorkflowEngine.ActionExecutor do
  @spec execute((map() -> {atom(), map()}), map()) :: {atom(), map()}
  def execute(action, document)
      when is_function(action) and is_map(document) do
    action.(document)
  end
end
