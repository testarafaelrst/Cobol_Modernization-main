---
name: cobol-compiler-options
description: >-
  Use when the user asks which COBOL II compiler options need to change for
  Enterprise COBOL 6.5 — including removed options (RES, RESIDENT, CMPR2, SIZE),
  replacements (OPT(FULL), INVDATA, NUMCHECK), new options (CICS, SQL, ARCH,
  TUNE, SMARTBIN), or how to build the PARM string for a compile JCL/PROC.
---

# Skill: Compiler Options — COBOL II to Enterprise COBOL 6.5

Follow these steps when the user asks about compiler option migration,
PARM construction, or new EC 6.5 options to adopt.

## Step 1 — Capture the Current PARM

Ask the user to provide their current compile `PARM` string or JCL PROC step
if they have not already. Use `ask_followup_question` if needed.

## Step 2 — Scan for Removed Options

Flag any option from this list — they cause compile errors in EC 6.5:

| Removed Option | Action |
|---|---|
| `RES` / `NORES` | Remove — eliminated in EC 5+ |
| `RESIDENT` / `NORESIDENT` | Remove — eliminated in EC 5+ |
| `CMPR2` / `NOCMPR2` | Remove — eliminated in EC 6+; convert source to NOCMPR2 semantics first |
| `SIZE(MAX)` or `SIZE(n)` | Remove — eliminated in EC 5.2 |
| `ZONECHECK` | Replace with `NUMCHECK(ZON)` |
| `ZONEDATA` | Replace with `INVDATA` |

Reference: `Cobol-Skills/skill-compiler-options.md` Table — "Options Removed".

## Step 3 — Map Retained Options to EC 6.5 Equivalents

Apply direct substitutions:

| COBOL II | EC 6.5 Equivalent | Notes |
|---|---|---|
| `OPTIMIZE` | `OPT(FULL)` | More granular; `OPT(0)` for dev |
| `NUMPROC(PFD)` | `INVDATA(NOFIXUP,NODECIMAL)` | Best performance — assumes valid data |
| `NUMPROC(NOPFD)` | `INVDATA(FIXUP,DECIMAL)` | Conservative — safe starting point |
| `TEST` | `TEST(DWARF,SEPARATE)` | Debug without load-module overhead |
| `NOTEST` | `NOTEST` | Production — unchanged |

## Step 4 — Add Mandatory New Options

These options must be added when applicable:

| Option | When Required |
|---|---|
| `CICS('COBOL2')` | Any program with `EXEC CICS` commands |
| `SQL` | Any program with `EXEC SQL` statements |
| `RENT` | All CICS programs — mandatory |
| `NODYNAM` | CICS programs — static calls preferred |

## Step 5 — Recommend Performance Options

Suggest these for production builds:

```
OPT(FULL), ARCH(10), TUNE(10), TRUNC(OPT), NOSSRANGE, NOTEST
INVDATA(NOFIXUP,NODECIMAL), SMARTBIN
```

For quality / first-migration builds (safer):

```
OPT(FULL), NOSSRANGE, NOTEST
INVDATA(FIXUP,DECIMAL), NUMCHECK, INITCHECK, PARMCHECK(MSG)
```

## Step 6 — Output the Updated PARM

Produce a ready-to-paste JCL PARM snippet showing the before and after,
with a comment for each change explaining the reason.

## Step 7 — Flag JCL Region Requirements

Remind the user to add `REGION=0M` and verify `MEMLIMIT>=2G` on the compile
step — EC 6.5 uses storage above the 2GB bar during compilation.
Reference: `Cobol-Skills/skill-compiler-options.md` §"REGION and MEMLIMIT".
