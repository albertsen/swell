defmodule Swell.Messaging.Consumers.EventPersistenceConsumer do
  require Logger

  def consume(message) do
    Logger.debug("Persisting: #{inspect(message)}")
  end
end
