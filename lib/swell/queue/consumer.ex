defmodule Swell.Queue.Consumer do

  def handle_info({:basic_deliver, payload, _meta}, channel) do
    :ok = :erlang.binary_to_term(payload)
      |> consume_message(channel)
    {:noreply, channel}
  end

  def handle_info({:basic_consume_ok, _}, channel) do
    {:noreply, channel}
  end

  def handle_info({:basic_cancel, _}, channel) do
    {:stop, :normal, channel}
  end

  def handle_info({:basic_cancel_ok, _}, channel) do
    {:noreply, channel}
  end

  def consume_message(_message, _channel), do: :ok

  defmacro __using__(_opts) do
    quote do
      import Swell.Queue.Consumer
    end
  end

end
