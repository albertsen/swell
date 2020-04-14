defmodule Swell.Messaging.Publishers.EventPublisher do
  use Swell.Messaging.Publisher, exchange: "events", schema: "event"
end
