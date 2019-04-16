defmodule Swell.Application do
  # See https://hexdocs.pm/elixir/Application.html
  # for more information on OTP Applications
  @moduledoc false

  use Application

  def start(_type, _args) do
    # List all child processes to be supervised
    children = [
      Swell.Queue.Manager,
      Swell.DB.Manager,
      Swell.Workflow.Engine.Workers.WorkerSupervisor,
      Swell.Workflow.Engine.WorkflowExecutor,
    ]

    # See https://hexdocs.pm/elixir/Supervisor.html
    # for other strategies and supported options
    opts = [strategy: :one_for_one, name: Swell.Supervisor]
    Supervisor.start_link(children, opts)
  end
end
