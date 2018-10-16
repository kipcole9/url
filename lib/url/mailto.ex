defmodule URL.Mailto do
  @moduledoc """
  Parses a `mailto` URL
  """
  import NimbleParsec
  import URL.ParseHelpers.{Core, Mailto, Params, Unwrap}

  @type t() :: %__MODULE__{
    to: [binary(), ...],
    params: Map.t()
  }

  defstruct to: nil, params: %{}

  @doc """
  Parse a URI with the `:scheme` of "tel"

  ## Example

      iex> mailto = URI.parse("mailto:user@%E7%B4%8D%E8%B1%86.example.org?subject=Test&body=NATTO")
      iex> URL.Mailto.parse(mailto)
      %URL.Mailto{
        params: %{"body" => "NATTO", "subject" => "Test"},
        to: ["user@納豆.example.org"]
      }

  """
  @spec parse(URI.t()) :: __MODULE__.t() | {:error, {module(), binary()}}
  def parse(%URI{scheme: "mailto", path: path, query: query}) do
    with {:ok, mailto} <- unwrap(parse_mailto(path)),
         {:ok, [params]} <- unwrap(parse_query(query)) do
      mailto
      |> structify(__MODULE__)
      |> Map.put(:params, params)
    end
  end

  defparsecp :parse_mailto,
    optional(to())

  defp parse_query(nil) do
    {:ok, [%{}], "", %{}, {0, 0}, 0}
  end

  defparsecp :parse_query,
    optional(hfields())

end