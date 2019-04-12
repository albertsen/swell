use Mix.Config

config :lager,
  error_logger_redirect: false,
  handlers: [level: :critical]

config :logger, level: :warn

config :swell,
  workers: [
    {Swell.Workflow.Engine.Workers.StepWorker, {~w{step}, "steps"}, 1000},
    {Swell.Workflow.Engine.Workers.TransitionWorker, {~w{transition}, "transitions"}, 1000},
  ]
