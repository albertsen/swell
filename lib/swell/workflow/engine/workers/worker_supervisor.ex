defmodule Swell.Workflow.Engine.Workers.WorkerSupervisor do
  use DynamicSupervisor
  require Logger
  @me __MODULE__

  def start_link(_) do
    DynamicSupervisor.start_link(@me, nil, name: @me)
  end

  def init(_) do
    DynamicSupervisor.init(strategy: :one_for_one)
  end

  def start_workers({module, opts, worker_count} = conf)
      when is_atom(module) and is_tuple(opts) and is_integer(worker_count) do
    Logger.debug(fn -> "Starting workers: #{inspect(conf)}" end)
    for _ <- 1..worker_count do
      {:ok, _pid} = DynamicSupervisor.start_child(@me, {module, opts})
    end
  end
end
