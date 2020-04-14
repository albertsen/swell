defmodule Swell.Messaging.Publishers.ActionPublisher do
  use Swell.Messaging.Publisher, exchange: "actions", schema: "action_dispatch_request"
end
