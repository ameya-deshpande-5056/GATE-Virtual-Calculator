# GATE virtual calculator — verified keypad layout

Source of truth: `screenshots/*.jpeg` (seven screenshots of the real GATE exam
calculator window, retrieved from the BYJU'S GATE virtual-calculator page).
Textual references are `GATE_Virtual_Calculator_Documentation.md` and the
BYJU'S article; conflicts are listed at the bottom of this file.

Window: 11 button columns, 6 rows (1 mode/memory row + 5 function/keypad rows),
and two right-aligned display boxes above the keypad.

## Display

| Box | Content | Example (screenshot) |
|-----|---------|----------------------|
| Upper | expression / key sequence | `73*(2+3)` |
| Lower | current value / result  | `365` |

Both boxes are white, 1px grey border, right-aligned text. Verified samples:

| Screenshot | Upper display | Lower display |
|-----------|---------------|---------------|
| step-3-c-1 | `73*(2+3)` | `365` |
| step-4-c-1 | `ln(15)*2+3` | `8.416100402204421` |
| step-5-b-1 | `tand(35)*6+2` | `6.201245229258259` |
| step-6-a-1 | `8yroot4` | `1.6817928305074292` |
| step-7-a-1 | `cuberoot(125)` | `5` |
| step-8-b-1 | `fact(8)*5-2` | `201598` |
| step-9-a-1 | `18^-0.509` | `0.22964991811628313` |

The lower display prints the **shortest round-tripping decimal** of the value
(JavaScript `Number.prototype.toString()` semantics), not a fixed number of
decimals: `201598`, `5`, `0.0025`, `0.22964991811628313`.

## Mode / memory row

| Column | 1 | 2-3 | 4-6 | 7 | 8 | 9 | 10 | 11 |
|--------|---|---|-----|---|---|---|---|----|
| | `mod` | `Deg` `Rad` radio buttons | *(empty)* | `MC` | `MR` | `MS` | `M+` | `M-` |

Radio buttons are drawn as native-looking circles; `Deg` is selected by default
(all screenshots show `Deg` selected).

## Keypad rows (columns 1-11)

| Row | 1 | 2 | 3 | 4 | 5 | 6 | 7 | 8 | 9 | 10 | 11 |
|-----|---|---|---|---|---|---|---|---|---|----|----|
| 1 | `sinh` | `cosh` | `tanh` | `Exp` | `(` | `)` | `←` (spans 7-8) | | | `C` | `+/-` | `√x` |
| 2 | `sinh⁻¹` | `cosh⁻¹` | `tanh⁻¹` | `log₂x` | `ln` | `log` | `7` | `8` | `9` | `/` | `%` |
| 3 | `π` | `e` | `n!` | `log_y x` | `eˣ` | `10ˣ` | `4` | `5` | `6` | `*` | `1/x` |
| 4 | `sin` | `cos` | `tan` | `x^y` | `x³` | `x²` | `1` | `2` | `3` | `-` | `=` (spans rows 4-5) |
| 5 | `sin⁻¹` | `cos⁻¹` | `tan⁻¹` | `ʸ√x` | `³√` | `\`x\`` | `0` (spans 7-8) | | `.` | `+` | `=` (spans rows 4-5) |

Notes

* Row 1: `←`, `C` and `+/-` are red (`#E84C3D`); `←` spans columns 7-8.
* Row 4-5: `=` is green (`#2DCC70`) and spans two rows.
* Row 5: `0` spans columns 7-8, `.` is column 9, `+` is column 10; column 11
  is the green `=`.
* Columns 1-6 hold the function block, columns 7-11 the numeric block.

## Geometry (measured from `gate-calculator-step-3-c-1.jpeg`, 708x505)

| Element | Value |
|---------|-------|
| Title bar | blue `#4286F3`, "Scientific Calculator" left, `Help` button right, `—` and `✕` |
| Window body | `#DADADA` |
| Button face | `#F1F1F1` in the upper rows, `#E9E9E9` for the numeric block |
| Button border | 1px `#AAAAAA`, 4px corner radius, hard "raised" left/top highlight |
| Display border | 1px `#C1C1C1` |
| Button column pitch | 60 px (button 52 px wide + 8 px gap), first column at x=24 |
| Button row height | 33 px, row pitch 45 px |
| Display boxes | 45 px tall, expression box top y=85, result box top y=141 |

## Conflicts between references

| Item | Screenshots (authoritative) | BYJU'S / documentation text | Resolution |
|------|-----------------------------|-----------------------------|------------|
| Clear keys | single `C`; no `AC`, no `CE` | documentation lists `C or AC`, `CE` | screenshots win |
| Backspace | red `←` arrow button | documentation: "DEL or Backspace" | screenshots win |
| `%` | present (row 2 col 11) | not mentioned | screenshots win |
| Inverse functions | dedicated `sin⁻¹`/`cos⁻¹`/`tan⁻¹` keys | listed as "inverse sin/cos/tan" | same |
| `y-root` | key labelled `ʸ√x` | "y-root" | same |
| Display precision | shortest round-trip (`0.22964991811628313`) | "typically shows up to 12-16 digits"; `0.000000` example | screenshots win |
| Decimal-comma vs point | `.` | `.` | same |

The `GATE_Virtual_Calculator_Documentation.md` file is a generic, partly
inaccurate description (it also mentions `CE`, `AC`, a `%`-of-total behaviour
and mode-less trig). It is treated as a *secondary* source; the screenshots are
authoritative wherever they disagree.
