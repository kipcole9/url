# Getting Started
[![Hex pm](http://img.shields.io/hexpm/v/ex_url.svg?style=flat)](https://hex.pm/packages/ex_url)
[![License](https://img.shields.io/badge/license-Apache%202-blue.svg)](https://github.com/kipcole9/url/blob/master/LICENSE)

## Overview

`ex_url` is a library modelled on the Elixir URI module. It parses and formats URL's with the additional function that is parses the scheme-specific payload of known URI schemes.  At present it can parse:

* [geo](https://tools.ietf.org/rfc/rfc5870)
* [data](https://tools.ietf.org/html/rfc2397)
* [mailto](https://tools.ietf.org/html/rfc6068)
* [uuid](https://tools.ietf.org/html/draft-kindel-uuid-uri-00)
* and [tel](https://tools.ietf.org/html/rfc3966)

The basic API is `URL.parse/1`.  The function `URL.to_string/1` is delegated to the URI module.

Of course these are really URI's, not URL's but its a reasonable choice of name
given that [WHATWG](https://en.wikipedia.org/wiki/WHATWG) prefers URL over URI:

> Standardize on the term URL. URI and IRI [Internationalized Resource Identifier]
> are just confusing. In practice a single algorithm is used for both so keeping
> them distinct is not helping anyone. URL also easily wins the search result
> popularity contest

## Examples

### Parse a `geo` URL:
```elixir
iex> URL.parse("geo:48.198634,-16.371648,3.4;crs=wgs84;u=40.0")
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
```
### Parse a `tel` URL:
```elixir
iex> URL.parse("tel:+61-0407-555-987")
%URL{
  authority: nil,
  fragment: nil,
  host: nil,
  parsed_path: %URL.Tel{params: %{}, tel: "+61 407 555 987"},
  path: "+61-0407-555-987",
  port: nil,
  query: nil,
  scheme: "tel",
  userinfo: nil
}

# When the parameter "phone-context" is also a valid number then it is prepended before formatting
iex> tel = URL.parse "tel:0407-555-987;phone-context=+61"
%URL{
  authority: nil,
  fragment: nil,
  host: nil,
  parsed_path: %URL.Tel{
    params: %{"phone-context" => "+61"},
    tel: "+61 407 555 987"
  },
  path: "0407-555-987;phone-context=+61",
  port: nil,
  query: nil,
  scheme: "tel",
  userinfo: nil
}
```
### Parse a `data` URL:
This first example shows the treatment of data that is `base64` encoded.  It is decoded by `URL.Data.parse/1`.
```elixir
iex> URL.parse("data:;base64,SGVsbG8gV29ybGQh")
%URL{
  authority: nil,
  fragment: nil,
  host: nil,
  parsed_path: %URL.Data{
    data: "Hello World!",
    mediatype: "text/plain",
    params: %{"encoding" => "base64"}
  },
  path: ";base64,SGVsbG8gV29ybGQh",
  port: nil,
  query: nil,
  scheme: "data",
  userinfo: nil
}
```
This second example shows the treatment of data that is not marked as `base64` encoded.  In this case it is considered to be `percent-encoded`.  It is also decoded during parsing.
```elixir
iex> URL.parse("data:,Hello%20World%21")
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
```
### Parse a `mailto` URL
A `mailto` URL will be parsed and percent encoding will be decoded.  Note that [RFC2047 encoded-words](https://tools.ietf.org/html/rfc2047) is not currently supported.
```elixir
iex> URL.parse "mailto:infobot@example.com?subject=current-issue"
%URL{
  authority: nil,
  fragment: nil,
  host: nil,
  parsed_path: %URL.Mailto{
    params: %{"subject" => "current-issue"},
    to: ["infobot@example.com"]
  },
  path: "infobot@example.com",
  port: nil,
  query: "subject=current-issue",
  scheme: "mailto",
  userinfo: nil
}
```
### Parse a `uuid` URL
```elixir
iex> URL.parse "uuid:f81d4fae-7dec-11d0-a765-00a0c91e6bf6;a=b"
%URL{
  authority: nil,
  fragment: nil,
  host: nil,
  parsed_path: %URL.UUID{
    params: %{"a" => "b"},
    uuid: "f81d4fae-7dec-11d0-a765-00a0c91e6bf6"
  },
  path: "f81d4fae-7dec-11d0-a765-00a0c91e6bf6;a=b",
  port: nil,
  query: nil,
  scheme: "uuid",
  userinfo: nil
}
```
## Configuration

Configure `ex_url` in `mix.exs`:
```elixir
  defp deps do
    [
      {:ex_url, "~> 0.3"},
      ...
    ]
  end
```

If configured in `mix.exs`, URL will use the following libraries:

* [ex_phone_number](https://hex.pm/packages/ex_phone_number) will be used to parse and format telephone numbers defined in the `tel` URI scheme

* [ex_cldr](https://hex.pm/packages/ex_cldr) and [gettext](https://hex.pm/packages/gettext) will be used to determine the current locale and therefore the current territory (country) for parsing and formatting telephone numbers that don't have a country code supplied.

Optional configuration in `mix.exs`:
```elixir
  defp deps do
    [
      # Required
      {:ex_url, "~> 1.3"},

      # Optional
      {:ex_phone_number, "~> 0.1"},
      {:ex_cldr, "~> 2.18"},
      {:gettext, "~> 0.13"}
      ...
    ]
  end
```

