defmodule URL do
  @moduledoc """
  Utilities for working with URLs.

  This module provides functions for parsing URLs. It is modelled on
  Elixir's `URI` module but will also parse scheme-specific URIs such
  as [geo](https://tools.ietf.org/rfc/rfc5870), [data](https://tools.ietf.org/html/rfc2397)
  and [tel](https://tools.ietf.org/html/rfc3966).

  """
  defstruct scheme: nil,
    path: nil,
    query: nil,
    fragment: nil,
    authority: nil,
    userinfo: nil,
    host: nil,
    port: nil,
    parsed_path: nil

  @type t() :: %__MODULE__{
    authority: nil | binary(),
    fragment: nil | binary(),
    host: nil | binary(),
    path: nil | binary(),
    port: nil | :inet.port_number(),
    query: nil | binary(),
    scheme: nil | binary(),
    userinfo: nil | binary(),
    parsed_path: nil | URL.Data.t() | URL.Geo.t() | URL.Tel.t()
  }

  @supported_schemes %{
    "tel" => URL.Tel,
    "data" => URL.Data,
    "geo" =>  URL.Geo
  }

  import URL.ParseHelpers.Core, only: [structify: 2]

  @doc """
  Parses a url and returns a %URL{} struct that
  has the same shape as Elixir's %URI{} with the
  addition of the `p:arsed_path` key.

  ## Example

    iex> URL.parse("geo:48.198634,-16.371648,3.4;crs=wgs84;u=40.0")
    %URL{
      authority: nil,
      fragment: nil,
      host: nil,
      parsed_path: %URL.Geo{
        alt: 3.4,
        lat: 48.198634,
        lng: -16.371648,
        params: %{"crs" => "wgs84", "u" => 40.0}
      },
      path: "48.198634,-16.371648,3.4;crs=wgs84;u=40.0",
      port: nil,
      query: nil,
      scheme: "geo",
      userinfo: nil
    }

  """
  @spec parse(url :: binary()) :: __MODULE__.t()
  def parse(url) when is_binary(url) do
    url
    |> parse_scheme
    |> merge_uri
  end

  defdelegate to_string(url), to: URI

  defp parse_scheme(url) when is_binary(url) do
    url
    |> URI.parse
    |> parse_scheme
  end

  for {scheme, module} <- @supported_schemes do
    defp parse_scheme(%URI{scheme: unquote(scheme)} = uri) do
      {uri, unquote(module).parse(uri)}
    end
  end

  defp parse_scheme(%URI{} = uri) do
    {uri, nil}
  end

  defp merge_uri({uri, parsed_path}) do
    uri
    |> Map.to_list
    |> structify(__MODULE__)
    |> add_parsed_path(parsed_path)
  end

  defp add_parsed_path(url, parsed_path) do
    Map.put(url, :parsed_path, parsed_path)
  end

end
