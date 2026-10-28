# AGENTS.md

This file provides guidance to agents when working with code in this repository.

## Non-Obvious Coding Rules for this Workspace

### COBOL Source Edits
- Always preserve columns 7–72 for COBOL code; never write past column 72 (causes IEW truncation silently)
- Every paragraph MUST have a matching `-EXIT` paragraph with only `EXIT.` — PERFORM…THRU breaks if missing
- DB2 `DECLARE CURSOR` belongs in Working-Storage, never Procedure Division (EC 6.5 integrated coprocessor)
- `VALUE` on items subordinate to `OCCURS` is a compile error in EC 6.5 without `CMPR2` — use `INITIALIZE` instead
- Use `SET condition-name TO TRUE` — not `MOVE 'Y' TO flag` — the existing code has inconsistencies; follow the standard
- Migration annotation format for changed lines: `*>> Cn - reason` (mandatory/required) or `*>> Rn - reason` (recommended)

### JCL Edits
- JCL records truncate at column 71 — continuation starts at column 16 with `//` + spaces + keyword
- EC 6.5 compile step: single `COBCOMP` step with `REGION=0M`, `CICS('COBOL2')`, and `SQL` options replaces the three-step DSNHPC + DFHECP1$ + IGYCRCTL chain
- `DBRM DD` statement must be on the `COBCOMP` step (not on DSNHPC which no longer exists)
- `SYSIN` on `COBCOMP` points directly to the source dataset — not to `&&CICSOUT` temp dataset

### File Editing Scope
- The mode `zCobol-Modernization` restricts edits to `*.cbl`, `*.cob`, `*.cpy`, `*.jcl`, `*.md`, `*.txt` only (from `zCobol-Modernization.yaml` `fileRegex`)
- `docling-main/` is an unrelated Python library; do not edit it during COBOL migration tasks

### Skill Documents (canonical references — always cite section)
- `Cobol-Skills/skill-migration-v65.md` — language changes, compiler options, DB2/CICS integration
- `Cobol-Skills/skill-cics-standards.md` — CICS structured programming, BMS, error handling patterns
- `Cobol-Skills/skill-perf-tuning.md` — OPT(FULL), ARCH, TUNE, TRUNC(OPT) guidance
- `Cobol-Skills/skill-le-runtime.md` — LE runtime calls replacing IGZERRE/IGZETUN

### Using update_todo_list
The mode custom instructions explicitly require `update_todo_list` for multi-step migration work — use it.
