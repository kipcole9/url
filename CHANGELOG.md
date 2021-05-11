# Changelog for URL v1.3.1

This is the changelog for URL version 1.3.1 released on May 12th, 2021.  For older changelogs please consult the release tag on [GitHub](https://github.com/kipcole9/cldr/tags)

### Enhancements

* Updates `nimble_parsec` dependency to `~> 1.0`. Thanks to @ghry5

* Make `ex_doc` available only in `:dev` and `:release`

# Changelog for URL v1.3.0

This is the changelog for URL version 1.3.0 released on November 1st.  For older changelogs please consult the release tag on [GitHub](https://github.com/kipcole9/cldr/tags)

### Enhancements

* Support [CLDR 38](http://cldr.unicode.org/index/downloads/cldr-38)

### Bug Fixes

* Correct some types to use `map()`

* Fix error resulting from inconsistent use of territories as atoms and strings

# Changelog for URL v1.2.0

This is the changelog for URL version 1.2.0 released on January 23rd, 2020.  For older changelogs please consult the release tag on [GitHub](https://github.com/kipcole9/cldr/tags)

### Enhancements

* Executes `String.trim/1` on parsed elements of URI's so that "https://     google.fr" will return "google.fr" as the host, not "    google.fr".

# Changelog for URL v1.1.0

This is the changelog for URL version 1.1.0 released on April 7th, 2019.  For older changelogs please consult the release tag on [GitHub](https://github.com/kipcole9/cldr/tags)

### Enhancements

* Update to `NimbleParsec` version 0.5

# Changelog for URL v1.0.0

This is the changelog for URL version 1.0.0 released on November 25th, 2018.  For older changelogs please consult the release tag on [GitHub](https://github.com/kipcole9/cldr/tags)

### Enhancements

* Supports [ex_cldr version 2.0.0](https://hex.pm/packages/ex_cldr).  This is an optional dependency.

* Add `URL.parse_query_string/1`

# Changelog for URL v0.4.0

This is the changelog for URL version 0.4.0 released on October 18th, 2018.  For older changelogs please consult the release tag on [GitHub](https://github.com/kipcole9/cldr/tags)

### Enhancements

* Adds support for the `uuid` URL type.  See `URL.UUID`

# Changelog for URL v0.3.0

This is the changelog for URL version 0.3.0 released on October 16th, 2018.  For older changelogs please consult the release tag on [GitHub](https://github.com/kipcole9/cldr/tags)

### Enhancements

* Adds support for the `mailto` URL type.  See `URL.Mailto`

### Bug Fixes

* Now correctly uses the `phone-context` parameter when formatting a telelphone number in a `tel` URL.

# Changelog for URL v0.2.0

This is the changelog for URL version 0.2.0 released on October 13th, 2018.  For older changelogs please consult the release tag on [GitHub](https://github.com/kipcole9/cldr/tags)

### Enhancements

* Add specs to public functions

* Make several functions private including the `defparsec` definitions

# Changelog for URL v0.1.0

This is the changelog for URL version 0.1.0 released on October 13th, 2018.  For older changelogs please consult the release tag on [GitHub](https://github.com/kipcole9/cldr/tags)

### Enhancements

* Initial release of URL