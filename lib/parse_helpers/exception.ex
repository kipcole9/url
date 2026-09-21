defmodule URL.Parser.ParseError do
  @moduledoc """
  Exception describing a failure to parse the scheme-specific
  part of a URL.

  `URL.new/1` returns it, together with its message, in an
  `{:error, {URL.Parser.ParseError, message}}` tuple; only
  `URL.new!/1` actually raises it.

  """
  defexception [:message]

  @doc """
  Builds the exception from a message.

  ### Arguments

  * `message` is a string describing what could not be parsed and
    where.

  ### Returns

  * A `t:t/0` exception struct.

  ### Examples

      iex> URL.Parser.ParseError.exception("expected a comma")
      %URL.Parser.ParseError{message: "expected a comma"}

  """
  @impl true
  def exception(message) do
    %__MODULE__{message: message}
  end
end
