# Skill: Compiler Options — COBOL II to Enterprise COBOL 6.5

> Sources: `skill-migration-v65.md` Tables 22, 23, 46 / Ch.19 and 20 /
> `skill-perf-tuning.md` §"Compiler options that affect run-time performance"

---

## 1. Option Migration Map

### 1.1 Removed Options — Mandatory Action

| COBOL II Option | Status in EC 6.5 | Action |
|---|---|---|
| `RES` / `NORES` | **Removed** in EC 5+ | Remove from JCL/PROC |
| `RESIDENT` / `NORESIDENT` | **Removed** in EC 5+ | Remove from JCL/PROC |
| `CMPR2` / `NOCMPR2` | **Removed** in EC 6+ | Remove; convert program to ANSI 85 |
| `SIZE(MAX)` | **Removed** in EC 5.2 | Remove |
| `ZONECHECK` | **Replaced** by `NUMCHECK(ZON)` | Update to `NUMCHECK(ZON)` |
| `ZONEDATA` | **Replaced** by `INVDATA` | Update to `INVDATA` |

> **Ref:** `skill-migration-v65.md` Table 46 "Compiler options not available in EC 5 and 6"

---

### 1.2 Equivalent Options — Migrate as Usual

| COBOL II Option | Enterprise COBOL 6.5 Equivalent | Notes |
|---|---|---|
| `OPTIMIZE` | `OPT(FULL)` | `OPT(FULL)` is more granular |
| `NOOPTIMIZE` | `OPT(0)` | For development/debug |
| `NUMPROC(PFD)` | `INVDATA(NOFIXUP,NODECIMAL)` | Finer control |
| `NUMPROC(NOPFD)` | `INVDATA(FIXUP,DECIMAL)` | Conservative default |
| `TRUNC(OPT)` | `TRUNC(OPT)` | Kept — recommended for CICS |
| `TRUNC(BIN)` | `TRUNC(BIN)` | Kept |
| `TRUNC(STD)` | `TRUNC(STD)` | ANSI default |
| `TEST` | `TEST(DWARF,SEPARATE)` | Debug without load module overhead |
| `NOTEST` | `NOTEST` | Production |
| `RENT` | `RENT` | Mandatory for CICS — kept |
| `NODYNAM` | `NODYNAM` | Static calls — recommended for CICS |
| `DYNAM` | `DYNAM` | Dynamic calls |
| `SSRANGE` | `SSRANGE(MSG)` | Message instead of abend |
| `NOSSRANGE` | `NOSSRANGE` | Production — no overhead |
| `AWO` | `AWO` | Variable-length sequential files |
| `LIB` | `LIB` | Processes COPY |
| `APOST` | `APOST` | Apostrophe literals |
| `FASTSRT` | `FASTSRT` | Optimized SORT |

---

### 1.3 New Options in Enterprise COBOL 6.x — Adopt

| Option | Version | Description | When to Use |
|---|---|---|---|
| `CICS` | EC 5+ | Integrated CICS Translator | Every CICS program |
| `SQL` | EC 5+ | Integrated DB2 Coprocessor | Every DB2 program |
| `OPT(FULL)` | EC 5+ | Full optimization | Production |
| `ARCH(10)` | EC 6.3 | z15/z16 instructions | New development |
| `TUNE(10)` | EC 6.3 | Performance tuning for z15/z16 | Together with ARCH |
| `LP(64)` | EC 6.3 | 64-bit mode (AMODE 64) | Large programs |
| `INVDATA` | EC 6.3 | Replaces NUMPROC + ZONEDATA | All programs |
| `NUMCHECK` | EC 6.2 | Detects invalid data at compile time | Code quality |
| `INITCHECK` | EC 6.2 | Detects uninitialized variables | Code quality |
| `PARMCHECK` | EC 6.2 | Checks parameter types in CALLs | Code quality |
| `SMARTBIN` | EC 6.4 | Metadata for IBM ABO | Stable production |
| `CONDCOMP` | EC 6.4 | Conditional compilation | Code for multiple environments |

---

## 2. Recommended Compile PARM

### 2.1 COBOL II (original)
```jcl
//COBCOMP  EXEC PGM=IGYCRCTL,
//         PARM='APOST,LIB,RENT,RES,OPT,NODYNAM,NODECK'
```

### 2.2 Enterprise COBOL 6.5 — Minimum for migration
```jcl
//COBCOMP  EXEC PGM=IGYCRCTL,
//         PARM='APOST,LIB,RENT,OPT(FULL),NODYNAM,NODECK,NOSSRANGE'
*                                ^^^^^^^^^                ^^^^^^^^^
*                     RES removed         SIZE removed
```

### 2.3 Enterprise COBOL 6.5 — CICS + DB2 program (recommended)
```jcl
//COBCOMP  EXEC PGM=IGYCRCTL,
//         PARM='APOST,LIB,RENT,OPT(FULL),NODYNAM,NODECK,NOSSRANGE',
//         PARM='CICS(''COBOL2''),SQL,ARCH(10),TUNE(10),TRUNC(OPT)',
//         PARM='INVDATA(NOFIXUP),NUMCHECK,INITCHECK,TEST(NODWARF)'
```

> **Note:** For long option lists, use a `CEEOPTS DD` for LE options instead
> of putting everything in the JCL `PARM`.

---

## 3. The `INVDATA` Option — Replaces `NUMPROC` and `ZONEDATA`

| COBOL II | Enterprise COBOL 6.5 | Behavior |
|---|---|---|
| `NUMPROC(PFD)` | `INVDATA(NOFIXUP,NODECIMAL)` | Assumes valid data — maximum performance |
| `NUMPROC(NOPFD)` | `INVDATA(FIXUP,DECIMAL)` | Fixes sign — maximum compatibility |
| `NUMPROC(MIG)` | `INVDATA(FIXUP,NODECIMAL)` | Fixes receivers only |
| `ZONEDATA(PFD)` | `INVDATA(NOFIXUP)` | Zoned decimal without fix-up |
| `ZONEDATA(MIG)` | `INVDATA(FIXUP)` | Zoned decimal with fix-up |

**Migration recommendation:**
1. Start with `INVDATA(FIXUP,DECIMAL)` — the most conservative behavior,
   equivalent to `NUMPROC(NOPFD)`.
2. Run a full regression test.
3. Move to `INVDATA(NOFIXUP,NODECIMAL)` for programs that confirm their
   data is always valid (equivalent to `NUMPROC(PFD)` — best performance).

---

## 4. The `OPT` Option — Production Performance

| COBOL II | Enterprise COBOL 6.5 | Effect |
|---|---|---|
| `OPTIMIZE` | `OPT(FULL)` | All available optimizations |
| `NOOPTIMIZE` | `OPT(0)` | No optimization (development) |
| — | `OPT(1)` | Basic flow optimizations |
| — | `OPT(2)` | Storage and data optimizations |

> **Ref:** `skill-perf-tuning.md` §"OPTIMIZE or NOOPTIMIZE"

**Important:** `OPT(FULL)` combined with `TEST` causes a conflict — the compiler
automatically disables optimizations that are incompatible with debugging.
For debugging in production: `TEST(DWARF,SEPARATE)` + `OPT(FULL)`.

---

## 5. Diagnostic Options — Code Quality

### `NUMCHECK` — invalid numeric data
```jcl
NUMCHECK(PAC,ZON,BIN)  *> checks COMP-3, DISPLAY and BINARY
```
Detects data with a wrong sign, invalid zone bits, or values outside the
PIC range.

### `INITCHECK` — uninitialized variables
```jcl
INITCHECK(STRICT)  *> error if any logic path fails to initialize
INITCHECK(LAX)     *> warning only if no path initializes
```

### `PARMCHECK` — parameter types in CALL
```jcl
PARMCHECK(MSG)  *> warning on type mismatch
PARMCHECK(ABD)  *> abend on type mismatch
```

---

## 6. ARCH and TUNE — Code Generation for Current Hardware

| Option | Target Hardware | Recommendation |
|---|---|---|
| `ARCH(10)` | z14 | Default in EC 6.4 |
| `ARCH(11)` | z15 | z15 and later |
| `ARCH(12)` | z16 | z16 and later |
| `ARCH(13)` | EC 6.3+ | Future |
| `TUNE(10)` | z14 | Together with ARCH(10) |
| `TUNE(11)` | z15 | Together with ARCH(11) |

> Using `ARCH` and `TUNE` matching the execution hardware produces code
> with vector and SIMD instructions that can improve the performance of
> loops and string operations by up to 30-50%.
>
> **Ref:** `skill-migration-v65.md` §Ch.19 "Compiler option changes in EC 6"
