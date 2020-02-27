defmodule Swell.Services.JSONValidatorPlug do
  import Swell.Services.ServiceHelpers

  def init(schema) do
    schema
  end

  def call(conn, schema) do
    if conn.method in ~w(POST PUT) do
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
