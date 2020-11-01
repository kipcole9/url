defmodule URL.Data do
  @moduledoc """
  Parses a `data` URL
  """
  import NimbleParsec
  import URL.ParseHelpers.{Core, Params, Unwrap}

  @default_mediatype "text/plain"
  defstruct mediatype: @default_mediatype, params: %{}, data: ""

  @type t() :: %__MODULE__{
    mediatype: binary(),
    params: map()
  }

  @doc """
  Parse a URI with the `:scheme` of "data"

  ## Example

      iex> data = URI.parse "data:text/plain;base64,SGVsbG8gV29ybGQh"
      iex> URL.Data.parse(data)
      %URL.Data{
        data: "Hello World!",
        mediatype: "text/plain",
        params: %{"encoding" => "base64"}
      }

  """
  @spec parse(URI.t()) :: __MODULE__.t() | {:error, {module(), binary()}}
  def parse(%URI{scheme: "data", path: path}) do
    with {:ok, data} <- unwrap(parse_data(path)) do
      struct(__MODULE__, data)
      |> decode_data
    end
  end

  defp decode_data(%__MODULE__{params: %{"encoding" => "base64"}, data: data} = url) do
    case Base.decode64(data) do
      {:ok, decoded} -> Map.put(url, :data, decoded)
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