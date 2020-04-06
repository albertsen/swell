defmodule Swell.Endpoints.Helper do
  require Logger
  import Plug.Conn
  alias Plug.Conn.Status

  def send_json_response({status, body}, conn) when is_binary(body) do
    send_json_response({status, %{message: body}}, conn)
  end

  def send_json_response({:error, body}, conn),
    do: send_json_response({:internal_server_error, body}, conn)

  def send_json_response({status, body}, conn) do
    conn
    |> put_resp_content_type("application/json")
    |> send_resp(Status.code(status), encode_body(body))
    |> halt()
  end

  def encode_body(body) when is_map(body) do
    Jason.encode!(body)
  end

  def encode_body(nil), do: ""

  def encode_body(body), do: body

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
