defmodule URL.UUID do
  @moduledoc """
  Parses a `geo` URL
  """
  import NimbleParsec
  import URL.ParseHelpers.{Core, Params, Unwrap}

  @type t() :: %__MODULE__{
    uuid: binary(),
    params: map()
  }

  defstruct uuid: nil, params: %{}

  @doc """
  Parse a URI with the `:scheme` of "uuid"

  ## Example

      iex> uuid = URI.parse("uuid:f81d4fae-7dec-11d0-a765-00a0c91e6bf6;a=b")
      iex> URL.UUID.parse(uuid)
      %URL.UUID{params: %{"a" => "b"}, uuid: "f81d4fae-7dec-11d0-a765-00a0c91e6bf6"}

      iex> uuid = URI.parse("urn:uuid:f81d4fae-7dec-11d0-a765-00a0c91e6bf6;a=b")
      iex> URL.UUID.parse(uuid)
      %URL.UUID{params: %{"a" => "b"}, uuid: "f81d4fae-7dec-11d0-a765-00a0c91e6bf6"}

  """
  @spec parse(URI.t()) :: __MODULE__.t() | {:error, {module(), binary()}}
  def parse(%URI{scheme: "uuid", path: path}) do
    with {:ok, uuid} <- unwrap(parse_uuid(path)) do
      uuid
      |> structify(__MODULE__)
    end
  end

  def parse(%URI{scheme: "urn", path: path}) do
    case URL.new(path) do
      {:ok, %URL{parsed_path: parsed_path}} -> parsed_path
      other -> other
    end
  end

  defparsecp :parse_uuid,
    uuid()
    |> concat(params())

end