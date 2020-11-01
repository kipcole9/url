defmodule MyApp.Cldr do
  use Cldr,
  locales: ["en", "fr"],
  default_locale: "en",
  providers: []
end