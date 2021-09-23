defmodule Castile.MixProject do
  use Mix.Project

  def project do
    [
      app: :castile,
      version: "1.0.1",
      elixir: "~> 1.6",
      start_permanent: Mix.env() == :prod,
      elixirc_paths: elixirc_paths(Mix.env()),
      deps: deps(),
      name: "Castile",
      source_url: "https://github.com/polyfox/castile",
      description: "Castile is a modern Elixir SOAP API client.",
      package: [
        maintainers: ["Blaž Hrastnik"],
        licenses: ["MIT"],
        links: %{ "GitHub" => "https://github.com/polyfox/castile" },
      ],
    ]
  end

  # Run "mix help compile.app" to learn about applications.
  def application do
    [
      extra_applications: [:logger]
    ]
  end

  defp elixirc_paths(:test), do: ["lib", "test/fixtures"]
  defp elixirc_paths(_), do: ["lib"]

  # Run "mix help deps" to learn about dependencies.
  defp deps do
    [
      # hex version is old and doesn't have write/3 or write related perf
      # improvements
      {:erlsom, "~> 1.4.2"},
      {:ex_doc, ">= 0.0.0", only: :dev},
      {:credo, "~> 0.9.1", only: [:dev, :test], runtime: false},
      {:exvcr, "~> 0.10", only: :test}
    ]
  end
end
