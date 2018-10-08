defmodule URL.ParseHelpers.Params do
  import NimbleParsec
  import URL.ParseHelpers.Core

  def params do
    repeat(ignore(semicolon()) |> concat(param()))
    |> reduce({Map, :new, []})
    |> unwrap_and_tag(:params)
  end

  #   parameter  := attribute "=" value
  def param do
    choice([
      attribute() |> ignore(equals()) |> concat(value()),
      base64_param()
    ])
    |> reduce(:tupleize)
  end

  def tupleize([key, value]) do
    {String.downcase(key), value}
  end

  def normalize_params(url, param_map) do
    params =
      url
      |> Keyword.get(:params)
      |> Enum.map(fn {key, value} ->
        case Map.get(param_map, key) do
          nil -> {key, value}
          fun when is_function(fun) -> {key, fun.(value)}
        end
      end)

    Keyword.put(url, :params, Map.new(params))
  end

  def integerize(string) do
    case Integer.parse(string) do
      :error -> string
      {int, ""} -> int
      _other -> string
    end
  end

  def floatize(string) do
    case Float.parse(string) do
      :error -> string
      {float, ""} -> float
      _other -> string
    end
  end

  def numberize(string) do
    case Integer.parse(string) do
      {int, ""} -> int
      _other -> floatize(string)
    end
  end

end