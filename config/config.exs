use Mix.Config

config :swell,
  workers: [
    {Swell.Workflow.Engine.Workers.StepWorker, {~w{event.step}, "steps"}, 10},
    {Swell.Workflow.Engine.Workers.TransitionWorker, {~w{event.transition}, "transitions"}, 10},
    {Swell.Workflow.Engine.Workers.WorkflowUpdateWorker, {~w{event.*}, "updates"}, 10}
  ]

config :swell, db: [database: "swell", username: "swelladmin", pool_size: 10]

config :lager,
  error_logger_redirect: false,
  handlers: [level: :critical]

config :logger, level: :warn, handle_sasl_reports: true
