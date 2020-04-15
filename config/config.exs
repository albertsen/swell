use Mix.Config

root_dir = System.get_env("SWELL_ROOT", File.cwd!())

config :ex_json_schema,
       :remote_schema_resolver,
       fn path -> Swell.JSON.Validator.resolve_schema(path) end

config :swell, db: [name: :swell, database: "swell", pool_size: 2]

config :swell, schema_dir: Path.join([root_dir, "schemas"])

config :swell,
  messaging: [
    topology: %{
      "actions" => [
        publisher: Swell.Messaging.Publishers.ActionPublisher,
        consumers: [{"action_dispatch", Swell.Messaging.Consumers.ActionDispatchConsumer, 1}]
      ],
      "events" => [
        publisher: Swell.Messaging.Publishers.EventPublisher,
        consumers: [{"event_persistence", Swell.Messaging.Consumers.EventPersistenceConsumer, 1}]
      ]
    }
  ]
