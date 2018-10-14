defmodule URL.Data do
  import NimbleParsec
  import URL.ParseHelpers.{Core, Params, Unwrap}

  @default_mediatype "text/plain"
  defstruct mediatype: @default_mediatype, params: %{}, data: ""

  @type t() :: %__MODULE__{
    mediatype: binary(),
    params: Map.t()
  }

  @spec parse(URI.t()) :: __MODULE__.t() | {:error, {module(), binary()}}
  def parse(%URI{scheme: "data", path: path}) do
    with {:ok, data} <- unwrap(parse_data(path)) do
      struct(__MODULE__, data)
      |> decode_data
    end
  end

  defp decode_data(%__MODULE__{params: %{"encoding" => "base64"}} = data) do
    case Base.decode64(data.data) do
      {:ok, decoded} -> Map.put(data, :data, decoded)
    end
  end

  defp decode_data(%__MODULE__{} = data) do
    Map.put(data, :data, URI.decode(data.data))
  end

  defparsecp :parse_data,
      optional(mediatype())
      |> concat(params())
      |> ignore(comma())
      |> concat(data())
end