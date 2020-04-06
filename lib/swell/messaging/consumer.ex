defmodule Swell.Messaging.Consumer do
  use GenServer
  require Logger

  def start_link(opts) do
    GenServer.start_link(__MODULE__, opts)
  end

  @impl GenServer
  def init({queue, consumer}) when is_binary(queue) do
    {:ok, channel} = Swell.Messaging.Manager.open_channel()
    {:ok, _} = Swell.Messaging.Manager.consume(channel, queue)
    {:ok, {channel, consumer}}
  end

  @impl GenServer
  def handle_info({:basic_deliver, message, meta}, {channel, consumer}) do
    :ok =
      message
      |> Jason.decode!(keys: :atoms)
      |> log_message()
      |> consume({channel, consumer})

    Swell.Messaging.Manager.ack(channel, meta.delivery_tag)
    {:noreply, {channel, consumer}}
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
  def terminate(_reason, {channel, _consumer}) do
    AMQP.Channel.close(channel)
  end

  defp log_message(message) do
    Logger.debug(fn -> "Consuming message: #{inspect(message)} - #{inspect(self())}" end)
    message
  end

  def consume(message, {_channel, consumer}) do
    consumer.consume(message)
  end
end
