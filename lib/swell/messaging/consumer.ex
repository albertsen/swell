defmodule Swell.Messaging.Consumer do
  use GenServer
  require Logger

  def start_link(opts) do
    GenServer.start_link(__MODULE__, opts)
  end

  @impl GenServer
  def init({queue, consumer, publisher})
      when is_binary(queue) and is_atom(consumer) and is_atom(publisher) do
    {:ok, channel} = Swell.Messaging.Manager.open_channel()
    {:ok, _} = Swell.Messaging.Manager.consume(channel, queue)
    {:ok, {channel, consumer, publisher}}
  end

  @impl GenServer
  def handle_info({:basic_deliver, message, meta}, {channel, consumer, publisher} = state) do
    :ok =
      message
      |> Jason.decode!()
      |> log_message()
      |> consume(consumer)
      |> publish(publisher)

    Swell.Messaging.Manager.ack(channel, meta.delivery_tag)
    {:noreply, state}
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

  @impl GenServer
  def terminate(_reason, {channel, _consumer, _publisher}) do
    AMQP.Channel.close(channel)
  end

  defp log_message(message) do
    Logger.debug(fn -> "Consuming message: #{inspect(message)}" end)
    message
  end

  defp consume(message, consumer) do
    consumer.consume(message)
  end

  defp publish({:ok, _message}, nil), do: :ok

  defp publish({:ok, message}, publisher) when is_atom(publisher) do
    publisher.publish(message)
  end
end
