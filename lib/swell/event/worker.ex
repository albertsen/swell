defmodule Swell.Event.Worker do
  use GenServer
  use Swell.Queue.Consumer
  use Swell.Queue.Publisher
  alias Swell.Event
  require Logger

  def start_link(opts) do
    GenServer.start_link(__MODULE__, opts)
  end

  @impl GenServer
  def init({queue, handlers, converter}) do
    {:ok, channel} = init_consumer(queue)
    {:ok, {channel, {handlers, converter}}}
  end

  def consume(%{type: type} = event, {_channel, {handlers, converter}}) do
    event
    |> create_event_struct()
    |> convert_event_payload(converter)
    |> handle_event(handlers[type])
    :ok
  end

  defp create_event_struct(map), do: struct(Event, map)

  defp convert_event_payload(event, nil) do
    Logger.error("No payload converter for event: #{inspect(event)}")
    event
  end

  defp convert_event_payload(%Event{payload: payload} = event, _converter) when is_nil(payload), do: event

  defp convert_event_payload(%Event{payload: payload} = event, converter) do
    payload = converter.to_struct(payload)
    %{event | payload: payload}
  end

  defp handle_event(nil, event), do: Logger.error("No handler for event: #{inspect(event)}")

  defp handle_event(event, module) do
    module.handle_event(event)
  end
end
