---
name: cobol-modernization-code
description: >-
  Use when the user wants a full migration assessment, impact analysis, or
  modernization roadmap for a COBOL II program or application moving to
  Enterprise COBOL 6.5 — or when they say "analyze this COBOL program for
  migration", "what needs to change to compile with EC 6.5", "give me a
  migration checklist", or "assess this program for modernization".
---

# Skill: Full Modernization Assessment — COBOL II to Enterprise COBOL 6.5

This is the entry-point skill. It orchestrates the other cobol-* skills
to produce a complete migration impact report for a program or application.

## Step 1 — Gather Input

Use `ask_followup_question` if the user has not provided:
1. The COBOL source program (or key sections)
2. The compile JCL or PROC
3. Whether the program uses CICS, DB2, both, or neither

## Step 2 — Classify the Program

Assign a migration complexity rating based on attributes present:

| Rating | Criteria |
|---|---|
| **Simple** | No CICS, no DB2, no CMPR2, no deprecated verbs | Recompile with updated PARM |
| **Medium** | CICS or DB2 (not both), CMPR2 in use, obsolete JCL options | Targeted fixes in 2–4 areas |
| **Complex** | CICS + DB2, IGZERRE/IGZETUN calls, VALUE in OCCURS, STOP RUN, HANDLE CONDITION | Full review + test cycle |

## Step 3 — Scan for Findings by Category

Analyze the source and JCL, grouping findings into six categories.
For each finding, record: **line**, **construct**, **action**, **risk**.

### Category 1 — Language Changes
Invoke skill `cobol-lang-changes` logic. Look for:
- `ALTER`, `STOP literal`, `ACCEPT DATE/TIME`
- `VALUE` on subordinates of `OCCURS`
- `MOVE 'Y'/'N' TO sw` instead of `SET condition-name`
- Reserved word conflicts (`JSON`, `FREE`, `ALLOCATE`, `DYNAMIC`, etc.)

### Category 2 — Compiler Options
Invoke skill `cobol-compiler-options` logic. Look for:
- `RES`, `RESIDENT`, `CMPR2`, `SIZE` in PARM — must remove
- Missing `CICS`, `SQL`, `OPT(FULL)`, `ARCH`, `TUNE`

### Category 3 — Language Environment
Invoke skill `cobol-le-migration` logic. Look for:
- `CALL 'IGZERRE'`, `CALL 'IGZETUN'`, `CALL 'IGZCLOC'`
- `RTEREUS`, `LIBKEEP`, `STAE` runtime options
- `COB2.SCOB2LKE` in STEPLIB

### Category 4 — CICS Adaptations
Invoke skill `cobol-cics-migration` logic. Look for:
- `DFHECP1$` step in JCL
- `STOP RUN` in Procedure Division
- `EXEC CICS HANDLE CONDITION`
- `EXEC CICS ABEND` without `RESP`

### Category 5 — DB2 Adaptations
Invoke skill `cobol-db2-migration` logic. Look for:
- `DSNHPC` step in JCL
- `DECLARE CURSOR` in Procedure Division
- Missing `DBRM DD` in compile step

### Category 6 — JCL / Procedures
Invoke skill `cobol-jcl-migration` logic. Look for:
- Multi-step pre-processing (DSNHPC + DFHECP1$ + COBCOMP)
- Missing `REGION=0M`
- `CEE.SCEERUN` not in link-edit SYSLIB

## Step 4 — Produce the Migration Checklist

Output a Markdown checklist grouped by category. Use this format:

```
## Migration Checklist — <PROGRAM-NAME>
### Complexity: Simple / Medium / Complex

#### Language Changes
- [ ] Description — Action — Risk

#### Compiler Options
- [ ] Description — Action — Risk
...
```

Mark items as:
- 🔴 **Mandatory** — compile error or wrong runtime behavior without this fix
- 🟡 **Recommended** — deprecated or suboptimal; compiles but should change
- 🟢 **Compatible** — works as-is; no action required

## Step 5 — Functional Equivalence Statement

For each 🔴 mandatory item, state explicitly whether functional equivalence
is guaranteed after the fix, or whether regression testing is required.

## Step 6 — Corrected Code Snippets

For each 🔴 mandatory finding, produce a before/after code block with
inline comments marking the change (e.g., `*>> C1: reason`).

## Step 7 — Updated JCL

Produce the full corrected compile step (COBCOMP) and link-edit step (LNKPGM)
showing all changes with annotations. Reference the procedure template in
`Cobol-Skills/skill-jcl-procedures.md` §"Procedure EC 6.5 (depois)".
