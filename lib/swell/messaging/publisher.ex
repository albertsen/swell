defmodule Swell.Messaging.Publisher do
  defmacro __using__(opts) do
    quote location: :keep, bind_quoted: [opts: opts] do
      @me __MODULE__
      require Logger
      use GenServer

      def start_link(queue) do
        GenServer.start(@me, queue, name: @me)
      end

      def publish(message) do
        GenServer.call(@me, {:publish, message})
      end

      @impl GenServer
      def init(queue) do
        {:ok, channel} = Swell.Messaging.Manager.open_channel()
        {:ok, {channel, queue}}
      end

      @impl GenServer
      def handle_call({:publish, message}, _from, state = {channel, queue}) do
        json = Jason.encode!(message)
        Logger.debug(fn -> "Publishing message: #{inspect(json)}" end)
        res = Swell.Messaging.Manager.publish(channel, queue(), json)
        {:reply, res, state}
      end
    end
  end
end
