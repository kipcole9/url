# TODO

Work for `ex_url`. Findings from the 2026-09-21 release-readiness review; there are no design documents yet, so no `plans/` directory.

## Open

* [ ] **Return errors instead of raising on empty scheme paths** — `URL.new/1` raises `FunctionClauseError` for `"mailto:"`, `"mailto:?subject=x"`, `"geo:"`, `"tel:"`, `"uuid:"`, `"urn:"` and `"urn:uuid:"` because `URI.new/1` yields `path: nil` and each scheme parser is called with `nil`. Each `parse/1` needs a `path: nil` clause (`mailto:` is valid and should parse to an empty `to`; the rest should return `{:error, {URL.Parser.ParseError, _}}`).

* [ ] **`URL.parse_query_string/1` raises on a URL without a query** — the `%{query: query}` clause forwards `nil` and no clause matches it. Return `%{}` for `nil`.

* [ ] **`tel` parsing raises when `ex_cldr` is loaded but has no default backend** — `URL.Tel.get_territory/0` calls `Cldr.get_locale/0`, which raises `Cldr.NoDefaultBackendError`. Rescue or check `Cldr.default_backend/0` first and fall through to the gettext and `"US"` fallbacks.

* [ ] **`URL.Tel` puts an error tuple in the `tel` field** — when `ExPhoneNumber.parse/2` fails, `format/2` returns `{:error, reason}` and it is stored as `tel`, contradicting the `tel: String.t()` type. Decide whether to keep the raw string or return an error tuple from `parse/1`.

* [ ] **Bring function docs to the standard template** — the scheme modules' `parse/1` docs use `## Example` and lack `### Arguments` and `### Returns`; `URL.parse_query_string/1` lacks `### Arguments`. Add `groups_for_modules` to `docs/0` so the scheme modules and `URL.Parser.ParseError` are grouped.

* [ ] **Add bad-input tests** — none of the cases above are covered; add a test per scheme for empty path, malformed percent-encoding and unknown `urn` namespaces.

* [ ] **Decide the Elixir floor** — `mix.exs` declares `~> 1.13` but CI only exercises 1.17 to 1.20. Either raise the floor to `~> 1.17` in a minor release or accept that older versions are untested.

## Done

* [x] **Add CI, pre-commit hook and session context** — standard 1.17 to 1.20 by OTP 26 to 29 matrix with OTP-versioned cache keys. 2026-09-21.

* [x] **Fix `URL.to_string/1` type warning and version-dependent test** — Elixir 1.20's type checker and its changed `URI.new/1` error part broke the build. 2026-09-21.
