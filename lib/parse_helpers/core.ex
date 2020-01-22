defmodule URL.ParseHelpers.Core do
  @moduledoc false

  import NimbleParsec

  @cr 0x0d
  @lf 0x0a

  # Allow NL line ends for simpler compatibility
  def crlf do
    choice([
      ascii_string([@cr], 1) |> ascii_string([@lf], 1),
      ascii_string([@lf], 1)
    ])
    |> label("a newline (either CRLF or LF)")
  end

  @doc false
  def colon do
    ascii_string([?:], 1)
    |> label("a colon")
  end

  @doc false
  def plus do
    ascii_string([?+], 1)
    |> label("a plus sign")
  end

  @doc false
  def semicolon do
    ascii_string([?;], 1)
    |> label("a semicolon")
  end

  @doc false
  def period do
    ascii_string([?.], 1)
    |> label("a dot character")
  end

  @doc false
  def comma do
    ascii_string([?,], 1)
    |> label("a comma")
  end

  @doc false
  def at_symbol do
    ascii_string([?@], 1)
    |> label("an at symbol")
  end

  @doc false
  def question_mark do
    ascii_string([??], 1)
    |> label("a question mark")
  end

  @doc false
  def ampersand do
    ascii_string([?&], 1)
    |> label("an ampersand")
  end

  @doc false
  def digit do
    ascii_string([?0..?9], 1)
    |> label("a decimal digit")
  end

  @doc false
  def digits do
    ascii_string([?0..?9], min: 1)
    |> label("an string of digits")
  end

  @doc false
  def sign do
    ascii_string([?-, ?+], 1)
  end

  @doc false
  def hex_digit do
    ascii_string([?0..?9, ?a..?f, ?A..?F], 1)
    |> label("a hexidecimal digit")
  end

  @doc false
  def equals do
    ascii_string([?=], 1)
    |> label("an equals sign")
  end

  @doc false
  def dquote do
    ascii_string([?"], 1)
    |> label("a double quote character")
  end

  @doc false
  def hex_string do
    ascii_string([?a..?f, ?A..?F, ?0..?9], min: 1)
    |> label("a hexidecimal digit")
  end

  @doc false
  def uuid do
    ascii_string([?a..?f, ?A..?F, ?0..?9], 8)
    |> concat(ascii_string([?-], 1))
    |> ascii_string([?a..?f, ?A..?F, ?0..?9], 4)
    |> concat(ascii_string([?-], 1))
    |> ascii_string([?a..?f, ?A..?F, ?0..?9], 4)
    |> concat(ascii_string([?-], 1))
    |> ascii_string([?a..?f, ?A..?F, ?0..?9], 4)
    |> concat(ascii_string([?-], 1))
    |> ascii_string([?a..?f, ?A..?F, ?0..?9], 12)
    |> reduce({Enum, :join, []})
    |> unwrap_and_tag(:uuid)
    |> label("a valid UUID")
  end

  @doc false
  def alphanum_and_dash do
    ascii_string([?a..?z, ?A..?Z, ?0..?9, ?-], min: 1)
    |> label("an alphanumeric character or a dash")
  end

  @doc false
  def alphabetic do
    ascii_string([?a..?z, ?A..?Z], min: 1)
    |> label("an alphabetic character")
  end

  @doc false
  def alphanumeric do
    ascii_string([?a..?z, ?A..?Z, ?0..?9], min: 1)
    |> label("an alphanumeric character")
  end

  @doc false
  def base64 do
    ascii_string([?a..?z, ?A..?Z, ?0..?9, ?/, ?+, ?=], min: 1)
    |> label("a base64 encoded string")
  end

  @doc false
  def url_string do
    choice([
      reserved(),
      unreserved(),
      escaped()
    ])
    |> repeat
    |> reduce({Enum, :join, []})
  end

  @doc false
  def param_string do
    choice([
      unreserved(),
      escaped()
    ])
    |> repeat
    |> reduce({Enum, :join, []})
  end

  # reserved    = ";" | "/" | "?" | ":" | "@" | "&" | "=" | "+" |
  #               "$" | ","
  @reserved [?;, ?/, ??, ?:, ?@, ?&, ?=, ?+, ?$, ?,]
  @doc false
  def reserved do
    ascii_string(@reserved, min: 1)
  end

  # unreserved  = alphanum | mark
  # mark        = "-" | "_" | "." | "!" | "~" | "*" | "'" | "(" | ")"
  @unreserved [?a..?z, ?A..?Z, ?0..?9, ?-, ?_, ?., ?!, ?~, ?*, ?', ?(, ?)]
  @doc false
  def unreserved do
    ascii_string(@unreserved, min: 1)
  end

  # escaped     = "%" hex hex
  # hex         = digit | "A" | "B" | "C" | "D" | "E" | "F" |
  #                       "a" | "b" | "c" | "d" | "e" | "f"
  @doc false
  def escaped do
    ascii_string([?%], 1) |> concat(hex_digit()) |> concat(hex_digit())
    |> reduce({Enum, :join, []})
  end

  @doc false
  def data do
    url_string()
    |> unwrap_and_tag(:data)
  end

  @doc false
  def anycase_string(string) do
    string
    |> String.upcase
    |> String.to_charlist
    |> Enum.reverse
    |> char_piper
    |> reduce({List, :to_string, []})
  end

  defp char_piper([c]) when c in ?A..?Z do
    c
    |> both_cases
    |> ascii_char
  end

  defp char_piper([c | rest]) when c in ?A..?Z do
    rest
    |> char_piper
    |> ascii_char(both_cases(c))
  end

  defp char_piper([c]) do
    ascii_char([c])
  end

  defp char_piper([c | rest]) do
    rest
    |> char_piper
    |> ascii_char([c])
  end

  defp both_cases(c) do
    [c, c + 32]
  end

  @doc false
  def quoted_string do
    ignore(ascii_string([?"], 1))
    |> concat(qsafe_string())
    |> ignore(ascii_string([?"], 1))
  end

  @doc false
  def base64_param do
    string("base64")
    |> post_traverse(:base64_encoding)
  end

  @doc false
  def base64_encoding(_rest, _args, context, _, _) do
    {["base64", "encoding"], context}
  end

  @doc false
  def number do
    choice([float(), integer()])
  end

  @doc false
  def integer do
    optional(sign())
    |> concat(digits())
    |> reduce({Enum, :join, []})
    |> reduce(:to_integer)
  end

  @doc false
  def float do
    optional(sign())
    |> concat(digits())
    |> concat(period() |> reduce({List, :to_string, []}))
    |> concat(digits())
    |> reduce({Enum, :join, []})
    |> reduce(:to_float)
  end

  @doc false
  def to_integer([number]) do
    String.to_integer(number)
  end

  @doc false
  def to_float([number]) do
    String.to_float(number)
  end

  # parameter := attribute "=" value
  #
  # attribute := token
  #              ; Matching of attributes
  #              ; is ALWAYS case-insensitive.
  #
  # value := token / quoted-string
  #
  # token := 1*<any (US-ASCII) CHAR except SPACE, CTLs,
  #             or tspecials>
  #
  # tspecials :=  "(" / ")" / "<" / ">" / "@" /
  #               "," / ";" / ":" / "\" / <">
  #               "/" / "[" / "]" / "?" / "="
  #               ; Must be in quoted-string,
  #               ; to use within parameter values
  @doc false
  def attribute do
    token()
  end

  @doc false
  def value do
    choice([
      quoted_string() |> post_traverse(:unescape),
      token() |> post_traverse(:unpercent)
    ])
  end

  #   mediatype  := [ type "/" subtype ] *( ";" parameter )
  @doc false
  def mediatype do
    optional(token()
    |> string("/")
    |> concat(token())
    |> reduce({Enum, :join, []})
    |> unwrap_and_tag(:mediatype))
  end

  @non_ctrls Enum.to_list(32..126)
  @tspecials [?(, ?), ?<, ?>, ?@, ?,, ?;, ?:, ?\\, ?\", ?/, ?[, ?], ??, ?=, 0x20]
  @token MapSet.difference(MapSet.new(@non_ctrls), MapSet.new(@tspecials)) |> MapSet.to_list
  @doc false
  def token do
    ascii_string(@token, min: 1)
    |> traverse(:unpercent)
  end

  @tel_digits [?-, ?., ?(, ?), ?0..?9]
  @doc false
  def tel do
    optional(ascii_string([?+], min: 1))
    |> ascii_string(@tel_digits, min: 1)
    |> reduce({Enum, :join, []})
    |> unwrap_and_tag(:tel)
    |> label("A telephone number")
  end

  @doc false
  def unpercent(_rest, [arg], context, _, _) do
    {[URI.decode(arg)], context}
  end

  #    SAFE-CHAR = WSP / "!" / %x23-39 / %x3C-7E / NON-ASCII
  #      ; Any character except CTLs, DQUOTE, ";", ":"
  #      ; ALSO ALLOW &NBSP 0xa0 since Apple Contacts generates it
  @doc false
  def safe_string do
    ascii_string([0x20, 0x09, ?!, 0x23..0x39, 0x3c..0x7e], min: 1)
  end

  #    QSAFE-CHAR = WSP / "!" / %x23-7E / NON-ASCII
  #      ; Any character except CTLs, DQUOTE
  @doc false
  def qsafe_string do
    ascii_string([0x20, 0x09, ?!, 0x23..0x7e], min: 1)
  end

  @doc false
  def unescape(_rest, args, context, _, _) do
    {unescape(args), context}
  end

  @doc false
  def unescape(values) when is_list(values) do
    Enum.map(values, &unescape/1)
  end

  def unescape(""), do: ""
  def unescape(<< "\\n", rest :: binary>>), do: "\n" <> unescape(rest)
  def unescape(<< "\\r", rest :: binary>>), do: "\r" <> unescape(rest)
  def unescape(<< "\\t", rest :: binary>>), do: "\t" <> unescape(rest)
  def unescape(<< "\\,", rest :: binary>>), do: "," <> unescape(rest)
  def unescape(<< "\\;", rest :: binary>>), do: ";" <> unescape(rest)
  def unescape(<< "\\\\", rest :: binary>>), do: "\\" <> unescape(rest)
  def unescape(<< c :: binary-size(1), rest :: binary>>), do: c <> unescape(rest)
  def unescape(values), do: values

  @doc false
  def structify(map, module) do
    struct(module, map)
  end
end