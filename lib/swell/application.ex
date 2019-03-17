defmodule Swell.Application do
  # See https://hexdocs.pm/elixir/Application.html
  # for more information on OTP Applications
  @moduledoc false

  use Application

  def start(_type, {process_def, pid}) do
    # List all child processes to be supervised
    children = [
      Swell.DocumentStore,
      {Swell.ProcessEngine.ActionExecutor, process_def.actions},
      Swell.ProcessEngine.StepExecutor,
      {Swell.ProcessEngine.WorkflowExecutor, {process_def.workflow, pid}},
    ]

    # See https://hexdocs.pm/elixir/Supervisor.html
    # for other strategies and supported options
    opts = [strategy: :one_for_one, name: Swell.Supervisor]
    Supervisor.start_link(children, opts)
  end
end
