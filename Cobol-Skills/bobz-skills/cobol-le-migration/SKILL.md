---
name: cobol-le-migration
description: >-
  Use when the user asks about migrating COBOL II runtime calls to Language
  Environment — including IGZERRE, IGZETUN, IGZCLOC, RTEREUS, LIBKEEP, STAE,
  MIXRES, STEPLIB changes from COB2.SCOB2LKE to CEE.SCEERUN, AMODE 64 migration,
  or LE dump and diagnostic setup (CEEDUMP, CEESNAP).
---

# Skill: Language Environment Migration — COBOL II to EC 6.5

Follow these steps when the user needs to replace COBOL II runtime modules
or options with Language Environment equivalents.

## Step 1 — Identify Runtime Calls in the Source

Scan the provided program for direct calls to COBOL II runtime modules:

| COBOL II Call | Replace With | Notes |
|---|---|---|
| `CALL 'IGZERRE'` | `CALL 'CEEPIPI'` | LE enclave init/term |
| `CALL 'IGZETUN'` | `CALL 'CEESIGT'` | LE condition handler registration |
| `CALL 'IGZCLOC'` | `CALL 'CEEDATM'` | LE date/time service |
| `CALL 'ILBOSTP0'` | Remove — use LE enclave lifecycle | OS/VS COBOL compat stub |
| `CALL 'ILBDSET0'` | Remove — use LE enclave lifecycle | DOS/VS COBOL compat stub |

Reference: `Cobol-Skills/skill-le-migration.md` §"Runtime Calls Table".

## Step 2 — Map Runtime Options

Identify runtime options in IGZOPT or JCL PARM and map to LE equivalents:

| COBOL II Option | LE Equivalent | Notes |
|---|---|---|
| `RTEREUS` | Configure via `TRAP(ON,NOSPIE)` + `CEEBXITA` exit | LE manages enclave reuse |
| `LIBKEEP` | Default LE behavior — no action needed | LE keeps runtime loaded |
| `STAE` | `TRAP(ON)` | LE default |
| `NOSTAE` | `TRAP(OFF)` | Disables LE condition interception |
| `WSCLEAR` | `STORAGE(00,00,00)` | Clears WS to zeros |
| `MIXRES` | Not needed — LE manages all modules | Remove |

## Step 3 — Update STEPLIB / JOBLIB

Produce a corrected STEPLIB concatenation:

```jcl
* REMOVE:
//        DD DSN=COB2.SCOB2LKE,DISP=SHR   <- COBOL II runtime
//        DD DSN=COB2.SCOB2LOD,DISP=SHR   <- COBOL II library

* ADD:
//        DD DSN=CEE.SCEERUN,DISP=SHR     <- LE runtime
//        DD DSN=CEE.SCEECICS,DISP=SHR    <- LE CICS support (if CICS program)
```

Never mix `COB2.SCOB2LKE` and `CEE.SCEERUN` in the same concatenation.

## Step 4 — AMODE Considerations

If the program is a candidate for 64-bit migration (`LP(64)`):

- Add compiler option `LP(64)` to enable AMODE 64
- Replace `USAGE POINTER` (4 bytes in AMODE 31) with `USAGE POINTER-64` where needed
- Use `POINTER-32` for explicit 4-byte pointers in LP(64) programs
- Verify `DATA(31)` vs `DATA(64)` for Working-Storage location

Flag programs that use `DATA(24)` — they must be reviewed for below-the-line dependency.

## Step 5 — Configure Diagnostic DDs

Add LE diagnostic DDs to batch JCL:

```jcl
//CEESNAP  DD SYSOUT=*
//CEEDUMP  DD SYSOUT=*
//SYSABEND DD SYSOUT=*
```

Replace `IGZSNAP` / `IGZDUMP` references with `CEEDUMP` calls or structured
LE dumps via `CEEDUMP` callable service.

## Step 6 — Functional Equivalence Assessment

For each replaced call, state whether behavior is guaranteed identical.
Flag any case where the LE service has a different parameter interface or
return convention — those require a test before promoting to production.
