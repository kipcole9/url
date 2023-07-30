defmodule URL.Mailto do
  @moduledoc """
  Parses a `mailto` URL
  """
  import NimbleParsec
  import URL.ParseHelpers.{Core, Mailto, Unwrap}
  alias URL.ParseHelpers.Params

  @type t() :: %__MODULE__{
    to: [binary(), ...],
    params: map()
  }

  defstruct to: nil, params: %{}

  @doc """
  Parse a URI with the `:scheme` of "tel"

  ## Example

      iex> mailto = URI.parse("mailto:user@%E7%B4%8D%E8%B1%86.example.org?subject=Test&body=NATTO")
      iex> URL.Mailto.parse(mailto)
      {:ok,
       %URL.Mailto{
         to: ["user@納豆.example.org"],
         params: %{"body" => "NATTO", "subject" => "Test"}
       }}

  """
  @spec parse(URI.t()) :: {:ok, __MODULE__.t()} | {:error, {module(), binary()}}
  def parse(%URI{scheme: "mailto", path: path, query: query}) do
    with {:ok, mailto} <- unwrap(parse_mailto(path)),
         {:ok, [params]} <- unwrap(URL.parse_query(query)) do
      mailto
      |> structify(__MODULE__)
      |> Map.put(:params, params)
      |> Params.wrap(:ok)
    end
  end

  defparsecp :parse_mailto,
    optional(to())

end