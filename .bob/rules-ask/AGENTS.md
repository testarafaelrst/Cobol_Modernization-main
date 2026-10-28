# AGENTS.md

This file provides guidance to agents when working with code in this repository.

## Non-Obvious Documentation Context

### Where Things Actually Are
- The flat `Cobol-Skills/skill-*.md` files are **reference/source** versions of the skills
- `Cobol-Skills/bobz-skills/<name>/SKILL.md` are the **published/deployed** versions — these are what Bob loads via `use_skill`
- IBM guide PDFs are in `IBM-Guides/`; their Markdown conversions are in `IBM-Guides-Markdown/` (4 files, not all guides converted)
- `IBM-Guides-Markdown/migration-cost-measurement-checklist.md` is a custom document (not a converted IBM PDF) — it contains ROI formulas and CPU reduction benchmarks

### BKC01 Program Context
- `Source-Code/src/BKC01.cbl` is **intentionally defective** (written in COBOL II with known migration issues) — treat it as the "before" state
- `Source-Code-Refactor/BKC01V65.cbl` is the corrected "after" state; changes annotated with `*>>` inline comments
- `Source-Code-Refactor/BKC01-MIGRATION.md` is the authoritative statement-by-statement mapping with 🔴/🟡/🟢 severity ratings
- `Source-Code/docs/BKC01-DOCUMENTATION.md` is the full technical reference (BMS layout, WS fields, DB2 tables, CICS commands, JCL analysis)

### Misleading Structure
- `zapp.yaml` uses `"**"` wildcard locations — it is a default generated file, not a tuned configuration
- `docling-main/` appears to be part of the COBOL workspace but is a standalone open-source Python PDF-to-Markdown tool used to generate the `IBM-Guides-Markdown/` files

### Migration Complexity Ratings (from cobol-modernization-code skill)
- Simple: no CICS, no DB2, no deprecated verbs → recompile only
- Medium: CICS or DB2 (not both) → 2–4 targeted fix areas
- Complex: CICS + DB2, STOP RUN, VALUE in OCCURS, HANDLE CONDITION → full review + test cycle
- BKC01 is rated **Complex** (CICS + DB2 + all three dangerous patterns present)
