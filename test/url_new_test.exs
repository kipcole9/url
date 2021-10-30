defmodule UrlTest do
  use ExUnit.Case
  doctest URL
  doctest URL.Data
  doctest URL.Tel
  doctest URL.Geo
  doctest URL.UUID
  doctest URL.Mailto

  test "parsing a tel url" do
    assert URL.new("tel:+610407555987") ==
      {:ok,
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
      }
  end

  test "parsing a geo url" do
    assert URL.new("GEO:48.198634,-16.371648,3.4;crs=wgs84;u=40.0") ==
      {:ok,
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
      }
  end

  test "parsing a data url that is base64 encoded" do
    assert URL.new("data:text/plain;base64,SGVsbG8gV29ybGQh") ==
      {:ok,
        %URL{
          authority: nil,
          fragment: nil,
          host: nil,
          parsed_path: %URL.Data{
            data: "Hello World!",
            mediatype: "text/plain",
            params: %{"encoding" => "base64"}
          },
          path: "text/plain;base64,SGVsbG8gV29ybGQh",
          port: nil,
          query: nil,
          scheme: "data",
          userinfo: nil
        }
      }
  end

  test "parsing a data url that is not base64 encoded" do
    assert URL.new("data:,Hello%20World%21") ==
      {:ok,
        %URL{
          authority: nil,
          fragment: nil,
          host: nil,
          parsed_path: %URL.Data{
            data: "Hello World!",
            mediatype: "text/plain",
            params: %{}
          },
          path: ",Hello%20World%21",
          port: nil,
          query: nil,
          scheme: "data",
          userinfo: nil
        }
      }
  end

  test "parsing an http url" do
    assert URL.new("http://thing.com/my_path") ==
      {:ok,
        %URL{
          authority: nil,
          fragment: nil,
          host: "thing.com",
          parsed_path: nil,
          path: "/my_path",
          port: 80,
          query: nil,
          scheme: "http",
          userinfo: nil
        }
      }
  end

  test "parsing a url with spaces" do
    assert {:error, _} = URL.new("http://  thing.com/my_path ")
  end

end
