use Mix.Config

root_dir = System.get_env("SWELL_ROOT", File.cwd!())

config :swell, db: [name: :swell, database: "swell", pool_size: 2]

config :swell,
  schemas: %{
    workflow_def: Path.join([root_dir, "schemas", "workflow_def.schema.json"]),
    workflow: Path.join([root_dir, "schemas", "workflow.schema.json"])
  }

config :swell,
  messaging: [
    topology: %{
      "actions" => [
        {"action_dispatch", Swell.Messaging.Consumers.ActionDispatchConsumer, 1}
      ],
      "events" => [
        {"event_persistence", Swell.Messaging.Consumers.EventPersistenceConsumer, 1}
      ]
    }
  ]
