defmodule Swell.Messaging.Publishers.ActionPublisher do
  use Swell.Messaging.Publisher
  def queue(), do: "actions"
end
