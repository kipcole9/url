defmodule URL.Tel do
  @moduledoc """
  Parses the scheme-specific part of a `tel` URL as defined
  in [RFC 3966](https://tools.ietf.org/html/rfc3966).

  When the optional `ex_phone_number` dependency is available the
  number is formatted in international form, with a `phone-context`
  parameter that is itself a number prepended first. The territory
  used for numbers without a country code comes from the current
  `ex_cldr` locale, then the current `gettext` locale, then `"US"`.
  Numbers that `ex_phone_number` cannot parse are kept as written.
  The primary API is `parse/1`, which `URL.new/1` calls for any URL
  with the `tel` scheme.

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
  Parses the path of a `tel` URI into a `t:t/0` struct.

  ### Arguments

  * `uri` is a `t:URI.t/0` whose `:scheme` is `"tel"`.

  ### Returns

  * `{:ok, t:t/0}` with the formatted (or, if it cannot be
    parsed, unformatted) telephone number in `:tel` and any
    parameters in `:params`, or

  * `{:error, {URL.Parser.ParseError, reason}}` if the path is
    not a valid telephone subscriber string, including an empty path.

  ### Examples

      iex> tel = URI.parse "tel:+61-0407-555-987"
      iex> URL.Tel.parse(tel)
      {:ok, %URL.Tel{tel: "+61 407 555 987", params: %{}}}

      iex> tel = URI.parse "tel:0407-555-987;phone-context=+61"
      iex> URL.Tel.parse(tel)
      {:ok, %URL.Tel{tel: "+61 407 555 987", params: %{"phone-context" => "+61"}}}

      iex> {:error, {URL.Parser.ParseError, _reason}} = URL.Tel.parse(URI.parse("tel:abc"))

  """
  @spec parse(URI.t()) :: {:ok, __MODULE__.t()} | {:error, {module(), binary()}}
  def parse(%URI{scheme: "tel", path: nil} = uri) do
    parse(%{uri | path: ""})
  end

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

      # A syntactically valid `tel` URL need not be a number that
      # ExPhoneNumber recognises (a local number with a domain
      # `phone-context`, for example), so keep the unformatted number
      # rather than storing an error tuple in the `tel` field.
      case parse_phone_number(phone_context <> tel) do
        {:ok, parsed} -> ExPhoneNumber.format(parsed, format)
        {:error, _reason} -> tel
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
    defp format(%__MODULE__{tel: tel}, _format \\ :international) do
      tel
    end
  end

  @doc false
  def get_territory do
    cldr_territory() || gettext_territory() || @default_territory
  end

  if Code.ensure_loaded?(Cldr) do
    # `Cldr.get_locale/0` raises when `ex_cldr` is a dependency but no
    # default backend is configured; that is a consumer configuration
    # choice, not invalid input, so fall through to the other sources.
    defp cldr_territory do
      Cldr.get_locale().territory
    rescue
      Cldr.NoDefaultBackendError -> nil
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
