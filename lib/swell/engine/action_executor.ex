defmodule Swell.Engine.ActionExecutor do
  def execute(action, document) do
    action.(document)
  end
end
