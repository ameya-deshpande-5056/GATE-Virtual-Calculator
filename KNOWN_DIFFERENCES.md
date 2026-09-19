# Known differences and reference conflicts

The screenshots in `reference/screenshots/` are the authoritative source of
truth. The BYJU'S article (`reference/GATE_Virtual_Calculator_Documentation.md`
superseded by https://byjus.com/gate/virtual-calculator/) is a secondary
source with formatting/OCR errors. Where they conflict, the screenshots win.
No claim of exact GATE compatibility is made beyond what is verified below.

## Conflicts (screenshots win)

| Item | Screenshots (authoritative) | BYJU'S / documentation text | Resolution |
|------|-----------------------------|-----------------------------|------------|
| Clear keys | single `C`; no `AC`, no `CE` | documentation lists `C or AC`, `CE` | screenshots win: only `C` |
| Backspace | red `←` arrow button | documentation: "DEL or Backspace" | screenshots win: `←` |
| `%` | present (row 2, col 11) | not mentioned | screenshots win: `%` key present |
| `y-root` | key labelled `ʸ√x`, expression prints `8yroot4` | "y-root" prose | same behaviour, display prints `yroot` |
| Display precision | shortest round-trip (`0.22964991811628313`, `1.6817928305074292`) | "typically shows up to 12-16 digits"; `0.000000` example | screenshots win: shortest round-trip |
| Degree/radian trig display | `tand(35)`, `sind(25)` style prefixes in some captures | plain `sin`/`tan` prose | expression display records the mode prefix |
| Inverse functions | dedicated `sin⁻¹`/`cos⁻¹`/`tan⁻¹` keys | listed as "inverse sin/cos/tan" | same |

## BYJU'S OCR / formatting errors (not copied)

The BYJU'S article contains malformed mathematical symbols (superscripts and
root signs mangled by OCR). The key labels were instead read from the
screenshots (`reference/KEYPAD_LAYOUT.md`): `x^y`, `x³`, `x²`, `ʸ√x`, `³√`,
`log₂x`, `log_y x`, `eˣ`, `10ˣ`, `sinh⁻¹` etc.

## Inferred behaviour (no screenshot coverage)

These follow the GATE button-sequence model but have no direct screenshot:

- `mod` — truncating remainder, standard precedence.
- `Exp` — scientific-notation entry (`1.5 Exp 3` == `1500`); the reference
  shows a `-` sign inside the exponent area (e.g. `1.5E-3`).
- `log_y x` — binary pending operation, same precedence family as `x^y`.
- Degree/radian radio buttons default to `Deg`; switching mode re-evaluates
  what is on screen.
- Memory (`MC MR MS M+ M-`) is session-only, never persisted; `MR` with empty
  memory is a no-op (there is no `M` indicator in the reference).
- Errors surface as a single `Error` token in the result display with a
  machine-readable reason kept on the state for accessibility/tooltips.

## Verification status

Every screenshot display sample is reproduced byte-identically by the engine
(`test/calculator/reference_test.dart`, `source: screenshot`):

| Keys | Expression | Result |
|------|-----------|--------|
| `73 * (2 + 3) =` | `73*(2+3)` | `365` |
| `ln(15) * 2 + 3 =` | `ln(15)*2+3` | `8.416100402204421` |
| `tan(35) * 6 + 2 =` | `tand(35)*6+2` | `6.201245229258259` |
| `8 yroot 4 =` | `8yroot4` | `1.6817928305074292` |
| `125 cube-root` | `cuberoot(125)` | `5` |
| `fact(8) * 5 - 2 =` | `fact(8)*5-2` | `201598` |
| `18 x^y 0.509 +/- =` | `18^-0.509` | `0.22964991811628313` |

The numerical engine is pure Dart (`lib/calculator/domain/`,
`lib/calculator/parser/`) with no Flutter dependency; the reference
implementation is JavaScript, and display formatting matches
`Number.prototype.toString()` semantics (shortest round-trip, verified on all
seven samples). Remaining un-screenshotted behaviours above should be compared
against a reliable reference implementation before any exact-compatibility
claim.
