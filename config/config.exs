use Mix.Config

config :lager,
  error_logger_redirect: false,
  handlers: [level: :critical]

config :logger, level: :warn
