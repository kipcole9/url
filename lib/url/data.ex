defmodule URL.Data do
  import NimbleParsec
  import URL.ParseHelpers.{Core, Params, Unwrap}

  @default_mediatype "text/plain"
  defstruct mediatype: @default_mediatype, params: %{}, data: ""

  #   dataurl    := "data:" [ mediatype ] [ ";base64" ] "," data
  #   mediatype  := [ type "/" subtype ] *( ";" parameter )
  #   data       := *urlchar
  #   parameter  := attribute "=" value

  def parse(%URI{scheme: "data", path: path} = _uri) do
    with {:ok, data} <- unwrap(parse_data(path)) do
      struct(__MODULE__, data)
      |> decode_data
    end
  end

  def decode_data(%__MODULE__{params: %{encoding: :base64}} = data) do
    Map.put(data, :data, Base.decode64(data.data))
  end

  def decode_data(%__MODULE__{} = data) do
    Map.put(data, :data, URI.decode(data.data))
  end

  defparsec :parse_data,
      optional(mediatype())
      |> concat(params())
      |> ignore(comma())
      |> concat(data())
end