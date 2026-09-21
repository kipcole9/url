defmodule URL.Data do
  @moduledoc """
  Parses the scheme-specific part of a `data` URL as defined
  in [RFC 2397](https://tools.ietf.org/html/rfc2397).

  The payload is decoded during parsing: base64 payloads
  (those with the `;base64` parameter) are base64-decoded and
  all others are percent-decoded. The primary API is `parse/1`,
  which `URL.new/1` calls for any URL with the `data` scheme.

  """
  import NimbleParsec
  import URL.ParseHelpers.{Core, Params, Unwrap}
  alias URL.ParseHelpers.Params

  @default_mediatype "text/plain"
  defstruct mediatype: @default_mediatype, params: %{}, data: ""

  @type t() :: %__MODULE__{
          mediatype: binary(),
          params: map(),
          data: String.t() | {:error, String.t()}
        }

  @doc """
  Parses the path of a `data` URI into a `t:t/0` struct.

  ### Arguments

  * `uri` is a `t:URI.t/0` whose `:scheme` is `"data"`.

  ### Returns

  * `{:ok, t:t/0}` with the media type, parameters and decoded
    payload. The media type defaults to `"text/plain"`. A base64
    payload that cannot be decoded is returned as
    `{:error, raw_payload}` in the `:data` field, or

  * `{:error, {URL.Parser.ParseError, reason}}` if the path is
    not a valid `data` payload.

  ### Examples

      iex> data = URI.parse "data:text/plain;base64,SGVsbG8gV29ybGQh"
      iex> URL.Data.parse(data)
      {:ok,
       %URL.Data{
         mediatype: "text/plain",
         params: %{"encoding" => "base64"},
         data: "Hello World!"
       }}

      iex> URL.Data.parse(URI.parse("data:,Hello%20World%21"))
      {:ok, %URL.Data{mediatype: "text/plain", params: %{}, data: "Hello World!"}}

      iex> URL.Data.parse(URI.parse("data:;base64"))
      {:error,
       {URL.Parser.ParseError,
        "expected a comma. Detected on line 1 at \\"\\""}}

  """
  @spec parse(URI.t()) :: {:ok, __MODULE__.t()} | {:error, {module(), binary()}}
  def parse(%URI{scheme: "data", path: nil}) do
    __MODULE__
    |> struct(data: "")
    |> Params.wrap(:ok)
  end

  def parse(%URI{scheme: "data", path: path}) do
    with {:ok, data} <- unwrap(parse_data(path)) do
      struct(__MODULE__, data)
      |> decode_data
      |> Params.wrap(:ok)
    end
  end

  defp decode_data(%__MODULE__{params: %{"encoding" => "base64"}, data: data} = url) do
    case Base.decode64(data) do
      {:ok, decoded} -> Map.put(url, :data, decoded)
      :error -> Map.put(url, :data, {:error, data})
    end
  end

  defp decode_data(%__MODULE__{} = data) do
    Map.put(data, :data, URI.decode(data.data))
  end

  defparsecp(
    :parse_data,
    optional(mediatype())
    |> concat(params())
    |> ignore(comma())
    |> concat(data())
  )
end
