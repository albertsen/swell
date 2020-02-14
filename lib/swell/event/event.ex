defmodule Swell.Event do
  # @derive Jason.Encoder
  defstruct [:id, :type, :timestamp, :payload]
  require Logger
  alias Swell.Event
  alias Swell.Event.EventService

  def new(type, payload) when is_binary(type) and is_map(payload) do
    %Swell.Event{
      id: UUID.uuid4(),
      type: type,
      timestamp: DateTime.utc_now(),
      payload: payload
    }
  end

  def send(type, payload) do
    EventService.send_event(Event.new(type, payload))
  end

end
