# Getting Started
[![Hex pm](http://img.shields.io/hexpm/v/url.svg?style=flat)](https://hex.pm/packages/url)
[![License](https://img.shields.io/badge/license-Apache%202-blue.svg)](https://github.com/kipcole9/url/blob/master/LICENSE)

## Overview

`ex_url` is a library modelled on the Elixir URI module. It parses and formats URL's with the additional function that is parses the scheme-specific payload of known URI schemes.  At present it can parse:

* [geo](https://tools.ietf.org/rfc/rfc5870)
* [data](https://tools.ietf.org/html/rfc2397)
* and [tel](https://tools.ietf.org/html/rfc3966)

The basic API is `URL.parse/1`.  The function `URL.format/1` is delegated to the URI module.

## Examples

Parse a geo URL:
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
Parse a `tel` URL:
```elixir
iex> URL.parse "tel:+61-0407-555-987"
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
```

## Configuration

Configure `ex_url` in `mix.exs`:
```elixir
  defp deps do
    [
      {ex_url, "~> 0.1"},
      ...
    ]
  end
```

If configured in `mix.exs`, URL will use the following libraries:

* [ex_phone_number](https://hex.pm/packages/ex_phone_number) will be used to parse and format telephone numbers defined in the `tel` URI scheme

* [ex_cldr](https://hex.pm/packages/ex_cldr) and [gettext](https://hex.pm/packages/gettext) will be used to determine the current locale and therefore the current territory (country) for parsing and formatting telephone numbers that don't have a country code supplied.

Option configuration in `mix.exs`:
```elixir
  defp deps do
    [
      {ex_url, "~> 0.1"},
      {:ex_phone_number, "~> 0.1"},
      {:ex_cldr, "~> 1.7"},
      {:gettext, "~> 0.13"}
      ...
    ]
  end
```

