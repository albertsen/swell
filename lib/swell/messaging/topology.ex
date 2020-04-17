defmodule Swell.Messaging.Topology do
  use DynamicSupervisor
  require Logger
  alias Swell.Messaging.Manager
  @me __MODULE__

  def start_link(_) do
    DynamicSupervisor.start_link(@me, nil, name: @me)
  end

  def init(_) do
    DynamicSupervisor.init(strategy: :one_for_one)
  end

  defp start_child(module, opts) do
    start_children(module, opts, 1)
  end

  defp start_children(module, opts, count)
       when is_atom(module) and is_integer(count) do
    for _ <- 1..count do
      {:ok, _pid} = DynamicSupervisor.start_child(@me, {module, opts})
    end
  end

  def set_up() do
    {:ok, channel} = Manager.open_channel()

    try do
      Application.get_env(:swell, :messaging)
      |> set_up(channel)
    rescue
      err in _ ->
        Logger.error(Exception.format(:error, err, __STACKTRACE__))
        raise err
    after
      Manager.close_channel(channel)
    end

    :ok
  end

  defp set_up(_opts = [topology: topology], chann), do: set_up_topology(topology, chann)

  defp set_up_topology(toplogy, chann) when is_map(toplogy) do
    Enum.each(toplogy, fn {exchange, [publisher: publisher, consumers: consumers]} ->
      :ok = AMQP.Exchange.declare(chann, exchange, :fanout, durable: true)
      start_child(publisher, exchange)

      Enum.each(consumers, fn opts ->
        queue = Keyword.fetch!(opts, :queue)
        module = Keyword.fetch!(opts, :module)
        worker_count = Keyword.get(opts, :worker_count, 10)
        publish_next_with = Keyword.get(opts, :publish_next_with)
        {:ok, _} = AMQP.Queue.declare(chann, queue, durable: true)
        :ok = AMQP.Queue.bind(chann, queue, exchange)

        start_children(
          Swell.Messaging.Consumer,
          {queue, module, publish_next_with},
          worker_count
        )
      end)
    end)
  end
end
