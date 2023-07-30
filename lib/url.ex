defmodule URL do
  @moduledoc """
  Functions for parsing URLs

  This module provides functions for parsing URLs. It is modelled on
  Elixir's `URI` module but will also parse scheme-specific URIs such
  as [geo](https://tools.ietf.org/rfc/rfc5870), [data](https://tools.ietf.org/html/rfc2397)
  [tel](https://tools.ietf.org/html/rfc3966), [mailto](https://tools.ietf.org/html/rfc2047),
  and [uuid](https://tools.ietf.org/html/draft-kindel-uuid-uri-00).

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
  Parses a url and returns a %URL{} struct that
  has the same shape as Elixir's %URI{} with the
  addition of the `parsed_path` key.

  ## Arguments

  * `url` is a binary representation of a URL

  ## Returns

  * `{:ok, t:URL.t/0}` or

  * `{:error, {exception, reason}}`

  ## Example

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

  """
  @spec new(url :: binary()) :: {:ok, __MODULE__.t()} | {:error, {module(), String.t()}}
  def new(url) when is_binary(url) do
    with {:ok, uri} <- uri_new(url),
         {:ok, scheme} <- parse_scheme(uri) do
      {:ok, merge_uri(uri, scheme)}
    end
  end

  @doc """
  Parses a url and returns a %URL{} struct that
  has the same shape as Elixir's %URI{} with the
  addition of the `parsed_path` key.

  ## Arguments

  * `url` is a binary representation of a URL

  ## Returns

  * `t:URL.t/0` or

  * raises an exception

  ## Example

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
  def new!(url) when is_binary(url) do
    case new(url) do
      {:ok, parsed} ->
        parsed

      {:error, {URL.Parser.ParseError = exception, reason}} ->
        raise(exception, reason)

      {:error, {URI.Error = exception, reason}} ->
        raise(exception, action: "parse", reason: "invalid_uri", part: reason)
    end
  end

  @doc false
  @deprecated "Use new/1 instead"
  @spec parse(url :: binary()) :: {:ok, __MODULE__.t()} | {:error, {module(), String.t()}}
  def parse(url) when is_binary(url) do
    new(url)
  end

  @doc """
  Parse a URL query string and percent decode.

  ## Returns

  * Either a map of query params or

  * an `{:error, {URL.Parser.ParseError, reason}}` tuple

  ## Examples

      iex> URL.parse_query_string "url=http%3a%2f%2ffonzi.com%2f&name=Fonzi&mood=happy&coat=leather"
      %{
        "coat" => "leather",
        "mood" => "happy",
        "name" => "Fonzi",
        "url" => "http://fonzi.com/"
      }

      iex> mailto = "mailto:user@%E7%B4%8D%E8%B1%86.example.org?subject=Test&body=NATTO"
      iex> URL.new!(mailto) |> URL.parse_query_string
      %{"body" => "NATTO", "subject" => "Test"}

  """
  @spec parse_query_string(String.t() | map()) :: map() | {:error, {module(), binary()}}
  def parse_query_string(query) when is_binary(query) do
    with {:ok, [params]} <- unwrap(parse_query(query)) do
      params
    end
  end

  def parse_query_string({:error, {_, _}} = error) do
    error
  end

  def parse_query_string(%{query: query}) do
    parse_query_string(query)
  end

  @doc false
  def parse_query(nil) do
    {:ok, [%{}], "", %{}, {0, 0}, 0}
  end

  defparsec :parse_query,
            optional(hfields())

  defdelegate to_string(url), to: URI

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

  def uri_new(uri) do
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
