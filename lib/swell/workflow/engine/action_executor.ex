defmodule Swell.Workflow.Engine.ActionExecutor do
  require Logger

  def execute({module, func} = action, document)
      when is_atom(module) and is_atom(func) do
    Logger.debug(fn -> "Executing action: #{inspect(action)} with document #{inspect(document)}" end)
    result = apply(module, func, [document])
    Logger.debug(fn -> "Executed action: #{inspect(action)} with result #{inspect(result)}" end)
    result
  end

end
