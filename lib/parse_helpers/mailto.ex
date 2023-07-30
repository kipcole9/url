defmodule URL.ParseHelpers.Mailto do
  @moduledoc false

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

  @doc false
  def to do
    optional(addr_spec())
    |> repeat(ignore(comma()) |> concat(addr_spec()))
    |> tag(:to)
  end

  @doc false
  def addr_spec do
    local_part()
    |> concat(at_symbol())
    |> concat(domain())
    |> reduce({Enum, :join, []})
  end

  @doc false
  def join_address(_rest, parts, context, _, _) do
    domain =
      parts
      |> Enum.map(fn
        x when is_integer(x) -> List.to_string([x])
        x -> x
      end)
      |> Enum.reverse()
      |> Enum.join()

    {[domain], context}
  end

  @doc false
  def local_part do
    choice([
      quoted_string(),
      token()
    ])
  end

  @doc false
  def domain do
    choice([
      quoted_string(),
      dot_atom_text()
    ])
  end

  @doc false
  def hfields do
    optional(hfield())
    |> repeat(ignore(ampersand()) |> concat(hfield()))
    |> reduce({Map, :new, []})
  end

  @doc false
  def hfield do
    hfname()
    |> ignore(equals())
    |> concat(hfvalue())
    |> reduce(:tupleize)
  end

  @doc false
  def hfname do
    param_string()
    |> post_traverse(:unpercent)
  end

  @doc false
  def hfvalue do
    param_string()
    |> post_traverse(:unpercent)
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
  # dot-atom-text   =   1*atext *("." 1*atext)
  # dot-atom        =   [CFWS] dot-atom-text [CFWS]

  @doc false
  def atext do
    ascii_string(
      [
        ?0..?9,
        ?a..?z,
        ?A..?Z,
        ?!,
        ?#,
        ?$,
        ?%,
        ?&,
        ?',
        ?*,
        ?+,
        ?-,
        ?/,
        ?=,
        ??,
        ?^,
        ?_,
        ?`,
        ?(,
        ?|,
        ?),
        ?~
      ],
      min: 1
    )
  end

  @doc false
  def atom do
    # optional(cfws())
    # |> concat(atext())
    # |> optional(cfws())
    atext()
  end

  @doc false
  def dot_atom_text do
    atext()
    |> repeat(period() |> concat(atext()))
    |> reduce({Enum, :join, []})
    |> post_traverse(:unpercent)
  end
end
