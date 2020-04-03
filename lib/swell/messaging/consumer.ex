defmodule Swell.Messaging.Consumer do
  @callback consume(map(), AMQP.Channel.t()) :: :ok
  require Logger

  def init_consumer(queue) do
    channel = Swell.Messaging.ConnectionFactory.open_channel()
    Swell.Messaging.Manager.consume(channel, queue)
    {:ok, channel}
  end

  defmacro __using__(opts) do
    quote location: :keep, bind_quoted: [opts: opts] do
      import Swell.Messaging.Consumer
      require Logger

      @impl GenServer
      def handle_info({:basic_deliver, message, meta}, {channel, state}) do
        :ok =
          message
          |> Jason.decode!(keys: :atoms)
          |> log_message()
          |> consume({channel, state})

        Swell.Messaging.Manager.ack(channel, meta.delivery_tag)
        {:noreply, {channel, state}}
      end

      @impl GenServer
      def terminate(_reason, {channel, state}) do
        AMQP.Channel.close(channel)
      end

      defp log_message(message) do
        Logger.debug(fn -> "Consuming message: #{inspect(message)} - #{inspect(self())}" end)
        message
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
    end
  end
end
