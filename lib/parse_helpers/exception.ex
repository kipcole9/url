defmodule URL.Parser.ParseError do
  @moduledoc """
  Exception raised when a URL cannot be parsed
  """
  defexception [:message]

  def exception(message) do
    %__MODULE__{message: message}
  end
end
