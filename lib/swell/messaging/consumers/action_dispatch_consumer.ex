defmodule Swell.Messaging.Consumers.ActionDispatchConsumer do
  require Logger

  def consume(message) do
    Logger.debug("Dispatching action: #{inspect(message)}")
  end
end
