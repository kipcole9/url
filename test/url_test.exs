defmodule UrlTest do
  use ExUnit.Case
  doctest URL

  test "parsing a tel url" do
    assert URL.parse("tel:+610407555987") ==
      %URL{
        authority: nil,
        fragment: nil,
        host: nil,
        parsed_path: %URL.Tel{params: %{}, tel: "+61 407 555 987"},
        path: "+610407555987",
        port: nil,
        query: nil,
        scheme: "tel",
        userinfo: nil
      }
  end

  test "parsing a geo url" do
    assert URL.parse("GEO:48.198634,-16.371648,3.4;crs=wgs84;u=40.0") ==
      %URL{
        authority: nil,
        fragment: nil,
        host: nil,
        parsed_path: %URL.Geo{
          alt: 3.4,
          lat: 48.198634,
          lng: -16.371648,
          params: %{"crs" => "wgs84", "u" => 40.0}
        },
        path: "48.198634,-16.371648,3.4;crs=wgs84;u=40.0",
        port: nil,
        query: nil,
        scheme: "geo",
        userinfo: nil
      }
  end

  test "parsing a data url" do
    base64 = "MIICajCCAdOgAwIBA" <>
          "gICBEUwDQYJKoZIhvcNAQEEBQAwdzELMAkGA1UEBhMCVVMxLDAqBgNVBAoTI05l"
    url = "data:application/pgp-keys;base64," <> base64
    p = URL.parse(url).parsed_path

    assert p.mediatype == "application/pgp-keys"
    assert {:ok, p.data} == Base.decode64(base64)
  end
  
  test "parsing an http url" do
    assert URL.parse("http://thing.com") ==                          
      %URL{
        authority: "thing.com",
        fragment: nil,
        host: "thing.com",
        parsed_path: nil,
        path: nil,
        port: 80,
        query: nil,
        scheme: "http",
        userinfo: nil
      }
  end
end
