defmodule URL.ParseHelpers.Mailto do
  import NimbleParsec
  import URL.ParseHelpers.Core

  # mailtoURI = "mailto:" [ to ] [ hfields ]
  # to = addr-spec *("," addr-spec )
  # hfields = "?" hfield *( "&" hfield )
  # hfield = hfname "=" hfvalue
  # hfname = *qchar
  # hfvalue = *qchar
  # addr-spec = local-part "@" domain
  # locale-part = dot-atom-text / quoted-string
  # domain = dot-atom-text / "[" *dtext-no-obs "]"
  # dtext-no-obs = %d33-90 / ; Printable US-ASCII

  def to do
    optional(addr_spec())
    |> repeat(ignore(comma()) |> concat(addr_spec()))
    |> tag(:to)
  end

  def addr_spec do
    local_part()
    |> concat(at_symbol())
    |> concat(domain())
    |> traverse(:join_address)
  end

  def join_address(_rest, parts, context, _, _) do
    domain =
      parts
      |> Enum.map(fn
        x when is_integer(x) -> List.to_string([x])
        x -> x
      end)
      |> Enum.reverse
      |> Enum.join
    {[domain], context}
  end

  def local_part do
    choice([
      quoted_string(),
      token()
    ])
  end

  def domain do
    choice([
      quoted_string(),
      dot_atom_text()
    ])
  end

  def hfields do
    optional(hfield())
    |> repeat(ignore(ampersand()) |> concat(hfield()))
    |> reduce({Map, :new, []})
  end

  def hfield do
    hfname()
    |> ignore(equals())
    |> concat(hfvalue())
    |> reduce(:tupleize)
  end

  def hfname do
    param_string()
    |> traverse(:unpercent)
  end

  def hfvalue do
    param_string()
    |> traverse(:unpercent)
  end

  # From RFC5322
  # atext           =   ALPHA / DIGIT /    ; Printable US-ASCII
  #                     "!" / "#" /        ;  characters not including
  #                     "$" / "%" /        ;  specials.  Used for atoms.
  #                     "&" / "'" /
  #                     "*" / "+" /
  #                     "-" / "/" /
  #                     "=" / "?" /
  #                     "^" / "_" /
  #                     "`" / "{" /
  #                     "|" / "}" /
  #                     "~"
  #
  # atom            =   [CFWS] 1*atext [CFWS]
  #
  # dot-atom-text   =   1*atext *("." 1*atext)
  #
  # dot-atom        =   [CFWS] dot-atom-text [CFWS]

  def atext do
    ascii_string([?0..?9, ?a..?z, ?A..?Z, ?!, ?#, ?$,
            ?%, ?&, ?', ?*, ?+, ?-, ?/, ?=, ??,
            ?^, ?_, ?`, ?(, ?|, ?), ?~], min: 1)
  end

  def atom do
    # optional(cfws())
    # |> concat(atext())
    # |> optional(cfws())
    atext()
  end

  def dot_atom_text do
    atext()
    |> repeat(period() |> concat(atext()))
    |> traverse(:join_address)
    |> traverse(:unpercent)
  end
end