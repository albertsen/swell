defmodule Swell.Workflow.Engine.ActionExecutor do
  require Logger

  def execute({module, func} = action, document)
      when is_atom(module) and is_atom(func) do
    Logger.debug("Executing action: #{inspect(action)} with document #{inspect(document)}")
    result = apply(module, func, [document])
    Logger.debug("Executed action: #{inspect(action)} with result #{inspect(result)}")
    result
  end

end
