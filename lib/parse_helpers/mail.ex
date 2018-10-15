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

  def join_address(_rest, [local_part, ?@, domain], context, _, _) do
    {[domain <> "@" <> local_part], context}
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
      token()
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

end