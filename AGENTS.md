# AGENTS.md

This file provides guidance to agents when working with code in this repository.

## Workspace Type
**Application platform: IBM Z**
**Detected Languages:** VS COBOL II (source), Enterprise COBOL 6.5 (migration target), JCL, BMS (CICS map assembly)

## Repository Purpose
This is a **COBOL II → Enterprise COBOL 6.5 migration** demonstration workspace. It contains:
- A sample CICS+DB2 banking program (`Source-Code/`) written in VS COBOL II
- Its migrated EC 6.5 counterpart (`Source-Code-Refactor/`)
- A custom Bob mode and skill suite for guiding migrations (`Cobol-Skills/`)
- IBM reference guides in PDF and Markdown (`IBM-Guides/`, `IBM-Guides-Markdown/`)
- A `docling-main/` Python library (unrelated to COBOL — used to convert PDFs to Markdown)

## Directory Structure (non-obvious)
- `Cobol-Mode/zCobol-Modernization.yaml` — standalone copy for installation; `Cobol-Skills/zCobol-Modernization.yaml` is the in-workspace version (same content, two locations)
- `Cobol-Skills/bobz-skills/` — deployable skill packages (each `SKILL.md` is the published version); the flat `Cobol-Skills/skill-*.md` files are the reference/source documents
- `IBM-Guides-Markdown/` — preferred knowledge base for skills (Markdown processes better than PDF for LLMs); `IBM-Guides/` has the original PDFs
- `Source-Code/src/BKC01.cbl` — intentionally contains migration defects for demonstration
- `Source-Code-Refactor/BKC01V65.cbl` — corrected EC 6.5 version; all changes annotated with `*>>` prefix
- `zapp.yaml` — IBM Z Open Editor property groups (default wildcard; not tuned for specific datasets)

## COBOL Code Style (from source and standards)
- **Column structure:** Code in columns 7–72; sequence numbers optional in 73–80
- **Paragraph naming:** `NNN-PARAGRAPH-NAME` / `NNN-EXIT` pattern (e.g., `100-INITIALIZE`, `100-EXIT`)
- **Perform pattern:** Always `PERFORM nnn-PARA THRU nnn-EXIT` — every paragraph terminates with a matching `-EXIT` paragraph containing only `EXIT.`
- **Working-Storage prefix:** Group names prefixed with program ID (e.g., `WSBK-` for `BKC01`)
- **Switch fields:** 88-level condition names on PIC X(1) fields; use `SET condition-name TO TRUE` (not `MOVE 'Y'`)
- **CICS error handling:** Every `EXEC CICS` command must have `RESP(field)` and check result via 88-level; no `HANDLE CONDITION`
- **DB2 cursor declaration:** Must be in **Working-Storage Section**, not Procedure Division (EC 6.5 integrated coprocessor requirement)
- **Numeric types:** Prefer `BINARY` / `COMP-4` over `COMP` for clarity; `COMP-3` for packed decimal

## JCL Code Style
- Record length: 71 characters; continuation at column 16 with leading `//` and spaces
- EC 6.5 compile step: single `COBCOMP` with `REGION=0M` (mandatory), `CICS('COBOL2')`, and `SQL` options — replaces the 6-step chain (DSNHPC + DFHECP1$ are eliminated)
- `DBRM DD` statement must be on the `COBCOMP` step, not on `DSNHPC` (which no longer exists)
- `SYSIN` on `COBCOMP` points directly to the source dataset — not to `&&CICSOUT` temp dataset

## Technical Documentation Mapping

| Program | Source | Refactored | Technical Doc | Modernization Guide | Migration Diff |
|---------|--------|------------|---------------|---------------------|----------------|
| BKC01 | `Source-Code/src/BKC01.cbl` | `Source-Code-Refactor/BKC01V65.cbl` | `Source-Code/docs/BKC01-DOCUMENTATION.md` | `Source-Code/docs/BKC01-MODERNIZATION.md` | `Source-Code-Refactor/BKC01-MIGRATION.md` |

**Auto-update rule:** When `BKC01.cbl` or `BKC01V65.cbl` is modified, check and update all three documentation files for accuracy.

## Migration Skills (Cobol-Skills/)
The mode `zCobol-Modernization` grounds answers in four primary skill documents:
1. `Cobol-Skills/skill-perf-tuning.md` — VS COBOL II performance tuning
2. `Cobol-Skills/skill-migration-v65.md` — COBOL II → EC 6.5 migration guide
3. `Cobol-Skills/skill-le-runtime.md` — Language Environment runtime programming
4. `Cobol-Skills/skill-cics-standards.md` — CICS COBOL II structured programming standards

Additional specialized skills (each with a `bobz-skills/<name>/SKILL.md`):
- `cobol-modernization-code` — orchestration skill for full migration assessment
- `cobol-cics-migration`, `cobol-db2-migration`, `cobol-jcl-migration`
- `cobol-compiler-options`, `cobol-lang-changes`, `cobol-le-migration`, `cobol-perf-tuning`

## Critical Migration Rules (non-obvious gotchas)
- `VALUE` on subordinates of `OCCURS` causes **IKF2066S** compile error in EC 6.5 without `CMPR2` — move to `INITIALIZE` in Procedure Division
- `STOP RUN` in a CICS program under LE terminates the LE enclave — causes `S0C4`; remove entirely
- `DECLARE CURSOR` must be in Working-Storage when using the integrated DB2 coprocessor (`SQL` option); Procedure Division placement is a COBOL II pre-compiler pattern only
- `RES`/`NORES` compiler option does not exist in EC 5+; remove from PARM or get compile error
- `EXEC CICS ABEND` without `RESP` generates a warning in EC 6.5; always add `RESP`
- Migration annotation convention: inline COBOL comments marking changes use `*>>` prefix with `Cn` (mandatory) or `Rn` (recommended), e.g. `*>> C4 - reason`
- Business case data: `IBM-Guides-Markdown/migration-cost-measurement-checklist.md` has ROI formulas and CPU reduction benchmarks

## File Editing Scope
The mode `zCobol-Modernization` restricts edits via `fileRegex` to `*.cbl`, `*.cob`, `*.cpy`, `*.jcl`, `*.md`, `*.txt` only (from `Cobol-Skills/zCobol-Modernization.yaml`).

## Docling (docling-main/)
Unrelated Python PDF-to-Markdown converter (uses `uv`). Do not modify during COBOL migration tasks.
