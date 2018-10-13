defmodule URL.Tel do
  import NimbleParsec
  import URL.ParseHelpers.{Core, Params, Unwrap}

  defstruct tel: nil, params: %{}

  @type t() :: %__MODULE__{
    tel: String.t(),
    params: Map.t()
  }

  @default_territory "US"

  def parse(%URI{scheme: "tel", path: path} = _uri) do
    with {:ok, tel} <- unwrap(parse_tel(path)) do
      tel = struct(__MODULE__, tel)
      Map.put(tel, :tel, format(tel))
    end
  end

  if Code.ensure_loaded?(ExPhoneNumber) do
    defp parse_phone_number(number, territory \\ get_territory()) do
      territory = if unknown_territory?(territory), do: @default_territory, else: territory
      ExPhoneNumber.parse(number, territory)
    end

    defp unknown_territory?(territory) do
      ExPhoneNumber.Metadata.get_country_code_for_region_code(territory) == 0
    end

    defp format(%__MODULE__{tel: tel}, format \\ :international) do
      case parse_phone_number(tel) do
        {:ok, tel} -> ExPhoneNumber.format(tel, format)
        other -> other
      end
    end
  else
    defp parse_phone_number(number, territory \\ nil) do
      number
    end

    defp format(%__MODULE__{tel: tel}, format \\ :international) do
      tel
    end
  end

  defp get_territory do
    cldr_territory() || gettext_territory() || @default_territory
  end

  if Code.ensure_loaded?(Cldr) do
    defp cldr_territory do
      Cldr.get_current_locale().territory
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

  defparsec :parse_tel,
    tel() |> concat(params())
end