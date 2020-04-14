defmodule Swell.Messaging.Consumers.ActionDispatchConsumer do
  require Logger

  def consume(dispatch_request) do
    Logger.debug("Dispatching action: #{inspect(dispatch_request)}")

    dispatch_action(dispatch_request)
    |> log_event()
    |> publish_event()
  end

  defp dispatch_action(%{
         "handler" => %{
           "type" => "endpoint",
           "url" => url
         },
         "document" => document,
         "stepName" => step_name
       }) do
    action_request = %{
      "stepName" => step_name,
      "document" => document
    }

    Logger.debug("Call action handler at '#{url}' with: #{inspect(action_request)}")
    {:ok, event} = Swell.Rest.Client.post(url, action_request)
    event
  end

  defp log_event(event) do
    Logger.debug("Received event from action handler: #{inspect(event)}")
    event
  end

  defp publish_event(event) do
    Logger.debug("Publishing event: #{inspect(event)}")
  end
end
