defmodule Castile.MixProject do
  use Mix.Project

  def project do
    [
      app: :castile,
      version: "0.1.0",
      elixir: "~> 1.6",
      start_permanent: Mix.env() == :prod,
      deps: deps()
    ]
  end

  # Run "mix help compile.app" to learn about applications.
  def application do
    [
      extra_applications: [:logger]
    ]
  end

  # Run "mix help deps" to learn about dependencies.
  defp deps do
    [
      {:xml_builder, "~> 2.0"},
      {:erlsom, "~> 1.4"}
    ]
  end
end
