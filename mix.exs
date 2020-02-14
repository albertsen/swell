defmodule Swell.MixProject do
  use Mix.Project

  def project do
    [
      app: :swell,
      version: "0.1.0",
      elixir: "~> 1.8",
      start_permanent: Mix.env() == :prod,
      deps: deps()
    ]
  end

  # Run "mix help compile.app" to learn about applications.
  def application do
    [
      extra_applications: [:sasl, :logger],
      mod: {Swell.Application, []}
    ]
  end

  # Run "mix help deps" to learn about dependencies.
  defp deps do
    [
      {:amqp, "~> 1.4"},
      {:uuid, "~> 1.1"},
      {:mongodb, "~> 0.5"},
      {:poolboy, "~> 1.5"},
      {:plug, "~> 1.9"},
      {:cowboy, "~> 2.7"},
      {:plug_cowboy, "~> 2.1"},
      {:jason, "~> 1.1"}
    ]
  end
end
