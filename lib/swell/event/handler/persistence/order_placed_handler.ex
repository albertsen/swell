defmodule Swell.Event.Handler.Persistence.OrderPlacedHandler do
  @behaviour Swell.Event.Handler
  alias Swell.Event
  alias Swell.DB.Repo.OrderRepo
  require Logger

  def handle_event(%Event{payload: order}) do
    OrderRepo.create(order)
  end

end
