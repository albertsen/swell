defmodule Swell.WorkerSupervisor do
  use DynamicSupervisor
  require Logger
  @me __MODULE__

  def start_link(_) do
    DynamicSupervisor.start_link(@me, nil, name: @me)
  end

  def init(_) do
    DynamicSupervisor.init(strategy: :one_for_one)
  end

  def start_workers(module, worker_opts, worker_count)
      when is_atom(module) and is_tuple(worker_opts) and is_integer(worker_count) do
    for _ <- 1..worker_count do
      {:ok, _pid} = DynamicSupervisor.start_child(@me, {module, worker_opts})
    end
  end
end
