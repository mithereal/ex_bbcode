defmodule BBCode.MixProject do
  use Mix.Project

  @version "1.1.0"
  @source_url "https://github.com/mithereal/ex_bbcode"

  def project do
    [
      app: :ex_bbcode,
      name: "BBCode Parser",
      description:
        "A high-performance HTML-to-BBCode converter and AST parser built with NimbleParsec.",
      version: @version,
      elixir: "~> 1.7",
      deps: deps(),
      package: package(),
      docs: docs(),
      source_url: @source_url
    ]
  end

  def application do
    [
      extra_applications: [:logger]
    ]
  end

  defp deps do
    [
      {:nimble_parsec, "~> 1.4"},
      {:credo, ">= 0.0.0", only: [:dev, :test], runtime: false},
      {:ex_doc, ">= 0.0.0", only: :dev, runtime: false},
      {:dialyxir, ">= 0.0.0", only: [:dev], runtime: false},
      {:html_sanitize_ex, "~> 1.4"}
    ]
  end

  defp package do
    [
      files: ["lib", "test", "mix.exs", "README.md"],
      licenses: ["Apache-2.0"],
      links: %{"GitLab" => "https://github.com/mithereal/ex_bbcode"},
      maintainers: []
    ]
  end

  defp docs do
    [
      source_url: @source_url,
      extras: ["README.md"]
    ]
  end
end
