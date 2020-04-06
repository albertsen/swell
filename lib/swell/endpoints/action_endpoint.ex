defmodule Swell.Services.ActionEndpoint do
  import Swell.Endpoints.Helper
  require Logger
  use Plug.Router
  use Plug.ErrorHandler

  plug(Plug.Parsers,
    parsers: [:json],
    pass: ["application/json"],
    json_decoder: Jason
  )

  plug(:match)
  plug(:dispatch)

  get "/action" do
    doc = conn.body_params
    order_status = conn.params["orderStatus"]
    event = conn.params["event"]

    %{
      event: event,
      document: %{doc | status: order_status}
    }
    |> send_json_response(conn)
  end

  match _ do
    send_json_response({:not_found, "Not found"}, conn)
  end
end
