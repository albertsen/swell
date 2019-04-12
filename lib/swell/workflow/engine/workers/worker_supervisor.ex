defmodule Swell.Workflow.Engine.Workers.WorkerSupervisor do
  use DynamicSupervisor
  alias Swell.Workflow.Engine.Workers.StepWorker
  alias Swell.Workflow.Engine.Workers.TransitionWorker
  require Logger
  @me __MODULE__

  def start_link(worker_count) do
    DynamicSupervisor.start_link(@me, worker_count, name: @me)
  end

  def init(_) do
    DynamicSupervisor.init(strategy: :one_for_one)
  end

  def start_workers(count \\ 1) do
    for _ <- 1..count do
      {:ok, _pid} = DynamicSupervisor.start_child(@me, {StepWorker, {~w{step}, "steps"}})

      {:ok, _pid} =
        DynamicSupervisor.start_child(@me, {TransitionWorker, {~w{transition}, "transitions"}})
    end
  end
end
