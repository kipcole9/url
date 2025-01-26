# Changelog

**URL version 2.0.0 is supported on Elixir 1.13 and later only.**

## URL v2.0.1

This is the changelog for URL version 2.0.1 released on January 26th, 2025.  For older changelogs please consult the release tag on [GitHub](https://github.com/kipcole9/url/tags)

### Bug Fixes

* Fix compilation warning with [nimble_parsec](https://github.com/dashbitco/nimble_parsec) version 1.4.1 and later. Thanks to @serpent213 for the PR. Closes #6.

## URL v2.0.0

This is the changelog for URL version 2.0.0 released on August 4th, 2023.  For older changelogs please consult the release tag on [GitHub](https://github.com/kipcole9/url/tags)

### Breaking Change

* `URL.new/1` now always returns a tuple of the form `{:ok, t:URL.t/0}` or `{:error, {module(), String.t()}}`. The previous versions embedded error tuples in the return structure making is too complex to determine if there was a parsing error on the path data.  This approach also makes it more straight forward to implement tests that return errors.

### Deprecations

* Hard deprecates `URL.parse/1`

### Bug Fixes

* Remove warnings for unused variables when neither `ex_phone_number` or `ex_cldr` are configured (these are both optional dependencies). Thanks to @shahryarjb for the report. Closes #5.

## URL v1.5.0

This is the changelog for URL version 1.5.0 released on July 28th, 2023.  For older changelogs please consult the release tag on [GitHub](https://github.com/kipcole9/url/tags)

`URL` version 1.5.0 is supported on Elixir 1.11 and later only.

### Bug Fixes

* Change to `import Config`, not `import Mix.Config`

* Make `Jason` dependency optional.

## URL v1.4.0

This is the changelog for URL version 1.4.0 released on October 30th, 2021.  For older changelogs please consult the release tag on [GitHub](https://github.com/kipcole9/url/tags)

### Deprecations

* Soft deprecated `URL.parse/1` in line with Elixir 1.13's deprecation of `URI.parse/1`

### Enhancements

* Add `URL.new/1` and `URL.new!/1` in line with the preferred API in Elixir 1.13

## URL v1.3.1

This is the changelog for URL version 1.3.1 released on May 12th, 2021.  For older changelogs please consult the release tag on [GitHub](https://github.com/kipcole9/url/tags)

### Enhancements

* Updates `nimble_parsec` dependency to `~> 1.0`. Thanks to @ghry5

* Make `ex_doc` available only in `:dev` and `:release`

## URL v1.3.0

This is the changelog for URL version 1.3.0 released on November 1st.  For older changelogs please consult the release tag on [GitHub](https://github.com/kipcole9/url/tags)

### Enhancements

* Support [CLDR 38](http://cldr.unicode.org/index/downloads/cldr-38)

### Bug Fixes

* Correct some types to use `map()`

* Fix error resulting from inconsistent use of territories as atoms and strings

## URL v1.2.0

This is the changelog for URL version 1.2.0 released on January 23rd, 2020.  For older changelogs please consult the release tag on [GitHub](https://github.com/kipcole9/url/tags)

### Enhancements

* Executes `String.trim/1` on parsed elements of URI's so that "https://     google.fr" will return "google.fr" as the host, not "    google.fr".

## URL v1.1.0

This is the changelog for URL version 1.1.0 released on April 7th, 2019.  For older changelogs please consult the release tag on [GitHub](https://github.com/kipcole9/url/tags)

### Enhancements

* Update to `NimbleParsec` version 0.5

## URL v1.0.0

This is the changelog for URL version 1.0.0 released on November 25th, 2018.  For older changelogs please consult the release tag on [GitHub](https://github.com/kipcole9/url/tags)

### Enhancements

* Supports [ex_cldr version 2.0.0](https://hex.pm/packages/ex_cldr).  This is an optional dependency.

* Add `URL.parse_query_string/1`

## URL v0.4.0

This is the changelog for URL version 0.4.0 released on October 18th, 2018.  For older changelogs please consult the release tag on [GitHub](https://github.com/kipcole9/url/tags)

### Enhancements

* Adds support for the `uuid` URL type.  See `URL.UUID`

## URL v0.3.0

This is the changelog for URL version 0.3.0 released on October 16th, 2018.  For older changelogs please consult the release tag on [GitHub](https://github.com/kipcole9/url/tags)

### Enhancements

* Adds support for the `mailto` URL type.  See `URL.Mailto`

### Bug Fixes

* Now correctly uses the `phone-context` parameter when formatting a telelphone number in a `tel` URL.

## URL v0.2.0

This is the changelog for URL version 0.2.0 released on October 13th, 2018.  For older changelogs please consult the release tag on [GitHub](https://github.com/kipcole9/url/tags)

### Enhancements

* Add specs to public functions

* Make several functions private including the `defparsec` definitions

## URL v0.1.0

This is the changelog for URL version 0.1.0 released on October 13th, 2018.  For older changelogs please consult the release tag on [GitHub](https://github.com/kipcole9/url/tags)

### Enhancements

* Initial release of URL