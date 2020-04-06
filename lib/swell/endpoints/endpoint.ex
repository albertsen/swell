defmodule Swell.Endpoints.Endpoint do
  defmacro __using__(opts) do
    quote location: :keep, bind_quoted: [opts: opts] do
      import Swell.Endpoints.Helper
      require Logger

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
  end
end
