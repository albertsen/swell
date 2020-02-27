defmodule Swell.Services.WorkflowService do
  alias Swell.DB.Repo.WorkflowDefRepo
  import Swell.Services.ServiceHelpers
  require Logger
  use Plug.Router
  use Plug.ErrorHandler

  plug(Plug.Parsers,
    parsers: [:json],
    pass: ["application/json"],
    json_decoder: Jason
  )

  plug(Swell.Services.JSONValidatorPlug, {"/workflowdefs", :workflow_def})
  plug(:match)
  plug(:dispatch)

  get "/workflowdefs/:id" do
    WorkflowDefRepo.find_by_id(id)
    |> send_json_response(conn)
  end

  post "/workflowdefs" do
    conn.body_params
    |> WorkflowDefRepo.create()
    |> send_json_response(conn)
  end

  put "/workflowdefs/:id" do
    WorkflowDefRepo.update(id, conn.body_params)
    |> send_json_response(conn)
  end

  delete "/workflowdefs/:id" do
    WorkflowDefRepo.delete(id)
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
