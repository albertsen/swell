defmodule Swell.Queue.Consumer do
  @callback consume_message(any(), AMQP.Channel.t()) :: :ok

  defmacro __using__(opts) do
    quote location: :keep, bind_quoted: [opts: opts] do
      def handle_info({:basic_deliver, payload, meta}, channel) do
        :ok =
          :erlang.binary_to_term(payload)
          |> consume_message(channel)
        Swell.Queue.Manager.ack(channel, meta.delivery_tag)
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
    end
  end
end
