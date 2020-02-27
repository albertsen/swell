use Mix.Config

root_dir = System.get_env("SWELL_ROOT", File.cwd!())

config :swell,
  workers: [
    {Swell.Event.Worker,
     {
       "persistence",
       %{"order_placed" => Swell.Event.Handler.Persistence.OrderPlacedHandler},
       Swell.Order.Converter
     }, 1}
  ]

config :swell, db: [name: :swell, database: "swell", pool_size: 2]

config :swell,
  schemas: %{
    workflow_def: Path.join([root_dir, "schemas", "workflow_def.schema.json"]),
    workflow: Path.join([root_dir, "schemas", "workflow.schema.json"])
  }
