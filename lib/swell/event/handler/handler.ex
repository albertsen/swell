defmodule Swell.Event.Handler do
  @callback handle_event(map()) :: :ok
end
