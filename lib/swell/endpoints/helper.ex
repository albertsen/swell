defmodule Swell.Endpoints.Helper do
  import Plug.Conn
  alias Plug.Conn.Status

  def send_json_response({status, body}, conn) when is_binary(body) do
    send_json_response({status, %{message: body}}, conn)
  end

  def send_json_response({:error, body}, conn),
    do: send_json_response({:internal_server_error, body}, conn)

  def send_json_response({status, body}, %Plug.Conn{} = conn)
      when is_atom(status) do
    conn
    |> put_resp_content_type("application/json")
    |> send_resp(Status.code(status), encode_body(body))
    |> halt()
  end

  def encode_body(body) when is_map(body) do
    Jason.encode!(body)
  end

  def encode_body(nil), do: ""
end
