defmodule Swell.Workflow.Engine.Workers.WorkerHelper do
  alias Swell.Workflow.Messages.Error
  require Logger

  def handle_error(message, error, stacktrace \\ nil) do
    details = Exception.format(:error, error, stacktrace)
    Logger.error(details)
    {:error, %Error{message: message, error: error, details: details}}
  end

  defmacro __using__(opts) do
    quote location: :keep, bind_quoted: [opts: opts] do
      import Swell.Workflow.Engine.Workers.WorkerHelper
    end
  end
end
