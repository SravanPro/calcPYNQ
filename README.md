# calcPYNQ
Scientific calculator, with the PYNQ Z2's onboard processor now driving the LCD display instead of the arduino. 

The arduino is now only being used for supplying power to the custom keyboard (3.3V) and the LCD display (5V).

https://github.com/user-attachments/assets/389a4112-c7c6-4885-92b8-7969b5daa8bb

<img width="612" height="902" alt="Image" src="https://github.com/user-attachments/assets/d8424740-f052-4ebc-b522-486a7966daea" />

<img width="605" height="817" alt="Image" src="https://github.com/user-attachments/assets/7706d8c8-61e2-4e12-9fd1-0da00fd7efd1" />

<img width="609" height="781" alt="Image" src="https://github.com/user-attachments/assets/ab019397-ef28-4b0f-b84d-f11d81900016" />

<img width="610" height="796" alt="Image" src="https://github.com/user-attachments/assets/4298e0a1-437e-4a94-a262-307ce3e99031" />


# FPGA Scientific Calculator — Project Documentation

## Overview

This project implements a **fixed-point scientific calculator** on an FPGA. The user inputs a mathematical expression via physical buttons. The hardware parses it, converts it to postfix, and evaluates it using a custom floating-point-like arithmetic engine. The number format used throughout is:

```
{ 2'b type | 1'b sign | 34'b mantissa | 7'b exponent }  =  44 bits total
```

A number is represented as `mantissa × 10^exponent`, with mantissa capped at `17_179_869_183` (~2^34). This gives roughly 10 significant decimal digits across a wide dynamic range.

---

## System Architecture — Top-Level Flow

```
Physical Buttons
      │
      ▼
[debouncer]  →  [decoder]  →  [keyboard]
                                   │
                                   ▼
                            [dataStructure]   ← raw token buffer
                                   │
                                   ▼
                            [numBuilder]      ← tokenize digits into numbers
                                   │  done pulse
                                   ▼
                            [inToPost]        ← shunting-yard infix → postfix
                                   │  done pulse
                                   ▼
                            [postEval]        ← postfix stack evaluator
                                   │
                                   ▼
                              answer (44-bit result)
                                   │
                                   ▼
                              axiOut (320-bit packed bus to SPI/display)
```

Each stage is triggered by the `done` pulse of the stage before it. The pipeline is strictly sequential — no stage overlaps with another.

---

## Module Reference

---

### `parent`

**Role:** Top-level integrator. Instantiates every other module and wires them together. Also handles the physical input decoding (debouncing, 5-to-32 bit decoding), and packs the final output into a 320-bit AXI bus.

**Key responsibilities:**
- Accepts a 5-bit encoded raw input from physical buttons.
- Routes debounced + decoded signals to `keyboard`.
- Chains `keyboard → dataStructure → numBuilder → inToPost → postEval`.
- Packs `{ jump, sizeOut, ptrOut, answer, flat_mem }` into `axiOut[319:0]`.

**Dependencies:** `clockDivider`, `decoder`, `debouncer`, `keyboard`, `dataStructure`, `numBuilder`, `inToPost`, `postEval`.

---

### `clockDivider`

**Role:** Divides the input clock by 64 for use as the internal pipeline clock.

**Mechanism:** A 6-bit counter increments each `clockIn` cycle; when it hits 31 it resets and toggles `clock`. Result: `clock` frequency = `clockIn / 64`.

**Used by:** `parent` — feeds `clock` to all pipeline modules (`keyboard`, `ds`, `nb`, `itp`, `pev`). `debouncer` intentionally keeps `clockIn` directly for accurate debounce timing.

**Dependencies:** None.

---

### `decoder`

**Role:** Expands a 5-bit active-low encoded input into a 32-bit active-high one-hot output.

**Mechanism:** Combinational. Inverts the 5-bit input to get a 0–31 index, sets `out[index] = 1`, all others 0. This maps the 32 possible button combinations from the physical encoding to individual named signals.

**Used by:** `parent` — its 32-bit output is then manually remapped (bit-assigns) to `b[26:0]`, `del`, `ptrLeft`, `ptrRight`, `jump`, `eval`.

**Dependencies:** None.

---

### `debouncer`

**Role:** Removes mechanical bounce from physical button inputs.

**Parameters:** `width`, `freq`, `debounceTime`

**Mechanism:**
- Uses a tick counter based on `freq` and `debounceTime` to sample inputs every N milliseconds.
- Two-stage synchronizer on raw input to cross clock domains.
- Only updates `debounced` output when the input has been stable for a full debounce period.

**Dependencies:** None.

---

### `keyboard` (`kb`)

**Role:** Encodes button presses into 8-bit token opcodes and generates control pulses.

**Mechanism:**
- Combinational priority encoder: scans all button inputs, picks the first active one, maps it to an opcode.
- Sequential block: latches the opcode into `dataIn`, asserts `insert` while a key is held, and passes through `del`, `ptrLeft`, `ptrRight`, `eval` as pulses.

**Opcode Map (partial):**

| Code | Symbol |
|------|--------|
| `0x00`–`0x09` | Digits 0–9 |
| `0x2A`–`0x2D` | `+ - * /` |
| `0x1E`, `0x1F` | `(`, `)` |
| `0xDD`, `0xDC` | `.` , `,` |
| `0xC0`, `0xC1` | `e`, `π` |
| `0xF0`–`0xF6` | `exp, ln, pow, log, sin, cos, tan` |

**Dependencies:** None (purely combinational + registered output).

---

### `dataStructure` (`ds`)

**Role:** Cursor-aware editable buffer for raw 8-bit token input.

**Mechanism:**
- Acts like a text editor buffer: supports `insert` at cursor, `delete` before cursor, `ptrLeft`, `ptrRight`.
- All operations are edge-triggered (pulse detection via prev-state registers).
- On insert: shifts everything right of cursor rightward, places new token.
- On delete: shifts everything at/after cursor leftward.
- Exposes full memory array `mem[depth]`, `sizeOut`, `ptrOut`.

**Dependencies:** None.

---

### `numBuilder` (`nb`)

**Role:** Tokenizer. Converts the raw 8-bit character array from `dataStructure` into a structured 44-bit token array where digit sequences are collapsed into number tokens.

**Mechanism:**
- Walks the input array one token per clock cycle (`running` flag).
- Accumulates digits: `mantissa = mantissa * 10 + digit`. Tracks decimal point position in `exp`.
- On hitting a non-digit (operator, bracket, function): flushes the pending number as `{2'b00, sign, mantissa, exp}`, then flushes the operator as `{2'b01, 34'b0, opcode}`.
- Constants `e` (`0xC0`) and `π` (`0xC1`) are inlined as hardcoded mantissa/exp values.
- Fires `done` pulse when complete.

**Dependencies:** None (reads from `ds` output wires).

---

### `inToPost` (`itp`)

**Role:** Converts infix token array (44-bit) to postfix using the **Shunting-Yard algorithm**.

**States:** `S_READ → S_RB_POP / S_DC_POP / S_OP_POP → S_DONE`

**Mechanism:**
- Numbers and constants → directly to postfix output.
- Functions and `(` → pushed onto operator stack.
- `)` → triggers `S_RB_POP`: pops to output until `(` found; if a function precedes the `(`, it too is popped to output.
- `,` → triggers `S_DC_POP`: pops to output until `(` found (handles multi-argument functions like `pow(x,y)`).
- Operators → triggers `S_OP_POP`: pops higher/equal precedence operators first, then pushes current.
- `S_DONE`: flushes remaining stack to output, then fires `done`.

**Operator precedence:** `* /` = 2, `+ -` = 1.

**Dependencies:** None (reads from `nb` output wires).

---

### `postEval` (`pev`)

**Role:** Evaluates a postfix token array using a value stack. The most complex module — it instantiates and orchestrates all arithmetic cores.

**States:** `S_IDLE → S_READ → S_OP_POP → S_LAUNCH → S_WAIT → S_DONE`

**Mechanism:**
- Numbers → pushed directly onto value stack.
- Operator/function token → `S_OP_POP` pops operands (1 for unary, 2 for binary), then `S_LAUNCH` asserts the correct `eval` pulse to the right arithmetic core.
- `S_WAIT` polls `moduleDone` (a combinational mux keyed on `op[7:0]`) until the active core finishes.
- Result is pushed back onto the stack.
- Final answer = top of stack.

**Subtraction handling:** Sign of the top operand (`A`) is inverted before calling `adder`, making subtraction a signed addition.

**Dependencies (instantiated inside `pev`):**

| Module | Opcode |
|--------|--------|
| `adder` | `0x2A` (+), `0x2B` (−) |
| `multiplier` | `0x2C` (×) |
| `divider` | `0x2D` (÷) |
| `exp_core` | `0xF0` |
| `ln_core` | `0xF1` |
| `pow_core` | `0xF2` |
| `log_core` | `0xF3` |
| `sin_core` | `0xF4` |
| `cos_core` | `0xF5` |
| `tan_core` | `0xF6` |
| `seq_multiplier` | shared bus |
| `seq_divider` | shared bus |

---

## Arithmetic Modules

---

### `adder`

**Role:** Adds or subtracts two fixed-point numbers `(sign, mantissa, exponent)`.

**Algorithm:**
1. Identify larger exponent (L) and smaller exponent (S).
2. Compute `n` = how many times L's mantissa can be ×10 safely (via `mul10Count`).
3. Compute `d` = exponent difference.
4. **Case A** (`n ≥ d`): multiply L's mantissa by 10 `d` times, decrement its exponent, aligning both to the same exponent.
5. **Case B** (`n < d`): multiply L by 10 `n` times AND divide S by 10 `(d−n)` times, meeting in the middle.
6. Perform sign-aware addition/subtraction.
7. Normalize result back into `[0, M_MAX]`.

**Internal dependency:** `mul10Count` (combinational helper).

---

### `mul10Count`

**Role:** Purely combinational. Given a 34-bit mantissa `x`, returns how many times it can be safely multiplied by 10 before overflowing `M_MAX = 17_179_869_183`, with a safety margin of 1.

**Used by:** `adder` only.

---

### `multiplier`

**Role:** Multiplies two fixed-point numbers.

**Algorithm:** Single-cycle brute multiply (uses `*` operator in `S_EVAL`):
- `mantRes = mantX * mantY` (normalized iteratively in `S_FINALIZATION`)
- `expRes  = expX + expY`
- `signRes = signX ^ signY`

**Note:** This is a simple FSM multiplier, NOT the 512-bit sequential one. Used for user-level `×` operations only.

---

### `divider`

**Role:** Divides two fixed-point numbers.

**Algorithm:**
- Scales numerator's mantissa by `10^12` before integer division to preserve precision.
- `mantDiv = (mantB * 10^12) / mantA`
- `expDiv  = (expB − 12) − expA`
- `signRes = signA ^ signB`
- Normalizes result.

**Note:** Also a simple FSM divider, not the shared 512-bit one.

---

### `seq_multiplier`

**Role:** Sequential 512-bit unsigned shift-and-add multiplier. Takes 512 clock cycles per operation.

**Protocol:** `start` pulse → busy → `done` pulse + `product`.

**Shared by:** `exp_core`, `ln_core`, `pow_core`, `sin_core`, `cos_core`, `tan_core` — all via the `pev` shared bus.

---

### `seq_divider`

**Role:** Sequential 512-bit restoring binary long division. Takes 512 clock cycles per operation.

**Protocol:** `start` pulse → busy → `done` pulse + `quotient` + `remainder_out`.

**Shared by:** Same set as `seq_multiplier`.

---

### `exp_core`

**Role:** Computes `e^x` for a fixed-point input.

**Algorithm:**
1. `fixedX = mantA × SCALE` (via `seq_multiplier`). SCALE = 10^15.
2. Absorb `expA`: multiply by 10 (shift-add, free) or divide by 10 (via `seq_divider`).
3. Range-reduce: `k = floor(fixedX / ln2)` (via `seq_divider`), `r = fixedX − k×ln2` (via `seq_multiplier`).
4. Taylor series for `e^r`, 28 terms: `term_{n+1} = term_n × r / (SCALE × (n+1))`.
5. `e^x = e^r × 2^k` (k left-shifts, free).
6. If input was negative: `result = SCALE² / result` (via `seq_divider`).
7. Normalize.

**Dependencies:** `seq_multiplier`, `seq_divider` (via shared bus in `pev`).

---

### `ln_core`

**Role:** Computes `ln(x)` using an artanh series.

**Algorithm:**
1. `f_s = mantA × SCALE` (via `seq_multiplier`).
2. Binary range-reduce `f_s` into `[SCALE, 2×SCALE)` using bit-shifts, counting shifts as `p`.
3. `u = (f_s − SCALE) / (f_s + SCALE)` (mul + div via bus).
4. `u² = u² / SCALE` (mul + div).
5. Artanh series, 24 terms: `ln(x) ≈ 2 × Σ u^(2n+1) / (2n+1)`.
6. Combine: `result = 2×sum + p×ln2 + expA×ln10` (the last two via `seq_multiplier`).
7. Extract sign, normalize.

**Dependencies:** `seq_multiplier`, `seq_divider` (via shared bus).

---

### `log_core`

**Role:** Computes `log_y(x) = ln(x) / ln(y)`.

**Algorithm:**
1. Call `ln_core` with `x` → get `ln(x)`.
2. Call `ln_core` with `y` → get `ln(y)`.
3. Divide: `ln(x) × SCALE / ln(y)` (via `seq_divider`).
4. Normalize.

**Dependencies:** `ln_core` (called twice sequentially), `seq_divider` (via shared bus).

---

### `pow_core`

**Role:** Computes `x^y = exp(y × ln(x))`.

**Algorithm:**
1. Call `ln_core` with `x` → `ln(x)`.
2. Multiply `y × ln(x)` (mantissa multiply via `seq_multiplier`, exponent add, sign XOR).
3. Normalize `y×ln(x)`.
4. Call `exp_core` with the result.

**Dependencies:** `ln_core`, `exp_core`, `seq_multiplier`, `seq_divider` (all via shared bus).

---

### `sin_core`

**Role:** Computes `sin(x)` via Taylor series.

**Algorithm:**
1. `fixedX = mantA × SCALE` (via `seq_multiplier`).
2. Absorb `expA`.
3. Range-reduce to `[0, 2π)` (div then mul via bus).
4. Quadrant reduction to `[0, π/2]`, tracking sign flip.
5. `xr² = xr × xr` (unscaled, via `seq_multiplier`).
6. Taylor: 15 terms of `sin(x) = x − x³/3! + x⁵/5! − ...`
   Each term: `cur × xr² / SCALE / (da×db×SCALE)` (2 muls + 2 divs per term).
7. Normalize.

**Dependencies:** `seq_multiplier`, `seq_divider` (via shared bus).

---

### `cos_core`

**Role:** Computes `cos(x)` via Taylor series. Structurally identical to `sin_core`.

**Differences from sin_core:**
- Sign of input is irrelevant (cos is even); `signFlip` starts at 0.
- Taylor seed is `1.0` (= SCALE) instead of `xr`.
- Denominator starts at `(1,2)` instead of `(2,3)`.
- Quadrant sign-flip logic differs (cos has different sign patterns per quadrant).

**Dependencies:** `seq_multiplier`, `seq_divider` (via shared bus).

---

### `tan_core`

**Role:** Computes `tan(x) = sin(x) / cos(x)`.

**Algorithm:**
1. Call `sin_core` → `sin(x)`.
2. Call `cos_core` → `cos(x)`.
3. Scale numerator: `sin_mant × SCALE` (via `seq_multiplier`).
4. Divide: `scaled_sin / cos_mant` (via `seq_divider`).
5. `expRes = sin_exp − cos_exp − 15`, `signRes = sin_sign ^ cos_sign`.
6. Normalize.

**Dependencies:** `sin_core`, `cos_core`, `seq_multiplier`, `seq_divider` (all via shared bus).

---

## Shared Bus Architecture (inside `postEval`)

The 9 transcendental/trig cores all need big-integer multiply and divide. Instantiating separate 512-bit multipliers/dividers for each would be prohibitively large. Instead, `pev` instantiates **one** `seq_multiplier` and **one** `seq_divider`, and routes them to the active core via a combinational mux.

```
                    ┌─────────────────────────┐
                    │       postEval          │
                    │                         │
  op = 0xF0 ──────▶│  ┌──────────────────┐   │
  op = 0xF1 ──────▶│  │  Combinational   │   │
  op = 0xF2 ──────▶│  │  MUX (on op[7:0])│   │
  op = 0xF3 ──────▶│  └────────┬─────────┘   │
  op = 0xF4 ──────▶│           │              │
  op = 0xF5 ──────▶│     ┌─────▼──────┐      │
  op = 0xF6 ──────▶│     │seq_mul (×1)│      │
                    │     │seq_div (×1)│      │
                    │     └────────────┘      │
                    └─────────────────────────┘
```

**Mux rules (priority when multiple `_start` signals could fire):**

| Active op | mul bus winner | div bus winner |
|-----------|---------------|---------------|
| `0xF2` (pow) | `pow_mul` > `ln_mul` > `exp_mul` | `pow_div` > `exp_div` > `ln_div` |
| `0xF3` (log) | `ln_mul` | `log_div` > `ln_div` |
| `0xF6` (tan) | `tan_mul` > `sin_mul` > `cos_mul` | `tan_div` > `sin_div` > `cos_div` |
| Others | direct passthrough | direct passthrough |

This works because `pev` serializes all operations — only one opcode is ever active. The FSM never launches a new operation until the current one fires `done`.

---

## Core Dependency Chain

```
tan_core
  ├── sin_core  ──┐
  └── cos_core  ──┤
                  └──▶ seq_multiplier
                        seq_divider

pow_core
  ├── ln_core   ──┐
  └── exp_core  ──┤
                  └──▶ seq_multiplier
                        seq_divider

log_core
  └── ln_core (×2) ──▶ seq_multiplier
                         seq_divider

exp_core ──▶ seq_multiplier, seq_divider
ln_core  ──▶ seq_multiplier, seq_divider
sin_core ──▶ seq_multiplier, seq_divider
cos_core ──▶ seq_multiplier, seq_divider
```

Sub-cores (`ln_core`, `exp_core`, `sin_core`, `cos_core`) share the same physical `seq_multiplier`/`seq_divider` instances as their parents. The parent core's FSM orchestrates the order; the sub-core's `start` signals are ORed into the shared bus.

---

## Parent Module — Signal Flow Detail

```
clockIn ──▶ clockDivider ──▶ clock  (slow internal clock)
clockIn ──▶ debouncer                (fast clock for debounce timing)

encodedRawInput[4:0]
  ──▶ debouncer ──▶ encodedDebouncedInput[4:0]
  ──▶ decoder   ──▶ decodedOutput[31:0]   (one-hot, 32 signals)
  ──▶ (bit-remap assigns) ──▶ b[26:0], del, ptrLeft, ptrRight, jump, eval

keyboard:
  b[26:0], del, ptrLeft, ptrRight, eval
  ──▶ dataIn[7:0], insert_pulse, del_pulse, ptrLeft_pulse, ptrRight_pulse, eval_pulse

dataStructure:
  dataIn, insert_pulse, del_pulse, ptrLeft_pulse, ptrRight_pulse
  ──▶ mem[depth][8], sizeOut, ptrOut

numBuilder:
  triggered by eval_pulse
  reads mem, sizeOut
  ──▶ memOut[depth][44], newSize, done1

inToPost:
  triggered by done1
  reads memOut, newSize
  ──▶ postfix[depth][44], postfixSize, done2

postEval:
  triggered by done2
  reads postfix, postfixSize
  ──▶ answer[43:0], done

axiOut[319:0] = { 3'b000, jump,       // 4 bits
                  2'b00,  sizeOut,     // 8 bits
                  2'b00,  ptrOut,      // 8 bits
                  answer,              // 44 bits
                  flat_mem }           // 256 bits (mem flattened)
```

The `axiOut` bus is intended for an external SPI display controller or AXI peripheral to read back both the current buffer state and the computed answer simultaneously.

---

## Number Format Summary

| Field | Bits | Notes |
|-------|------|-------|
| type | 2 | `00` = number, `01` = operator/func |
| sign | 1 | 0 = positive |
| mantissa | 34 | max `17_179_869_183` (~2^34) |
| exponent | 7 | signed, range ~−64 to +63 |

Value represented: `(−1)^sign × mantissa × 10^exponent`

All internal arithmetic cores use SCALE = `10^15` as a fixed-point base for intermediate computation, then normalize back to the `[M_MAX/10, M_MAX]` mantissa range before outputting.
