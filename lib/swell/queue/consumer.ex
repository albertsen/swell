defmodule Swell.Queue.Consumer do
  @callback consume(map(), AMQP.Channel.t()) :: :ok
  require Logger

  def init_consumer(queue) do
    channel = Swell.Queue.Manager.open_channel()
    Swell.Queue.Manager.consume(channel, queue)
    {:ok, channel}
  end

  defmacro __using__(opts) do
    quote location: :keep, bind_quoted: [opts: opts] do
      import Swell.Queue.Consumer
      require Logger

      def handle_info({:basic_deliver, payload, meta}, {channel, state}) do
        :ok =
          payload
          |> Jason.decode!(keys: :atoms)
          |> log_message()
          |> consume({channel, state})

        Swell.Queue.Manager.ack(channel, meta.delivery_tag)
        {:noreply, {channel, state}}
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
