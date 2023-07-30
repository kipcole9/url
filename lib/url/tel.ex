defmodule URL.Tel do
  @moduledoc """
  Parses a `tel` URL
  """
  import NimbleParsec
  import URL.ParseHelpers.{Core, Params, Unwrap}
  alias URL.ParseHelpers.Params

  defstruct tel: nil, params: %{}

  @type t() :: %__MODULE__{
          tel: String.t(),
          params: map()
        }

  @default_territory "US"

  @doc """
  Parse a URI with the `:scheme` of "tel"

  ## Examples

      iex> tel = URI.parse "tel:+61-0407-555-987"
      iex> URL.Tel.parse(tel)
      {:ok, %URL.Tel{tel: "+61 407 555 987", params: %{}}}

      iex> tel = URI.parse "tel:0407-555-987;phone-context=+61"
      iex> URL.Tel.parse(tel)
      {:ok, %URL.Tel{tel: "+61 407 555 987", params: %{"phone-context" => "+61"}}}

  """
  @spec parse(URI.t()) :: {:ok, __MODULE__.t()} | {:error, {module(), binary()}}
  def parse(%URI{scheme: "tel", path: path}) do
    with {:ok, tel} <- unwrap(parse_tel(path)) do
      tel = struct(__MODULE__, tel)

      tel
      |> Map.put(:tel, format(tel))
      |> Params.wrap(:ok)
    end
  end

  if Code.ensure_loaded?(ExPhoneNumber) do
    defp parse_phone_number(number, territory \\ get_territory()) do
      territory = if unknown_territory?(territory), do: @default_territory, else: territory
      ExPhoneNumber.parse(number, to_string(territory))
    end

    defp unknown_territory?(territory) do
      ExPhoneNumber.Metadata.get_country_code_for_region_code(to_string(territory)) == 0
    end

    defp format(%__MODULE__{tel: tel} = url, format \\ :international) do
      phone_context = phone_context(url.params)

      case parse_phone_number(phone_context <> tel) do
        {:ok, tel} -> ExPhoneNumber.format(tel, format)
        other -> other
      end
    end

    defp phone_context(%{"phone-context" => phone_context}) do
      with {:ok, parsed_phone_context} <- unwrap(parse_tel(phone_context)) do
        Keyword.get(parsed_phone_context, :tel)
      else
        _ -> ""
      end
    end

    defp phone_context(_url) do
      ""
    end
  else
    defp parse_phone_number(number, territory \\ nil) do
      number
    end

    defp format(%__MODULE__{tel: tel}, format \\ :international) do
      tel
    end

    defp phone_context(_) do
      ""
    end
  end

  defp get_territory do
    cldr_territory() || gettext_territory() || @default_territory
  end

  if Code.ensure_loaded?(Cldr) do
    defp cldr_territory do
      Cldr.get_locale().territory
    end
  else
    defp cldr_territory do
      nil
    end
  end

  if Code.ensure_loaded?(Gettext) do
    defp gettext_territory do
      case String.split(Gettext.get_locale(), "_") do
        [_lang, territory] -> String.upcase(territory)
        [_lang] -> nil
      end
    end
  else
    defp gettext_territory do
      nil
    end
  end

  defparsecp(
    :parse_tel,
    tel() |> concat(params())
  )
end
