defmodule Swell.Application do
  use Application
  import Supervisor.Spec

  def start(_type, _args) do
    children = [
      Swell.Queue.Manager,
      worker(Mongo, [[name: :swell, database: "swell", pool_size: 2]]),
      Swell.Event.WorkerSupervisor,
      Swell.Event.EventService
    ]

    opts = [strategy: :one_for_one, name: Swell.Supervisor]
    Supervisor.start_link(children, opts)
  end
end
