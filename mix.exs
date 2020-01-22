defmodule Url.MixProject do
  use Mix.Project

  @version "1.2.0"

  def project do
    [
      app: :ex_url,
      version: @version,
      elixir: "~> 1.5",
      name: "URL",
      source_url: "https://github.com/kipcole9/url",
      docs: docs(),
      build_embedded: Mix.env() == :prod,
      start_permanent: Mix.env() == :prod,
      deps: deps(),
      description: description(),
      package: package(),
      test_coverage: [tool: ExCoveralls],
      aliases: aliases(),
      elixirc_paths: elixirc_paths(Mix.env()),
      dialyzer: [
        ignore_warnings: ".dialyzer_ignore_warnings",
        plt_add_apps: ~w(gettext inets jason mix poison plug)a
      ],
      compilers: Mix.compilers()
    ]
  end

  defp description do
    """
    Functions to parse URLs incuding scheme-specific
    URLs such as `tel`, `data`, `geo`, `uuid` and `mailto`.
    Modelled on the URI module.
    """
  end

  def application do
    [
      extra_applications: [:logger]
    ]
  end

  defp deps do
    [
      {:nimble_parsec, "~> 0.5"},
      {:jason, "~> 1.0"},
      {:ex_doc, "~> 0.18", only: [:dev, :release]},
      {:ex_phone_number, "~> 0.1", optional: true},
      {:ex_cldr, "~> 2.0", optional: true},
      {:gettext, "~> 0.13", optional: true}
    ]
  end

  defp package do
    [
      maintainers: ["Kip Cole"],
      licenses: ["Apache 2.0"],
      links: links(),
      files: [
        "lib",
        "config",
        "mix.exs",
        "README*",
        "CHANGELOG*",
        "LICENSE*",
      ]
    ]
  end

  def links do
    %{
      "GitHub" => "https://github.com/kipcole9/url",
      "Readme" => "https://github.com/kipcole9/url/blob/v#{@version}/README.md",
      "Changelog" => "https://github.com/kipcole9/url/blob/v#{@version}/CHANGELOG.md"
    }
  end

  def docs do
    [
      source_ref: "v#{@version}",
      main: "readme",
      extras: [
        "README.md",
        "LICENSE.md",
        "CHANGELOG.md"
      ],
    ]
  end

  def aliases do
    []
  end

  defp elixirc_paths(:test), do: ["lib", "mix", "test"]
  defp elixirc_paths(:dev), do: ["lib", "mix", "bench"]
  defp elixirc_paths(_), do: ["lib"]
end
