defmodule BBCode.MixProject do
  use Mix.Project

  def project do
    [
      app: :bbcode,
      name: "BBCode",
      description: "BBCode parsing for Elixir",
      version: "1.0.0",
      elixir: "~> 1.7",
      start_permanent: Mix.env() == :prod,
      deps: deps(),
      package: package()
    ]
  end

  def application do
    [
      extra_applications: [:logger]
    ]
  end

  defp deps do
    [
      {:nimble_parsec, ">= 0.0.0"},
      {:credo, ">= 0.0.0", only: [:dev, :test], runtime: false},
      {:ex_doc, ">= 0.0.0", only: :dev, runtime: false},
      {:dialyxir, ">= 0.0.0", only: [:dev], runtime: false}
    ]
  end

  defp package do
    [
      files: ["lib", "test", "mix.exs", "README.md", "LICENSE"],
      licenses: ["LGPLv3"],
      links: %{"GitLab" => "https://github.com/mithereal/ex_bbcode"},
      maintainers: []
    ]
  end
end
