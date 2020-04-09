defmodule Swell.Rest.Client do
  alias Plug.Conn.Status
  require Logger

  def post(url, payload) when is_binary(url) and is_binary(payload) do
    HTTPoison.post!(url, payload, [{"Content-Type", "application/json"}])
    |> convert_result()
  end

  def post(url, payload) when is_map(payload) do
    post(url, Jason.encode!(payload))
  end

  def put(url, payload) when is_binary(url) and is_binary(payload) do
    HTTPoison.put!(url, payload, [{"Content-Type", "application/json"}])
    |> convert_result()
  end

  def put(url, payload) when is_map(payload) do
    put(url, Jason.encode!(payload))
  end

  def get(url) when is_binary(url) do
    HTTPoison.get!(url)
    |> convert_result()
  end

  def delete(url) when is_binary(url) do
    HTTPoison.delete!(url)
    |> convert_result()
  end

  defp convert_result(res) do
    {
      Status.reason_atom(res.status_code),
      parse_body(res.body)
    }
  end

  defp parse_body(""), do: ""

  defp parse_body(body) when is_binary(body) do
    Jason.decode!(body)
  end
end
