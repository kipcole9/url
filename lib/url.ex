defmodule URL do
  defstruct uri: nil, path: nil

  @supported_schemes %{
    "tel" => URL.Tel,
    "ftp" => URL.Ftp,
    "data" => URL.Data,
    "http" => URL.Http,
    "geo" =>  URL.Geo
  }

  def parse(url) when is_binary(url) do
    url
    |> URI.parse
    |> dispatch_to_scheme_parser
  end

  for {scheme, module} <- @supported_schemes do
    def dispatch_to_scheme_parser(%URI{scheme: unquote(scheme)} = uri) do
      unquote(module).parse(uri)
    end
  end

  def dispatch_to_scheme_parser(%URI{} = uri) do
    nil
  end

end
