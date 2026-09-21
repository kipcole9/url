defmodule URL.UUID do
  @moduledoc """
  Parses the scheme-specific part of a `uuid` URL as described in
  [draft-kindel-uuid-uri](https://tools.ietf.org/html/draft-kindel-uuid-uri-00),
  and the `urn:uuid:` form of the same identifier.

  The primary API is `parse/1`, which `URL.new/1` calls for any
  URL with the `uuid` or `urn` scheme. A `urn` whose namespace is
  not `uuid` is accepted but yields no parsed path.

  """
  import NimbleParsec
  import URL.ParseHelpers.{Core, Params, Unwrap}
  alias URL.ParseHelpers.Params

  @type t() :: %__MODULE__{
          uuid: binary(),
          params: map()
        }

  defstruct uuid: nil, params: %{}

  @doc """
  Parses the path of a `uuid` or `urn` URI into a `t:t/0` struct.

  ### Arguments

  * `uri` is a `t:URI.t/0` whose `:scheme` is `"uuid"` or `"urn"`.

  ### Returns

  * `{:ok, t:t/0}` with the UUID and any parameters, or

  * `{:ok, nil}` for a `urn` whose namespace is not `uuid`, or

  * `{:error, {URL.Parser.ParseError, reason}}` if the path is
    not a valid UUID, or the `urn` has no namespace identifier.

  ### Examples

      iex> uuid = URI.parse("uuid:f81d4fae-7dec-11d0-a765-00a0c91e6bf6;a=b")
      iex> URL.UUID.parse(uuid)
      {:ok,
       %URL.UUID{uuid: "f81d4fae-7dec-11d0-a765-00a0c91e6bf6", params: %{"a" => "b"}}}

      iex> uuid = URI.parse("urn:uuid:f81d4fae-7dec-11d0-a765-00a0c91e6bf6;a=b")
      iex> URL.UUID.parse(uuid)
      {:ok, %URL.UUID{params: %{"a" => "b"}, uuid: "f81d4fae-7dec-11d0-a765-00a0c91e6bf6"}}

      iex> URL.UUID.parse(URI.parse("urn:isbn:0451450523"))
      {:ok, nil}

      iex> {:error, {URL.Parser.ParseError, _reason}} = URL.UUID.parse(URI.parse("uuid:not-a-uuid"))

  """
  @spec parse(URI.t()) :: {:ok, __MODULE__.t()} | {:error, {module(), binary()}}
  def parse(%URI{scheme: "uuid", path: nil} = uri) do
    parse(%{uri | path: ""})
  end

  def parse(%URI{scheme: "uuid", path: path}) do
    with {:ok, uuid} <- unwrap(parse_uuid(path)) do
      uuid
      |> structify(__MODULE__)
      |> Params.wrap(:ok)
    end
  end

  def parse(%URI{scheme: "urn", path: path}) when path in [nil, ""] do
    {:error, {URL.Parser.ParseError, "expected a URN namespace identifier after \"urn:\""}}
  end

  def parse(%URI{scheme: "urn", path: path}) do
    case URL.new(path) do
      {:ok, %URL{parsed_path: parsed_path}} -> {:ok, parsed_path}
      other -> other
    end
  end

  defparsecp(
    :parse_uuid,
    uuid()
    |> concat(params())
  )
end
