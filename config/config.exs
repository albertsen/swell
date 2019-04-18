use Mix.Config

config :swell,
  workers: [
    {Swell.Workflow.Engine.Workers.StepWorker, {~w{step}, "steps"}, 100},
    {Swell.Workflow.Engine.Workers.TransitionWorker, {~w{transition}, "transitions"}, 100},
    {Swell.Workflow.Engine.Workers.PersistenceWorker, {~w{step error done}, "persistence"}, 10}
  ]

config :swell, db: [database: "swell", username: "swelladmin", pool_size: 10]

config :lager,
  error_logger_redirect: false,
  handlers: [level: :critical]

config :logger, level: :debug
