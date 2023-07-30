defmodule URL.ParseHelpers.Unwrap do
  @moduledoc false

  @doc false
  def unwrap({:ok, acc, "", _, _, _}) when is_list(acc) do
    {:ok, acc}
  end

  @doc false
  def unwrap({:error, reason, rest, _, {line, _}, _offset}) do
    {:error,
     {URL.Parser.ParseError,
      "#{reason}. Detected on line #{inspect(line)} at #{inspect(rest, printable_limit: 20)}"}}
  end

  @doc false
  def unwrap({:ok, acc, rest, _, _, _}) when is_list(acc) do
    {:error, {URL.Parser.ParseError, "Error detected at #{inspect(rest)}"}}
  end
end
