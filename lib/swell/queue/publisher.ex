defmodule Swell.Queue.Publisher do
  require Logger

  def publish({routing_key, _payload} = message, channel) do
    Logger.debug(fn -> "Publishing message: #{inspect(message)}" end)
    Swell.Queue.Manager.publish(channel, to_string(routing_key), message)
  end

  defmacro __using__(opts) do
    quote location: :keep, bind_quoted: [opts: opts] do
      import Swell.Queue.Publisher
    end
  end
end
