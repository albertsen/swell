defmodule Swell.Application do
  # See https://hexdocs.pm/elixir/Application.html
  # for more information on OTP Applications
  @moduledoc false

  use Application

  def start(_type, _args) do
    # List all child processes to be supervised
    children = [
      Supervisor.child_spec({Swell.Queue, :steps}, id: :steps_queue),
      Supervisor.child_spec({Swell.Queue, :results}, id: :results_queue),
      Swell.WorkflowEngine.StepWorkerSupervisor,
      {Swell.WorkflowEngine, 100}
    ]

    # See https://hexdocs.pm/elixir/Supervisor.html
    # for other strategies and supported options
    opts = [strategy: :one_for_one, name: Swell.Supervisor]
    Supervisor.start_link(children, opts)
  end
end
