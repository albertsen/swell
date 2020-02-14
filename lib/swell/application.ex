defmodule Swell.Application do
  use Application
  import Supervisor.Spec

  def start(_type, _args) do
    Supervisor.start_link(children(), opts())
  end

  defp children() do
    [
      # Swell.Queue.Manager,
      worker(Mongo, [[name: :swell, database: "swell", pool_size: 2]]),
      # Swell.Event.WorkerSupervisor,
      # Swell.Event.EventService,
      Swell.WorkflowEngine.WorkflowService.Endpoint
    ]
  end

  defp opts() do
    [
      strategy: :one_for_one,
      name: Swell.Supervisor
    ]
  end
end
