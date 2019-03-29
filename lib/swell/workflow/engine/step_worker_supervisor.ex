defmodule Swell.Workflow.Engine.StepWorkerSupervisor do

  use DynamicSupervisor
  alias Swell.Workflow.Engine.StepWorker
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
      {:ok, _pid} = DynamicSupervisor.start_child(@me, StepWorker)
    end
  end

end
