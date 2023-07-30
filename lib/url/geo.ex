defmodule URL.Geo do
  @moduledoc """
  Parses a `geo` URL
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
  Parse a URI with the `:scheme` of "geo"

  ## Example

      iex> geo = URI.parse("geo:48.198634,-16.371648,3.4;crs=wgs84;u=40.0")
      iex> URL.Geo.parse(geo)
      {:ok,
       %URL.Geo{
         lat: 48.198634,
         lng: -16.371648,
         alt: 3.4,
         params: %{"crs" => "wgs84", "u" => 40.0}
       }}

  """
  @spec parse(URI.t()) :: {:ok, __MODULE__.t()} | {:error, {module(), binary()}}
  def parse(%URI{scheme: "geo", path: path}) do
    with {:ok, geo} <- unwrap(parse_geo(path)) do
      geo
      |> normalize_params(@param_map)
      |> structify(__MODULE__)
      |> Params.wrap(:ok)
    end
  end

  defparsecp :parse_geo,
    number() |> unwrap_and_tag(:lat) |> label("lng")
    |> ignore(comma())
    |> concat(number() |> unwrap_and_tag(:lng)) |> label("lat")
    |> optional(ignore(comma()) |> concat(number()) |> unwrap_and_tag(:alt)) |> label("alt")
    |> concat(params())
    |> label("geo data")

end