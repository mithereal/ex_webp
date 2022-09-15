defmodule ExWebp.MixProject do
  use Mix.Project

  @version "0.1.1"
  @source_url "https://github.com/mithereal/ex_webp"

  def project do
    [
      app: :webp,
      version: @version,
      elixir: "~> 1.13",
      start_permanent: Mix.env() == :prod,
      deps: deps(),
      description: description(),
      package: package(),
      aliases: aliases(),
      docs: docs(),
      name: "webp",
      elixirc_paths: elixirc_paths(Mix.env())
    ]
  end

  defp aliases do
    [
      c: "compile",
      aliases: [test: ["test"]]
    ]
  end

  defp docs do
    [
      main: "readme",
      homepage_url: @source_url,
      source_ref: "v#{@version}",
      source_url: @source_url,
      extras: ["README.md"]
    ]
  end

  defp description() do
    "Mix tasks and library for converting jpeg, png, etc images to webp"
  end

  defp package() do
    [
      name: "webp",
      files: ["lib", "mix.exs", "README.md"],
      maintainers: ["Jason Clark"],
      licenses: ["MIT"],
      links: %{"GitHub" => "https://github.com/mithereal/ex_webp"}
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
      # {:dep_from_hexpm, "~> 0.3.0"},
      # {:dep_from_git, git: "https://github.com/elixir-lang/my_dep.git", tag: "0.1.0"}
      {:eimp, "~> 1.0"},
      {:ex_doc, ">= 0.0.0", only: :dev, runtime: false},
      {:phoenix, ">= 0.0.0"},
      {:jason, "~> 1.0"}
    ]
  end

  # This makes sure your factory and any other modules in test/support are compiled
  # when in the test environment.
  defp elixirc_paths(:test), do: ["lib", "test/support"]
  defp elixirc_paths(_), do: ["lib"]
end
