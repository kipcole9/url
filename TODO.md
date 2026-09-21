# TODO

Work for `ex_url`. Findings from the 2026-09-21 release-readiness review; there are no design documents yet, so no `plans/` directory.

## Open

* [ ] **Bring function docs to the standard template** — the scheme modules' `parse/1` docs use `## Example` and lack `### Arguments` and `### Returns`. Add `groups_for_modules` to `docs/0` so the scheme modules and `URL.Parser.ParseError` are grouped.

## Done

* [x] **Return errors instead of raising on invalid input** — empty scheme paths, `nil` queries, non-binary input, unparseable `tel` numbers and a missing Cldr backend all return tuples now, with a bad-input test suite. 2026-09-21.

* [x] **Raise the Elixir floor to 1.17** — matches the oldest version CI exercises. 2026-09-21.

* [x] **Add CI, pre-commit hook and session context** — standard 1.17 to 1.20 by OTP 26 to 29 matrix with OTP-versioned cache keys. 2026-09-21.

* [x] **Fix `URL.to_string/1` type warning and version-dependent test** — Elixir 1.20's type checker and its changed `URI.new/1` error part broke the build. 2026-09-21.
