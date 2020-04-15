defmodule Swell.Messaging.Consumers.DocumentPersistenceConsumer do
  require Logger

  def consume(message) do
    Logger.debug("Persisting: #{inspect(message)}")
  end
end
