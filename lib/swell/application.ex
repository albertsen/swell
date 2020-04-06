defmodule Swell.Application do
  use Application
  import Supervisor.Spec

  def start(_type, _args) do
    {:ok, pid} = Supervisor.start_link(children(), opts())
    set_up()
    {:ok, pid}
  end

  defp children() do
    [
      worker(Mongo, [Application.get_env(:swell, :db)]),
      Swell.JSON.Validator,
      {Swell.Repos.WorkflowDefRepo, "workflowDefs"},
      {Swell.Repos.WorkflowRepo, "workflows"},
      Swell.WorkerSupervisor,
      Swell.Messaging.Manager,
      Swell.Messaging.Publishers.ActionPublisher,
      {Plug.Cowboy, scheme: :http, plug: Swell.Services.WorkflowEndpoint, options: [port: 8080]}
    ]
  end

  defp opts() do
    [
      strategy: :one_for_one,
      name: Swell.Supervisor
    ]
  end

  defp set_up do
    Swell.Messaging.Topology.set_up()
  end
end
