defmodule Swell.Endpoints.Plugs.JSONValidator do
  import Swell.Endpoints.Helper

  def init({path, schema} = opts) when is_binary(path) and is_binary(schema) do
    opts
  end

  def call(conn, {path, schema}) do
    if String.starts_with?(conn.request_path, path) and conn.method in ~w(POST PUT) do
      res = Swell.JSON.Validator.validate(conn.body_params, schema)

      case res do
        {:error, errors} ->
          body = %{
            errors: Enum.map(errors, fn {reason, path} -> %{reason: reason, path: path} end)
          }

          send_json_response({:unprocessable_entity, body}, conn)

        _ ->
          %{conn | body_params: Swell.Map.Helpers.atomize_keys(conn.body_params)}
      end
    else
      conn
    end
  end
end
