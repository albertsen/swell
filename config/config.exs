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
        consumers: [
          [
            queue: "action_dispatch",
            module: Swell.Messaging.Consumers.ActionDispatchConsumer,
            worker_count: 1
          ]
        ]
      ],
      "events" => [
        publisher: Swell.Messaging.Publishers.EventPublisher,
        consumers: [
          [
            queue: "document_persistence",
            module: Swell.Messaging.Consumers.DocumentPersistenceConsumer,
            worker_count: 1
          ]
        ]
      ]
    }
  ]
