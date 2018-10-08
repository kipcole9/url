defmodule Url.MixProject do
  use Mix.Project

  def project do
    [
      app: :url,
      version: "0.1.0",
      elixir: "~> 1.7",
      start_permanent: Mix.env() == :prod,
      deps: deps()
    ]
  end

  def application do
    [
      extra_applications: [:logger]
    ]
  end

  defp deps do
    [
      {:ex_phone_number, "~> 0.1"},
      {:nimble_parsec, "~> 0.4"}
    ]
  end
end
