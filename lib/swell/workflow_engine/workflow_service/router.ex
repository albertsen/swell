defmodule Swell.WorkflowEngine.WorkflowService.Router do
  use Plug.Router
  alias Plug.Conn.Status
  alias Swell.DB.Repo.WorkflowDefRepo
  require Logger

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

  defp send_json_response({status_code, body}, conn) do
    conn
    |> put_resp_content_type("application/json")
    |> send_resp(Status.code(status_code), Jason.encode!(body))
  end

end
