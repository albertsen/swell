use Mix.Config

config :swell,
  workers: [
    {Swell.Workflow.Engine.Workers.StepWorker, {~w{step}, "steps"}, 1},
    {Swell.Workflow.Engine.Workers.TransitionWorker, {~w{transition}, "transitions"}, 1},
    {Swell.Workflow.Engine.Workers.WorkflowUpdateWorker, {~w{step error done}, "updates"}, 1}
  ]

config :swell, db: [database: "swell", username: "swelladmin", pool_size: 10]

config :lager,
  error_logger_redirect: false,
  handlers: [level: :critical]

config :logger, level: :debug
