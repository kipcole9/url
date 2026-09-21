defmodule URL do
  @moduledoc """
  Functions for parsing URLs.

  This module provides functions for parsing URLs. It is modelled on
  Elixir's `URI` module but will also parse scheme-specific URIs such
  as [geo](https://tools.ietf.org/rfc/rfc5870), [data](https://tools.ietf.org/html/rfc2397)
  [tel](https://tools.ietf.org/html/rfc3966), [mailto](https://tools.ietf.org/html/rfc6068),
  and [uuid](https://tools.ietf.org/html/draft-kindel-uuid-uri-00).

  The primary API is `new/1`, which returns a `t:t/0` struct with the
  same shape as `t:URI.t/0` plus a `:parsed_path` holding the parsed
  scheme-specific data (`URL.Geo`, `URL.Data`, `URL.Tel`, `URL.Mailto`
  or `URL.UUID`), or `nil` for any other scheme. `new!/1` raises
  instead of returning an error tuple, `to_string/1` reverses the
  parse and `parse_query_string/1` decodes a query into a map.
  No function in this module raises on malformed input.

  """
  @type uri_type :: nil | URL.Data.t() | URL.Geo.t() | URL.Tel.t() | URL.UUID.t() | URL.Mailto.t()

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
          parsed_path: uri_type()
        }

  @supported_schemes %{
    "tel" => URL.Tel,
    "data" => URL.Data,
    "geo" => URL.Geo,
    "mailto" => URL.Mailto,
    "uuid" => URL.UUID,
    "urn" => URL.UUID
  }

  import URL.ParseHelpers.Core, only: [structify: 2]
  import NimbleParsec
  import URL.ParseHelpers.{Core, Mailto, Params, Unwrap}

  @doc """
  Parses a string url and returns a `t:URL.t/0` struct that
  has the same shape as Elixir's `t:URI.t/0` with the
  addition of the `parsed_path` key.

  ### Arguments

  * `url` is a binary representation of a URL.

  ### Returns

  * `{:ok, URL.t()}` or

  * `{:error, {exception, reason}}`. `exception` is `URI.Error` when
    the URL is not syntactically valid, `URL.Parser.ParseError` when the
    scheme-specific path cannot be parsed and `ArgumentError` when `url`
    is not a binary.

  ### Examples

      iex> URL.new("geo:48.198634,-16.371648,3.4;crs=wgs84;u=40.0")
      {:ok,
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
      }

      iex> URL.new("geo:48.198634,--16.371648,3.4;crs=wgs84;u=40.0")
      {:error,
       {URL.Parser.ParseError,
        "expected an string of digits while processing lat inside alt inside geo data. Detected on line 1 at \\"-16.371648,3.4;crs=w\\" <> ..."}}

      iex> URL.new "/invalid_greater_than_in_path/>"
      {:error,
       {URI.Error,
        "cannot parse due to reason invalid_uri: \\">\\""}}

      iex> URL.new(:not_a_url)
      {:error, {ArgumentError, "expected a binary URL, got: :not_a_url"}}

  """
  @spec new(url :: binary()) :: {:ok, __MODULE__.t()} | {:error, {module(), String.t()}}
  def new(url) when is_binary(url) do
    with {:ok, uri} <- uri_new(url),
         {:ok, scheme} <- parse_scheme(uri) do
      {:ok, merge_uri(uri, scheme)}
    end
  end

  def new(other) do
    {:error, {ArgumentError, "expected a binary URL, got: #{inspect(other)}"}}
  end

  @doc """
  Parses a string url and returns a `t:URL.t/0` struct that
  has the same shape as Elixir's `t:URI.t/0` with the
  addition of the `parsed_path` key, or raises an exception.

  ### Arguments

  * `url` is a binary representation of a URL.

  ### Returns

  * `t:URL.t/0` or

  * raises an exception.

  ### Examples

      iex> URL.new!("geo:48.198634,-16.371648,3.4;crs=wgs84;u=40.0")
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
  @spec new!(url :: binary()) :: __MODULE__.t() | no_return()
  def new!(url) do
    case new(url) do
      {:ok, parsed} ->
        parsed

      {:error, {URL.Parser.ParseError = exception, reason}} ->
        raise(exception, reason)

      {:error, {URI.Error = exception, reason}} ->
        raise(exception, action: "parse", reason: "invalid_uri", part: reason)

      {:error, {exception, reason}} ->
        raise(exception, reason)
    end
  end

  @doc """
  Returns the string representation of the given URL struct (t:t/0).

  This function delegates to `URI.to_string/1`.

  ### Arguments

  * `url` is any `t:URL.t/0`.

  ### Returns

  * a string representation of the URL.

  ### Examples

      iex> {:ok, geo_url} = URL.new("geo:48.198634,-16.371648,3.4;crs=wgs84;u=40.0")
      iex> URL.to_string(geo_url)
      "geo:48.198634,-16.371648,3.4;crs=wgs84;u=40.0"

  """
  @spec to_string(t()) :: String.t()
  def to_string(%URL{} = url) do
    url
    |> Map.from_struct()
    |> Map.delete(:parsed_path)
    |> then(&struct(URI, &1))
    |> URI.to_string()
  end

  @doc false
  @deprecated "Use new/1 instead"
  @spec parse(url :: binary()) :: {:ok, __MODULE__.t()} | {:error, {module(), String.t()}}
  def parse(url) when is_binary(url) do
    new(url)
  end

  @doc """
  Parse and percent decode a URL query string.

  ### Arguments

  * `query` is a query string, a `t:URL.t/0` (or any map with a
    `:query` key) whose query is parsed, or an `{:error, reason}`
    tuple which is returned unchanged so this function can be
    piped after `new/1`.

  ### Returns

  * Either a map of query params (an empty map when the query is `nil`) or

  * an `{:error, {exception, reason}}` tuple.

  ### Examples

      iex> URL.parse_query_string("url=http%3a%2f%2ffonzi.com%2f&name=Fonzi&mood=happy&coat=leather")
      %{
        "coat" => "leather",
        "mood" => "happy",
        "name" => "Fonzi",
        "url" => "http://fonzi.com/"
      }

      iex> mailto = "mailto:user@%E7%B4%8D%E8%B1%86.example.org?subject=Test&body=NATTO"
      iex> URL.new!(mailto) |> URL.parse_query_string()
      %{"body" => "NATTO", "subject" => "Test"}

      iex> URL.new!("geo:48.198634,-16.371648") |> URL.parse_query_string()
      %{}

  """
  @spec parse_query_string(String.t() | nil | map() | {:error, {module(), binary()}}) ::
          map() | {:error, {module(), binary()}}
  def parse_query_string(query) when is_binary(query) do
    with {:ok, [params]} <- unwrap(parse_query(query)) do
      params
    end
  end

  def parse_query_string(nil) do
    %{}
  end

  def parse_query_string({:error, {_, _}} = error) do
    error
  end

  def parse_query_string(%{query: query}) do
    parse_query_string(query)
  end

  def parse_query_string(other) do
    {:error, {ArgumentError, "expected a query string or URL, got: #{inspect(other)}"}}
  end

  @doc false
  def parse_query(nil) do
    {:ok, [%{}], "", %{}, {0, 0}, 0}
  end

  @doc false
  defparsec :parse_query,
            optional(hfields())

  for {scheme, module} <- @supported_schemes do
    defp parse_scheme(%URI{scheme: unquote(scheme)} = uri) do
      unquote(module).parse(uri)
    end
  end

  defp parse_scheme(%URI{}) do
    {:ok, nil}
  end

  defp merge_uri(uri, parsed_path) do
    uri
    |> Map.to_list()
    |> Enum.map(&__MODULE__.trim/1)
    |> structify(__MODULE__)
    |> add_parsed_path(parsed_path)
  end

  defp add_parsed_path(url, parsed_path) do
    Map.put(url, :parsed_path, parsed_path)
  end

  @doc false
  def trim({key, item}) when is_binary(item) do
    {key, String.trim(item)}
  end

  def trim(other) do
    other
  end

  defp uri_new(uri) do
    case URI.new(uri) do
      {:error, reason} -> {:error, uri_error(reason)}
      {:ok, uri} -> {:ok, uri}
    end
  end

  defp uri_error(part) do
    message = URI.Error.message(%URI.Error{action: "parse", reason: "invalid_uri", part: part})
    {URI.Error, message}
  end
end
