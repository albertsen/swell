defmodule Swell.Messaging.Consumers.ActionDispatchConsumer do
  require Logger

  def consume(%{
        "handler" => %{
          "type" => "endpoint",
          "url" => url
        },
        "document" => document,
        "stepName" => step_name,
        "workflowId" => workflowId
      }) do
    action_request = %{
      "workflowId" => workflowId,
      "stepName" => step_name,
      "document" => document
    }

    {
      :ok,
      %{
        "workflowId" => _,
        "event" => %{
          "name" => _,
          "payload" => %{}
        },
        "document" => %{}
      }
    } = Swell.Rest.Client.post(url, action_request)
  end
end
