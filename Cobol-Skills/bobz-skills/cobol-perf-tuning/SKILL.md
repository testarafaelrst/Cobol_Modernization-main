---
name: cobol-perf-tuning
description: >-
  Use when the user asks about improving performance of COBOL programs in
  Enterprise COBOL 6.5 — including compiler options OPT(FULL), ARCH, TUNE,
  TRUNC(OPT), INVDATA, SMARTBIN, data type recommendations (BINARY vs DISPLAY,
  COMP-3 digit rules), INDEX vs subscript, SEARCH ALL, or CICS/IMS tuning.
---

# Skill: Performance Tuning — COBOL II to Enterprise COBOL 6.5

Follow these steps when the user wants to tune a COBOL program or
understand performance differences between COBOL II and EC 6.5.

## Step 1 — Establish Baseline

Ask the user for:
- The compile PARM currently in use
- Whether the program is batch, CICS, or IMS
- Any known performance symptoms (high CPU, slow response, excessive I/O)

Use `ask_followup_question` if the context is missing.

## Step 2 — Review Compiler Options

Check for sub-optimal options and propose replacements:

| Current Option | Recommended EC 6.5 Option | CPU Impact |
|---|---|---|
| `OPTIMIZE` / `NOOPTIMIZE` | `OPT(FULL)` | Largest single gain |
| No `ARCH` / old `ARCH` | `ARCH(10)` + `TUNE(10)` | Vector/SIMD for loops & strings |
| `NUMPROC(NOPFD)` | `INVDATA(NOFIXUP,NODECIMAL)` | Eliminates sign fix-up code |
| `TRUNC(STD)` | `TRUNC(OPT)` if data is clean | Eliminates base-10 divide |
| `SSRANGE` in production | `NOSSRANGE` | Removes bounds-check overhead |
| `TEST` in production | `NOTEST` | Removes debug instrumentation |
| No `SMARTBIN` | `SMARTBIN` | Enables future ABO optimization |

Production PARM target:
```
OPT(FULL),ARCH(10),TUNE(10),TRUNC(OPT),NOSSRANGE,NOTEST,NODYNAM
INVDATA(NOFIXUP,NODECIMAL),RENT,LIB,SMARTBIN
```

Reference: `Cobol-Skills/skill-perf-modernization.md` §"Compiler Options".

## Step 3 — Review Data Types in Hot Paths

Identify loops, arithmetic areas, and table operations. Apply these rules:

**Binary (BINARY / COMP):**
- Use `PIC S9(4) BINARY` for counters, subscripts, loop variables
- Use `PIC S9(8) BINARY` for accumulators
- Avoid `PIC S9(9) BINARY` — triggers doubleword conversion overhead
- Use `SYNCHRONIZED` clause to ensure halfword/fullword alignment

**COMP-3 (Packed Decimal):**
- Use odd number of digits: `PIC S9(13)V99 COMP-3` (8 bytes, efficient)
- Stay at ≤15 digits for inline multiplication/division
- Avoid 16 digits (even, less efficient)

**DISPLAY in computations — always convert:**
```cobol
* SLOW
01  WS-CTR  PIC 9(4) DISPLAY.
PERFORM VARYING WS-CTR FROM 1 BY 1 UNTIL WS-CTR > 1000

* FAST
01  WS-CTR  PIC S9(4) BINARY.
PERFORM VARYING WS-CTR FROM 1 BY 1 UNTIL WS-CTR > 1000
```

Reference: `Cobol-Skills/skill-perf-modernization.md` §"Data Types".

## Step 4 — Review Table Access

```cobol
* SUBSCRIPT — calculates offset each access (slower)
MOVE WS-ITEM(WS-SUB) TO WS-DEST.

* INDEX — offset pre-calculated (faster)
SET WS-IDX TO 5
MOVE WS-ITEM(WS-IDX) TO WS-DEST.

* SEARCH ALL — binary search O(log n) for large sorted tables
SEARCH ALL WS-TABLE-ENTRY
    AT END SET WS-NOT-FOUND TO TRUE
    WHEN WS-KEY(WS-IDX) = WS-SEARCH-KEY SET WS-FOUND TO TRUE
END-SEARCH
```

## Step 5 — CICS-Specific Recommendations

For CICS programs, verify these options are set:
- `TRUNC(OPT)` — only if all BINARY data conforms to PIC definition
- `NODYNAM` — static calls have lower overhead than dynamic
- `RENT` — mandatory for reentrancy under CICS
- `NOSSRANGE` — no bounds checking in production
- `ARCH(10)` + `TUNE(10)` — hardware-native instructions

## Step 6 — Produce Tuning Report

Output two sections:
1. **Quick Wins** — compiler option changes only (no source changes)
2. **Source Changes** — data type and structure improvements with before/after code

For each recommendation include: **Estimated CPU Impact** (High/Medium/Low)
and **Risk of Regression** (Low = no semantic change / High = test required).
