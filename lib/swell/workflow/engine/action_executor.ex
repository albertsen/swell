defmodule Swell.Workflow.Engine.ActionExecutor do
  alias Swell.Workflow.Definition.FunctionActionDef
  require Logger

  def execute(%FunctionActionDef{module: module, function: function} = action, document)
      when is_atom(module) and is_atom(function) do
    Logger.debug(fn ->
      "Executing action: #{inspect(action)} with document #{inspect(document)}"
    end)

    result = apply(module, function, [document])
    Logger.debug(fn -> "Executed action: #{inspect(action)} with result #{inspect(result)}" end)
    result
  end
end
