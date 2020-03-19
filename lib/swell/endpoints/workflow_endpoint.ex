defmodule Swell.Services.WorkflowEndpoint do
  alias Swell.Services.WorkflowDefService
  import Swell.Endpoints.Helper
  require Logger
  use Plug.Router
  use Plug.ErrorHandler

  plug(Plug.Parsers,
    parsers: [:json],
    pass: ["application/json"],
    json_decoder: Jason
  )

  plug(Swell.Endpoints.Plugs.JSONValidator, {"/workflowdefs", :workflow_def})
  plug(:match)
  plug(:dispatch)

  get "/workflowdefs/:id" do
    WorkflowDefService.get_with_id(id)
    |> send_json_response(conn)
  end

  post "/workflowdefs" do
    conn.body_params
    |> WorkflowDefService.create()
    |> send_json_response(conn)
  end

  put "/workflowdefs/:id" do
    WorkflowDefService.update(id, conn.body_params)
    |> send_json_response(conn)
  end

  delete "/workflowdefs/:id" do
    WorkflowDefService.delete(id)
    |> send_json_response(conn)
  end

  match _ do
    send_json_response({:not_found, "Not found"}, conn)
  end

  def handle_errors(conn, %{kind: kind, reason: reason, stack: stack}) do
    Logger.error(
      Exception.format(
        :error,
        "Error handling #{conn.method} request to #{conn.request_path} - Code: #{kind} - Rason: #{
          inspect(reason)
        }",
        stack
      )
    )

    send_json_response({:error, "An error occurred"}, conn)
  end
end
