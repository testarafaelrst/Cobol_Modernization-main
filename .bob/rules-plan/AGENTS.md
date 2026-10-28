# AGENTS.md

This file provides guidance to agents when working with code in this repository.

## Non-Obvious Architectural Constraints

### Migration Architecture
- The workspace demonstrates a **demo migration**, not a production application — the single program `BKC01` is the complete scope
- The COBOL II → EC 6.5 migration is a **one-pass, forward-only** process — no rollback path
- Functional equivalence is NOT automatically guaranteed for the three mandatory fixes (STOP RUN, VALUE in OCCURS, DECLARE CURSOR position); regression testing is explicitly required for those

### Compilation Architecture Change (COBOL II vs EC 6.5)
- COBOL II required a 6-step JCL chain: ASMA90 (BMS) → IEWL (BMS link) → DSNHPC (DB2 pre-compile) → DFHECP1$ (CICS translate) → IGYCRCTL (compile) → IEWL (link)
- EC 6.5 collapses to 4 steps: ASMA90 → IEWL → IGYCRCTL (with integrated CICS+DB2) → IEWL
- The `DBRM DD` statement migrates from the DSNHPC step to the COBCOMP step — easy to miss when updating JCL

### Skill Orchestration (cobol-modernization-code)
- The `cobol-modernization-code` skill is an **orchestration** skill — it calls the logic of all other cobol-* skills internally (not via `use_skill`); do not expect separate skill activations per category
- Migration findings are categorized into exactly 6 buckets: Language Changes, Compiler Options, Language Environment, CICS Adaptations, DB2 Adaptations, JCL/Procedures

### CICS Pseudo-Conversational Pattern
- BKC01 uses EXEC CICS RETURN with TRANSID — every key press triggers a full program re-entry; no conversational state persists except in COMMAREA
- EIBCALEN = 0 means first invocation (no COMMAREA); any other value means re-entry — this is how the first-time flag is set (not a WS field default)

### DB2 Integration Constraint
- When using the integrated DB2 coprocessor, cursor `DECLARE` statements must appear in Working-Storage because the coprocessor processes declarations during compile, not at runtime — placing them in Procedure Division was a precompiler-era workaround

### ROI Planning Reference
- `IBM-Guides-Markdown/migration-cost-measurement-checklist.md` contains structured ROI formulas; typical CPU reduction with `OPT(FULL)` + `ARCH` + `TUNE` is 10–25%; with `TRUNC(OPT)` on arithmetic-heavy programs up to 40%
- Migration effort estimates: Simple ~2–4h, Medium ~8–16h, Complex ~24–40h per program
