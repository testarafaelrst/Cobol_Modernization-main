# Skill: Performance — COBOL II to Enterprise COBOL 6.5

> Sources: `skill-perf-tuning.md` (complete) /
> `skill-migration-v65.md` §Ch.19 "Changes with EC 6" and Appendix A "FAQ / Performance"

---

## 1. What Changes in Performance from COBOL II to EC 6.5

Enterprise COBOL 6.5 brings significant performance improvements over
COBOL II, especially in:

| Area | Typical Gain | Mechanism |
|---|---|---|
| COMP-3 numeric code | 10-30% | DFP (Decimal Floating Point) instructions of z/OS |
| Loops and tables | 20-50% | Automatic vectorization with ARCH(10+) |
| String operations | 15-25% | Vectorial SIMD instructions |
| Subprogram calls | 5-15% | Reduced LE enclave overhead |
| Compilation | 2-3x faster | EC 6.5 compiler uses storage above the bar |

---

## 2. Compiler Options for Performance

### 2.1 Required Replacements

| COBOL II | EC 6.5 | Impact |
|---|---|---|
| `OPTIMIZE` | `OPT(FULL)` | Best available optimization |
| `NUMPROC(PFD)` | `INVDATA(NOFIXUP,NODECIMAL)` | Eliminates sign fix-up — up to +15% |
| `TRUNC(OPT)` | `TRUNC(OPT)` | Maintained — recommended for CICS |
| `NOSSRANGE` | `NOSSRANGE` | Eliminates bounds-checking overhead |
| `NODYNAM` | `NODYNAM` | Static calls — lower overhead |

### 2.2 New Performance Options in EC 6.5

```jcl
*-- Recommended production configuration:
PARM='OPT(FULL),ARCH(10),TUNE(10),TRUNC(OPT),NOSSRANGE,NODYNAM'
PARM='INVDATA(NOFIXUP,NODECIMAL),RENT,LIB,NOTEST'
```

**`ARCH(n)` and `TUNE(n)`:**
Generate hardware-specific instructions, including:
- SIMD vectorial instructions for loops
- DFP for decimal arithmetic (COMP-3)
- Hardware-accelerated string instructions

> **Ref:** `skill-perf-tuning.md` §"OPTIMIZE or NOOPTIMIZE" and §"TRUNC"

---

## 3. Coding Techniques for Performance

### 3.1 Data Types — Golden Rules

| Type | Recommended Use | Why |
|---|---|---|
| `PIC S9(4) BINARY` | Counters, subscripts, control fields | Halfword instructions — faster |
| `PIC S9(8) BINARY` | Accumulators, moderate totals | Fullword instructions |
| `PIC S9(15) COMP-3` | Monetary values, decimal calculations | DFP in EC 6.5 — native instructions |
| `PIC S9(9) BINARY` | **Avoid** — fullword converts to doubleword | +1 conversion instruction |
| `PIC 9(n) DISPLAY` | **Do not use in calculations** — conversion overhead | Requires library routine call |

> **Ref:** `skill-perf-tuning.md` §"Data Types"

**Optimization example:**
```cobol
* SLOW — DISPLAY requires conversion
01  WS-COUNTER  PIC 9(4) DISPLAY.
PERFORM VARYING WS-COUNTER FROM 1 BY 1
    UNTIL WS-COUNTER > 1000

* FAST — BINARY uses direct halfword instructions
01  WS-COUNTER  PIC S9(4) BINARY.
PERFORM VARYING WS-COUNTER FROM 1 BY 1
    UNTIL WS-COUNTER > 1000
```

---

### 3.2 Tables — INDEX vs SUBSCRIPT

```cobol
* SUBSCRIPT — calculates offset on every access (slower)
01  WS-TABLE.
    12  WS-ITEM OCCURS 100 PIC X(10).
01  WS-SUB  PIC S9(4) BINARY.

MOVE WS-ITEM(WS-SUB) TO WS-DEST.
*-- WS-SUB contains occurrence number: converts to offset at runtime

* INDEX — pre-calculated offset (faster)
01  WS-TABLE.
    12  WS-ITEM OCCURS 100 INDEXED BY WS-IDX PIC X(10).

SET WS-IDX TO 5
MOVE WS-ITEM(WS-IDX) TO WS-DEST.
*-- WS-IDX already contains the offset: no runtime conversion
```

> **Ref:** `skill-perf-tuning.md` §"Data Types — indexes vs subscripts"

---

### 3.3 COMP-3 — Precision Rules

```cobol
* BEST PRACTICES FOR COMP-3 IN EC 6.5:

* 1. Odd number of digits (uses an integer number of bytes)
01  WS-VALUE  PIC S9(13)V99 COMP-3.   *> 8 bytes - efficient

* 2. Maximum 15 digits for inline multiplication/division
01  WS-BASE   PIC S9(15)    COMP-3.   *> inline calculation (no library call)
01  WS-LARGE  PIC S9(17)    COMP-3.   *> may call library routine

* 3. Avoid 16 digits (even, and less efficient)
01  WS-BAD    PIC S9(16)    COMP-3.   *> avoid — even and large
```

> **Ref:** `skill-perf-tuning.md` §"Data Types — packed decimal COMP-3"

---

### 3.4 Program Structure — Impact on the Optimizer

```cobol
* GOOD for the optimizer — structured code, no irregular GO TO:
EVALUATE TRUE
    WHEN WS-CONDITION-A
        PERFORM 200-PROCESS-A THRU 200-EXIT
    WHEN WS-CONDITION-B
        PERFORM 300-PROCESS-B THRU 300-EXIT
END-EVALUATE

* BAD for the optimizer — GO TO interrupts the optimization flow:
IF WS-CONDITION-A
    GO TO 200-PROCESS-A
IF WS-CONDITION-B
    GO TO 300-PROCESS-B
```

The EC 6.5 compiler with `OPT(FULL)` can inline PERFORM paragraphs
when the flow is structured — reducing call overhead.

> **Ref:** `skill-perf-tuning.md` §"Program Design — coding style and optimizer"

---

### 3.5 SEARCH vs SEARCH ALL

```cobol
* SEARCH (sequential) — O(n) — for small or unsorted tables
SEARCH WS-ITEM
    AT END MOVE 'N' TO WS-FOUND-SW
    WHEN WS-ITEM-KEY(WS-IDX) = WS-KEY
        MOVE 'Y' TO WS-FOUND-SW
END-SEARCH

* SEARCH ALL (binary) — O(log n) — for large SORTED tables
* Requires ASCENDING/DESCENDING KEY in the table definition
SEARCH ALL WS-ITEM
    AT END MOVE 'N' TO WS-FOUND-SW
    WHEN WS-ITEM-KEY(WS-IDX) = WS-KEY
        MOVE 'Y' TO WS-FOUND-SW
END-SEARCH
```

> **Ref:** `skill-perf-tuning.md` §"Program Design — SEARCH statement"

---

## 4. SMARTBIN Option — IBM Automatic Binary Optimizer (ABO)

Available in EC 6.4+, the `SMARTBIN` option includes metadata in the load module
that allows IBM ABO to optimize the module **without recompilation**:

```jcl
PARM='OPT(FULL),ARCH(10),TUNE(10),SMARTBIN,...'
```

**Benefit:** Modules already compiled and in production can be optimized
by ABO for future hardware (z16, z17...) without modifying the source code.

> **Ref:** `skill-migration-v65.md` §Ch.19 "Improved integration with IBM ABO"

---

## 5. Performance in CICS Environments

Specific recommendations for CICS programs (source: `skill-perf-tuning.md` §"CICS"):

| Option | Recommendation | Reason |
|---|---|---|
| `TRUNC(OPT)` | **Use** if BINARY data is correct | Eliminates divisions by powers of 10 |
| `NODYNAM` | **Use** | Static calls are faster than dynamic |
| `RENT` | **Required** | Reentrancy for parallel execution |
| `OPT(FULL)` | **Use** | Maximum optimization |
| `NOSSRANGE` | **Use in production** | Eliminates bounds-checking overhead |
| `NOTEST` | **Use in production** | Eliminates debug code |
| `ARCH(10)+TUNE(10)` | **Use** | Native instructions for current hardware |

---

## 6. Performance Checklist for Migration

```
COMPILATION
[ ] OPT(FULL) in place of OPTIMIZE
[ ] ARCH(10) and TUNE(10) added
[ ] TRUNC(OPT) verified (BINARY data conforms to PIC)
[ ] NOSSRANGE in production
[ ] NOTEST in production
[ ] INVDATA(NOFIXUP,NODECIMAL) if data is always valid

CODE
[ ] Loop variables and subscripts declared as PIC S9(4) BINARY
[ ] COMP-3 fields with an odd number of digits
[ ] COMP-3 with at most 15 digits for inline calculation
[ ] INDEX used instead of SUBSCRIPT for high-frequency tables
[ ] SEARCH ALL for large, sorted tables
[ ] No USAGE DISPLAY in intensive calculation areas
[ ] Program structure without irregular GO TO

PROFILING
[ ] Measure CPU time before and after migration (regression baseline)
[ ] Use RMF/SMF for production baseline
[ ] Compare NOTEST vs TEST to quantify debug overhead
```
