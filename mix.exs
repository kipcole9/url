defmodule Url.MixProject do
  use Mix.Project

  @source_url "https://github.com/kipcole9/url"

  @version "2.0.3"

  def project do
    [
      app: :ex_url,
      version: @version,
      elixir: "~> 1.17",
      name: "URL",
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
        plt_add_apps: ~w(gettext inets mix localize ex_phone_number)a
      ],
      compilers: Mix.compilers()
    ]
  end

  defp description do
    """
    Functions to parse URLs including scheme-specific
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
      {:nimble_parsec, ">= 1.4.1 or ~> 1.5"},
      {:ex_doc, "~> 0.40", only: [:dev, :release], runtime: false},
      {:ex_phone_number, "~> 0.1", optional: true},
      {:localize, "~> 1.2", optional: true},
      {:gettext, "~> 0.13 or ~> 1.0", optional: true},
      {:dialyxir, "~> 1.0", only: [:dev], runtime: false, optional: true}
    ] ++ maybe_json_polyfill()
  end

  # `localize` needs the OTP 27+ `:json` module. On OTP 26 it is
  # supplied by `json_polyfill`, which is deliberately only a dev/test
  # dependency of this project (so it never enters the hex package
  # requirements). An OTP 26 consumer that opts into `localize` adds
  # `{:json_polyfill, "~> 0.2 or ~> 1.0"}` to its own deps (see README);
  # `localize` raises with those instructions at application start
  # when `:json` is missing. The conditional avoids fetching the
  # polyfill on OTP 27 and later, where its own build fails.
  defp maybe_json_polyfill do
    if Code.ensure_loaded?(:json) do
      []
    else
      [{:json_polyfill, "~> 0.2 or ~> 1.0", only: [:dev, :test]}]
    end
  end

  defp package do
    [
      maintainers: ["Kip Cole"],
      licenses: ["Apache-2.0"],
      links: links(),
      files: [
        "lib",
        "config",
        "mix.exs",
        "README*",
        "CHANGELOG*",
        "LICENSE*"
      ]
    ]
  end

  def links do
    %{
      "GitHub" => @source_url,
      "Readme" => "#{@source_url}/blob/v#{@version}/README.md",
      "Changelog" => "#{@source_url}/blob/v#{@version}/CHANGELOG.md"
    }
  end

  def docs do
    [
      main: "readme",
      extras: [
        "README.md",
        "LICENSE.md",
        "CHANGELOG.md"
      ],
      source_url: @source_url,
      source_ref: "v#{@version}",
      formatters: ["html", "markdown"],
      groups_for_modules: groups_for_modules(),
      skip_undefined_reference_warnings_on: ["changelog", "CHANGELOG.md"]
    ]
  end

  defp groups_for_modules do
    [
      Schemes: [URL.Data, URL.Geo, URL.Mailto, URL.Tel, URL.UUID],
      Exceptions: [URL.Parser.ParseError]
    ]
  end

  def aliases do
    []
  end

  defp elixirc_paths(:test), do: ["lib", "test"]
  defp elixirc_paths(_), do: ["lib"]
end
