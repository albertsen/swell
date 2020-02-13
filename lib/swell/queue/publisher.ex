defmodule Swell.Queue.Publisher do
  require Logger

  def publish(message, channel) do
    json = Jason.encode!(message)
    Logger.debug(fn -> "Publishing message: #{inspect(json)}" end)
    Swell.Queue.Manager.publish(channel, json)
  end

  defmacro __using__(opts) do
    quote location: :keep, bind_quoted: [opts: opts] do
      import Swell.Queue.Publisher
    end
  end
end
