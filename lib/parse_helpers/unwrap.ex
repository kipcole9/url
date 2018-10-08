defmodule URL.ParseHelpers.Unwrap do
  def unwrap({:ok, acc, "", _, _, _}) when is_list(acc),
    do: {:ok, acc}

  def unwrap({:error, reason, rest, _, {line, _}, _offset}) do
    {:error, {URL.Parser.ParseError, "#{reason}. Detected on line #{inspect line} at #{inspect(rest, printable_limit: 20)}"}}
  end
end