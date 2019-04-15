use Mix.Config

config :swell, Swell.DB.Repo,
  database: "swell",
  username: "swelladmin",
  hostname: "localhost",
  migration_primary_key: [name: :id, type: :uuid]

config :swell, ecto_repos: [Swell.DB.Repo]

config :swell,
  workers: [
    {Swell.Workflow.Engine.Workers.StepWorker, {~w{step}, "steps"}, 1000},
    {Swell.Workflow.Engine.Workers.TransitionWorker, {~w{transition}, "transitions"}, 1000}
  ]

config :lager,
  error_logger_redirect: false,
  handlers: [level: :critical]

config :logger, level: :warn
