use Mix.Config

config :swell,
  workers: [
    {Swell.Event.Worker,
     {
       "persistence",
       %{"order_placed" => Swell.Event.Handler.Persistence.OrderPlacedHandler},
       Swell.Order.Converter
     }, 1}
  ]

config :swell, db: [database: "swell", username: "swelladmin", pool_size: 10]
