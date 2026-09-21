defmodule URL.Geo do
  @moduledoc """
  Parses the scheme-specific part of a `geo` URL as defined
  in [RFC 5870](https://tools.ietf.org/rfc/rfc5870).

  A `geo` URL carries a latitude, a longitude, an optional
  altitude and optional parameters such as `crs` and `u`. The
  primary API is `parse/1`, which `URL.new/1` calls for any URL
  with the `geo` scheme.

  """
  import NimbleParsec
  import URL.ParseHelpers.{Core, Params, Unwrap}
  alias URL.ParseHelpers.Params

  @type t() :: %__MODULE__{
          lat: number(),
          lng: number(),
          alt: nil | number(),
          params: map()
        }

  defstruct lat: 0.0, lng: 0.0, alt: nil, params: %{}

  @param_map %{
    "u" => &Params.numberize/1
  }

  @doc """
  Parses the path of a `geo` URI into a `t:t/0` struct.

  ### Arguments

  * `uri` is a `t:URI.t/0` whose `:scheme` is `"geo"`.

  ### Returns

  * `{:ok, t:t/0}` with the latitude, longitude, altitude (`nil`
    when absent) and parameters. The `u` (uncertainty) parameter
    is converted to a number, or

  * `{:error, {URL.Parser.ParseError, reason}}` if the path is
    not a valid `geo` payload, including an empty path.

  ### Examples

      iex> geo = URI.parse("geo:48.198634,-16.371648,3.4;crs=wgs84;u=40.0")
      iex> URL.Geo.parse(geo)
      {:ok,
       %URL.Geo{
         lat: 48.198634,
         lng: -16.371648,
         alt: 3.4,
         params: %{"crs" => "wgs84", "u" => 40.0}
       }}

      iex> URL.Geo.parse(URI.parse("geo:48.198634,-16.371648"))
      {:ok, %URL.Geo{lat: 48.198634, lng: -16.371648, alt: nil, params: %{}}}

      iex> {:error, {URL.Parser.ParseError, _reason}} = URL.Geo.parse(URI.parse("geo:48.198634"))

  """
  @spec parse(URI.t()) :: {:ok, __MODULE__.t()} | {:error, {module(), binary()}}
  def parse(%URI{scheme: "geo", path: nil} = uri) do
    parse(%{uri | path: ""})
  end

  def parse(%URI{scheme: "geo", path: path}) do
    with {:ok, geo} <- unwrap(parse_geo(path)) do
      geo
      |> normalize_params(@param_map)
      |> structify(__MODULE__)
      |> Params.wrap(:ok)
    end
  end

  defparsecp(
    :parse_geo,
    number()
    |> unwrap_and_tag(:lat)
    |> label("lng")
    |> ignore(comma())
    |> concat(number() |> unwrap_and_tag(:lng))
    |> label("lat")
    |> optional(ignore(comma()) |> concat(number()) |> unwrap_and_tag(:alt))
    |> label("alt")
    |> concat(params())
    |> label("geo data")
  )
end
