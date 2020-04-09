defmodule Swell.Services.WorkflowEndpoint do
  alias Swell.Services.WorkflowDefService
  alias Swell.Services.WorkflowService
  require Logger
  use Swell.Endpoints.Endpoint
  use Plug.Router
  use Plug.ErrorHandler

  plug(Plug.Parsers,
    parsers: [:json],
    json_decoder: {Jason, :decode!, [[keys: :strings]]}
  )

  plug(Swell.Endpoints.Plugs.JSONValidator, {"/workflowdefs", "workflow_def"})
  plug(Swell.Endpoints.Plugs.JSONValidator, {"/workflows", "workflow"})
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

  post "/workflows" do
    WorkflowService.create(conn.body_params)
    |> send_json_response(conn)
  end

  get "/workflows/:id" do
    WorkflowService.get_with_id(id)
    |> send_json_response(conn)
  end

  match _ do
    send_json_response({:not_found, "Not found"}, conn)
  end
end
