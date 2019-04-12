defmodule Swell.Queue.Receiver do
  require Logger

  def wait_for_messages(channel, fun, state) do
    Logger.debug(fn -> "Waiting for messages..." end)

    receive do
      {:basic_deliver, payload, meta} ->
        message = :erlang.binary_to_term(payload)
        Logger.debug(fn -> "Received message: #{inspect(message)}" end)
        Swell.Queue.Manager.ack(channel, meta.delivery_tag)

        case fun.(message, state) do
          {:next, new_state} -> wait_for_messages(channel, fun, new_state)
          {:done, new_state} -> new_state
        end
    end
  end
end
