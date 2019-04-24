defmodule Swell.Workflow.Engine.Workers.ErrorHelper do
  alias Swell.Workflow.State.Workflow
  alias Swell.Workflow.State.Error
  require Logger

  def handle_error(payload, error, stacktrace \\ nil)

  def handle_error(payload, %{message: message} = error, stacktrace) do
    do_handle_error(
      payload,
      message,
      error,
      Exception.format(:error, error, stacktrace)
    )
  end

  def handle_error(payload, error, stacktrace) when is_binary(error) do
    do_handle_error(
      payload,
      error,
      error,
      Exception.format(:error, error, stacktrace)
    )
  end

  def handle_error(payload, error, stacktrace) do
    do_handle_error(
      payload,
      inspect(error),
      error,
      Exception.format(:error, error, stacktrace)
    )
  end

  defp do_handle_error({routing_key, workflow}, message, data, details) do
    Logger.error(details)
    {
      :error,
      %Workflow{
        workflow
        | error: %Error{
            routing_key: routing_key,
            message: format(message),
            data: data,
            details: format(details)
          },
          status: :error
      }
    }
  end

  defp format(value) when is_binary(value), do: value
  defp format(value), do: inspect(value)

  defmacro __using__(opts) do
    quote location: :keep, bind_quoted: [opts: opts] do
      import Swell.Workflow.Engine.Workers.ErrorHelper
    end
  end
end
