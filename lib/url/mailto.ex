defmodule URL.Mailto do
  @moduledoc """
  Parses the scheme-specific part of a `mailto` URL as defined
  in [RFC 6068](https://tools.ietf.org/html/rfc6068).

  The recipient addresses and the header fields in the query
  (`subject`, `body` and so on) are percent-decoded during
  parsing. [RFC 2047](https://tools.ietf.org/html/rfc2047)
  encoded words are not decoded. The primary API is `parse/1`,
  which `URL.new/1` calls for any URL with the `mailto` scheme.

  """
  import NimbleParsec
  import URL.ParseHelpers.{Core, Mailto, Unwrap}
  alias URL.ParseHelpers.Params

  @type t() :: %__MODULE__{
          to: [binary()],
          params: map()
        }

  defstruct to: [], params: %{}

  @doc """
  Parses the path and query of a `mailto` URI into a `t:t/0` struct.

  ### Arguments

  * `uri` is a `t:URI.t/0` whose `:scheme` is `"mailto"`.

  ### Returns

  * `{:ok, t:t/0}` with the list of recipient addresses in `:to`
    (empty when the URL has no address) and the decoded header
    fields in `:params`, or

  * `{:error, {URL.Parser.ParseError, reason}}` if the address
    list or a header field cannot be parsed.

  ### Examples

      iex> mailto = URI.parse("mailto:user@%E7%B4%8D%E8%B1%86.example.org?subject=Test&body=NATTO")
      iex> URL.Mailto.parse(mailto)
      {:ok,
       %URL.Mailto{
         to: ["user@納豆.example.org"],
         params: %{"body" => "NATTO", "subject" => "Test"}
       }}

      iex> URL.Mailto.parse(URI.parse("mailto:?subject=Test"))
      {:ok, %URL.Mailto{to: [], params: %{"subject" => "Test"}}}

      iex> {:error, {URL.Parser.ParseError, _reason}} = URL.Mailto.parse(URI.parse("mailto:a@b.com?subject"))

  """
  @spec parse(URI.t()) :: {:ok, __MODULE__.t()} | {:error, {module(), binary()}}
  def parse(%URI{scheme: "mailto", path: nil} = uri) do
    parse(%{uri | path: ""})
  end

  def parse(%URI{scheme: "mailto", path: path, query: query}) do
    with {:ok, mailto} <- unwrap(parse_mailto(path)),
         {:ok, [params]} <- unwrap(URL.parse_query(query)) do
      mailto
      |> structify(__MODULE__)
      |> Map.put(:params, params)
      |> Params.wrap(:ok)
    end
  end

  defparsecp(
    :parse_mailto,
    optional(to())
  )
end
