defmodule URL.ParseHelpers.Core do
  @moduledoc false

  import NimbleParsec

  @cr 0x0d
  @lf 0x0a

  # Allow NL line ends for simpler compatibility
  def crlf do
    choice([
      ascii_char([@cr]) |> ascii_char([@lf]),
      ascii_char([@lf])
    ])
    |> label("a newline (either CRLF or LF)")
  end

  def colon do
    ascii_char([?:])
    |> label("a colon")
  end

  def plus do
    ascii_char([?+])
    |> label("a plus sign")
  end

  def semicolon do
    ascii_char([?;])
    |> label("a semicolon")
  end

  def period do
    ascii_char([?.])
    |> label("a dot character")
  end

  def comma do
    ascii_char([?,])
    |> label("a comma")
  end

  def at_symbol do
    ascii_char([?@])
    |> label("an at symbol")
  end

  def question_mark do
    ascii_char([??])
    |> label("a question mark")
  end

  def ampersand do
    ascii_char([?&])
    |> label("an ampersand")
  end

  def digit do
    ascii_char([?0..?9])
    |> label("a decimal digit")
  end

  def digits do
    ascii_string([?0..?9], min: 1)
    |> label("an string of digits")
  end

  def sign do
    ascii_char([?-, ?+])
    |> reduce({List, :to_string, []})
  end

  def hex_digit do
    ascii_char([?0..?9, ?a..?f, ?A..?F])
    |> label("a hexidecimal digit")
  end

  def equals do
    ascii_char([?=])
    |> label("an equals sign")
  end

  def dquote do
    ascii_char([?"])
    |> label("a double quote character")
  end

  def hex_string do
    ascii_string([?a..?f, ?A..?F, ?0..?9], min: 1)
    |> label("a hexidecimal digit")
  end

  def alphanum_and_dash do
    ascii_string([?a..?z, ?A..?Z, ?0..?9, ?-], min: 1)
    |> label("an alphanumeric character or a dash")
  end

  def alphabetic do
    ascii_string([?a..?z, ?A..?Z], min: 1)
    |> label("an alphabetic character")
  end

  def alphanumeric do
    ascii_string([?a..?z, ?A..?Z, ?0..?9], min: 1)
    |> label("an alphanumeric character")
  end

  def base64 do
    ascii_string([?a..?z, ?A..?Z, ?0..?9, ?/, ?+, ?=], min: 1)
    |> label("a base64 encoded string")
  end

  def url_string do
    choice([
      reserved(),
      unreserved(),
      escaped()
    ])
    |> repeat
    |> reduce({Enum, :join, []})
  end

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
  def reserved do
    ascii_string(@reserved, min: 1)
  end

  # unreserved  = alphanum | mark
  # mark        = "-" | "_" | "." | "!" | "~" | "*" | "'" | "(" | ")"
  @unreserved [?a..?z, ?A..?Z, ?0..?9, ?-, ?_, ?., ?!, ?~, ?*, ?', ?(, ?)]
  def unreserved do
    ascii_string(@unreserved, min: 1)
  end

  # escaped     = "%" hex hex
  # hex         = digit | "A" | "B" | "C" | "D" | "E" | "F" |
  #                       "a" | "b" | "c" | "d" | "e" | "f"
  def escaped do
    ascii_char([?%]) |> concat(hex_digit()) |> concat(hex_digit())
    |> reduce({List, :to_string, []})
  end

  def data do
    url_string()
    |> unwrap_and_tag(:data)
  end

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

  def quoted_string do
    ignore(ascii_char([?"]))
    |> concat(qsafe_string())
    |> ignore(ascii_char([?"]))
  end

  def base64_param do
    string("base64")
    |> traverse(:base64_encoding)
  end

  def base64_encoding(_rest, _args, context, _, _) do
    {["base64", "encoding"], context}
  end

  def number do
    choice([float(), integer()])
  end

  def integer do
    optional(sign())
    |> concat(digits())
    |> reduce({Enum, :join, []})
    |> reduce(:to_integer)
  end

  def float do
    optional(sign())
    |> concat(digits())
    |> concat(period() |> reduce({List, :to_string, []}))
    |> concat(digits())
    |> reduce({Enum, :join, []})
    |> reduce(:to_float)
  end

  def to_integer([number]) do
    String.to_integer(number)
  end

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
  def attribute do
    token()
  end

  def value do
    choice([
      quoted_string() |> traverse(:unescape),
      token() |> traverse(:unpercent)
    ])
  end

  #   mediatype  := [ type "/" subtype ] *( ";" parameter )
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
  def token do
    ascii_string(@token, min: 1)
    |> traverse(:unpercent)
  end

  @tel_digits [?-, ?., ?(, ?), ?0..?9]
  def tel do
    optional(ascii_string([?+], min: 1))
    |> ascii_string(@tel_digits, min: 1)
    |> reduce({Enum, :join, []})
    |> unwrap_and_tag(:tel)
    |> label("A telephone number")
  end

  def unpercent(_rest, [arg], context, _, _) do
    {[URI.decode(arg)], context}
  end

  #    SAFE-CHAR = WSP / "!" / %x23-39 / %x3C-7E / NON-ASCII
  #      ; Any character except CTLs, DQUOTE, ";", ":"
  #      ; ALSO ALLOW &NBSP 0xa0 since Apple Contacts generates it
  def safe_string do
    ascii_string([0x20, 0x09, ?!, 0x23..0x39, 0x3c..0x7e], min: 1)
  end

  #    QSAFE-CHAR = WSP / "!" / %x23-7E / NON-ASCII
  #      ; Any character except CTLs, DQUOTE
  def qsafe_string do
    ascii_string([0x20, 0x09, ?!, 0x23..0x7e], min: 1)
  end

  def unescape(_rest, args, context, _, _) do
    {unescape(args), context}
  end

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

  def structify(map, module) do
    struct(module, map)
  end
end