# TODO

Work for `ex_url`. Findings from the 2026-09-21 release-readiness review; there are no design documents yet, so no `plans/` directory.

## Blocked

* [ ] **Replace `ex_phone_number` with `localize_phone_number`** — a one-for-one swap of parse and international formatting in `URL.Tel`. Blocked on the user's decision: `localize_phone_number 1.0.0` needs Elixir 1.19 and a system libphonenumber build, so it means raising the floor from 1.17 or supporting both libraries.

## Done

* [x] **Replace `ex_cldr` with `localize`** — territory for `tel` numbers now comes from `Localize.get_locale/0`; ex_cldr, its test backend and config are gone. 2026-09-21, v2.0.3.

* [x] **Bring function docs to the standard template** — every public function has arguments, returns and examples; scheme modules and the exception are grouped in ExDoc. 2026-09-21, v2.0.3.

* [x] **Return errors instead of raising on invalid input** — empty scheme paths, `nil` queries, non-binary input, unparseable `tel` numbers and a missing Cldr backend all return tuples now, with a bad-input test suite. 2026-09-21.

* [x] **Raise the Elixir floor to 1.17** — matches the oldest version CI exercises. 2026-09-21.

* [x] **Add CI, pre-commit hook and session context** — standard 1.17 to 1.20 by OTP 26 to 29 matrix with OTP-versioned cache keys. 2026-09-21.

* [x] **Fix `URL.to_string/1` type warning and version-dependent test** — Elixir 1.20's type checker and its changed `URI.new/1` error part broke the build. 2026-09-21.
