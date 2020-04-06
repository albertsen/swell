defmodule Swell.Messaging.Publisher do
  defmacro __using__(opts) do
    quote location: :keep, bind_quoted: [opts: opts] do
      import Swell.Messaging.Publisher
      require Logger
      use GenServer

      @me __MODULE__
      @before_compile Swell.Messaging.Publisher
      @exchange Keyword.fetch!(opts, :exchange)

      def start_link(_) do
        GenServer.start(@me, nil, name: @me)
      end

      def publish(message) do
        GenServer.call(@me, {:publish, message})
      end

      @impl GenServer
      def init(_) do
        {:ok, channel} = Swell.Messaging.Manager.open_channel()
      end

      @impl GenServer
      def handle_call({:publish, message}, _from, channel) do
        json = Jason.encode!(message)
        Logger.debug(fn -> "Publishing message: #{inspect(json)}" end)
        res = Swell.Messaging.Manager.publish(channel, @exchange, json)
        {:reply, res, channel}
      end
    end
  end

  defmacro __before_compile__(_) do
    quote do
      def exchange(exchange), do: @exchange = exchange
    end
  end
end
