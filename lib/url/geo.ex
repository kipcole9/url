defmodule URL.Geo do
  import NimbleParsec
  import URL.ParseHelpers.{Core, Params, Unwrap}
  alias URL.ParseHelpers.Params

  defstruct lat: 0.0, lng: 0.0, alt: nil, params: %{}

  @param_map %{
    "u" => &Params.numberize/1
  }

  def parse(%URI{scheme: "geo", path: path} = _uri) do
    with {:ok, geo} <- unwrap(parse_geo(path)) do
      geo
      |> normalize_params(@param_map)
      |> structify(__MODULE__)
    end
  end

  defparsec :parse_geo,
    number() |> unwrap_and_tag(:lat)
    |> ignore(comma())
    |> concat(number() |> unwrap_and_tag(:lng))
    |> optional(ignore(comma()) |> concat(number()) |> unwrap_and_tag(:alt))
    |> concat(params())

end