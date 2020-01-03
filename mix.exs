defmodule FIQLEx.MixProject do
  use Mix.Project

  def project do
    [
      app: :fiqlex,
      version: "1.0.0",
      elixir: "~> 1.8",
      start_permanent: Mix.env() == :prod,
      deps: deps(),
      name: "FIQLEx",
      description: "FIQL (Feed Item Query Language) parser and query build",
      package: package(),
      source_url: "https://github.com/calions-app/fiqlex",
      homepage_url: "https://github.com/calions-app/fiqlex",
      docs: [
        main: "FIQLEx",
        extras: ["README.md"]
      ]
    ]
  end

  def package() do
    [
      name: "FIQLEx",
      licenses: ["MIT"],
      links: %{GitHub: "https://github.com/calions-app/fiqlex"},
      organization: "Calions apps"
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
      {:ex_doc, ">= 0.0.0", only: :dev, runtime: false}
      # {:dep_from_hexpm, "~> 0.3.0"},
      # {:dep_from_git, git: "https://github.com/elixir-lang/my_dep.git", tag: "0.1.0"}
    ]
  end
end
