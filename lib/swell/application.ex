defmodule Swell.Application do
  use Application

  def start(_type, _args) do
    children = [
      Swell.Queue.Manager,
      Swell.DB.Connection,
      Swell.DB.Repos.WorkflowRepo,
      Swell.Workflow.Engine.Workers.WorkerSupervisor,
      Swell.Workflow.Engine.WorkflowExecutor,
    ]
    opts = [strategy: :one_for_one, name: Swell.Supervisor]
    Supervisor.start_link(children, opts)
  end
end
