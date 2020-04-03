defmodule Swell.Messaging.Consumers.ActionDispatchConsumer do
  require Logger

  def consume(message) do
    Logger.info(inspect(message))
  end
end
