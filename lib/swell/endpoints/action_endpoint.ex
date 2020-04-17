defmodule Swell.Services.ActionEndpoint do
  require Logger
  use Swell.Endpoints.Endpoint
  use Plug.Router
  use Plug.ErrorHandler

  plug(Plug.Parsers,
    parsers: [:json],
    pass: ["application/json"],
    json_decoder: Jason
  )

  plug(Swell.Endpoints.Plugs.JSONValidator, {"/handle", "action_handle_request"})
  plug(:match)
  plug(:dispatch)

  post "/handle" do
    %{
      "workflowId" => workflowId,
      "document" => document
    } = conn.body_params

    status = conn.params["status"]
    event = conn.params["event"]

    {
      :ok,
      %{
        "workflowId" => workflowId,
        "event" => %{
          "name" => event,
          "payload" => %{
            "oldStatus" => document["status"],
            "newStatus" => status
          }
        },
        "document" => %{document | "status" => status}
      }
    }
    |> send_json_response(conn)
  end

  match _ do
    send_json_response({:not_found, "Not found"}, conn)
  end
end
