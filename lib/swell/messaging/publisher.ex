defmodule Swell.Messaging.Publisher do
  defmacro __using__(opts) do
    quote location: :keep, bind_quoted: [opts: opts] do
      import Swell.Messaging.Publisher
      require Logger
      use GenServer

      @me __MODULE__
      @exchange Keyword.fetch!(opts, :exchange)
      @schema Keyword.fetch!(opts, :schema)

      def start_link(schema) do
        GenServer.start(@me, nil, name: @me)
      end

      def publish(message) do
        GenServer.call(@me, {:publish, message})
      end

      @impl GenServer
      def init(schema) do
        {:ok, channel} = Swell.Messaging.Manager.open_channel()
      end

      @impl GenServer
      def handle_call({:publish, message}, _from, channel) do
        json = Jason.encode!(message)
        Logger.debug(fn -> "Publishing message: #{json}" end)
        :ok = Swell.JSON.Validator.validate(message, @schema)
        :ok = Swell.Messaging.Manager.publish(channel, @exchange, json)
        {:reply, :ok, channel}
      end
    end
  end
end