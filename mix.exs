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
      {:amqp, "~> 1.1"},
      {:uuid, "~> 1.1"},
      {:postgrex, ">= 0.0.0"},
      {:poolboy, "~>1.5.0"},
      {:dialyxir, "~> 1.0.0-rc.6", only: [:dev], runtime: false},
      {:jason, "~> 1.1"}
    ]
  end
end
