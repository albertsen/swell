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
    doc =
      conn.body_params
      |> Map.fetch!("document")

    status = conn.params["status"]
    event = conn.params["event"]

    {
      :ok,
      %{
        "event" => event,
        "document" => %{doc | "status" => status}
      }
    }
    |> send_json_response(conn)
  end

  match _ do
    send_json_response({:not_found, "Not found"}, conn)
  end
end
