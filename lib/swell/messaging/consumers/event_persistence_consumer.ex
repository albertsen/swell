defmodule Swell.Messaging.Consumers.EventPersistenceConsumer do
  require Logger

  def consume(message) do
    Logger.info(inspect(message))
  end
end
