unless Code.ensure_loaded?(URI.Error) do
  defmodule URI.Error do
    defexception [:action, :reason, :part]

    def message(%URI.Error{action: action, reason: reason, part: part}) do
      "cannot #{action} due to reason #{reason}: #{inspect(part)}"
    end
  end
end