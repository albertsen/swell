defmodule Swell.Application do
  use Application
  import Supervisor.Spec

  def start(_type, _args) do
    Supervisor.start_link(children(), opts())
  end

  defp children() do
    [
      # Swell.Queue.Manager,
      worker(Mongo, [Application.get_env(:swell, :db)]),
      # Swell.Event.WorkerSupervisor,
      # Swell.Event.EventService,
      Swell.JSON.Validator,
      {Plug.Cowboy, scheme: :http, plug: Swell.Services.WorkflowEndpoint, options: [port: 8080]}
    ]
  end

  defp opts() do
    [
      strategy: :one_for_one,
      name: Swell.Supervisor
    ]
  end
end
