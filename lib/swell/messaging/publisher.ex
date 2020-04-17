defmodule Swell.Messaging.Publisher do
  defmacro __using__(opts) do
    quote location: :keep, bind_quoted: [opts: opts] do
      import Swell.Messaging.Publisher
      require Logger
      use GenServer

      @me __MODULE__
      @schema Keyword.fetch!(opts, :schema)

      def start_link(exchange) do
        GenServer.start(@me, exchange, name: @me)
      end

      def publish(message) do
        GenServer.call(@me, {:publish, message})
      end

      @impl GenServer
      def init(exchange) do
        {:ok, channel} = Swell.Messaging.Manager.open_channel()
        {:ok, {exchange, channel}}
      end

      @impl GenServer
      def handle_call({:publish, message}, _from, {exchange, channel} = state) do
        Logger.debug(fn -> "Publishing message: #{inspect(message)}" end)
        json = Jason.encode!(message)
        :ok = Swell.JSON.Validator.validate(message, @schema)
        :ok = Swell.Messaging.Manager.publish(channel, exchange, json)
        {:reply, :ok, state}
      end
    end
  end
end
