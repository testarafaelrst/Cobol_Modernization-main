---
name: cobol-lang-changes
description: >-
  Use when the user asks about COBOL II language constructs that need to change
  for Enterprise COBOL 6.5 — such as ALTER, ACCEPT DATE, STOP literal, VALUE in
  OCCURS, reserved word conflicts, SET condition-name, EVALUATE, JSON GENERATE,
  ALLOCATE, or any syntax incompatibility between COBOL II and EC 6.5.
---

# Skill: COBOL Language Changes — COBOL II to Enterprise COBOL 6.5

Follow these steps whenever the user asks about language-level incompatibilities,
deprecated constructs, or new EC 6.5 syntax to adopt.

## Step 1 — Identify the Construct

Read the program or snippet provided. Look for these COBOL II patterns:

- `ALTER` statement
- `ACCEPT DATE` / `ACCEPT TIME` / `ACCEPT DAY`
- `STOP 'literal'`
- `VALUE` on items subordinate to `OCCURS`
- `MOVE 'Y'/'N' TO flag-sw` instead of `SET condition-name TO TRUE`
- `HANDLE CONDITION` (CICS)
- Data-names that collide with EC 6.5 reserved words: `JSON`, `UTF-8`,
  `DYNAMIC`, `FUNCTION`, `FREE`, `ALLOCATE`, `VOLATILE`, `CONVERT`

If the user provides no code, ask them to paste the relevant paragraph or
Working-Storage entry using `ask_followup_question`.

## Step 2 — Map Each Finding to Its Fix

For every finding, apply the table below. Produce one annotated block per item
showing the original COBOL II line (marked `* COBOL II`) and the EC 6.5
replacement (marked `* EC 6.5`).

| COBOL II Construct | EC 6.5 Replacement | Notes |
|---|---|---|
| `ALTER p1 TO p2` | Eliminate — restructure with `EVALUATE` | Not supported in NOCMPR2 |
| `ACCEPT DATE` | `FUNCTION CURRENT-DATE` or `EXEC CICS ASKTIME` | 8 vs 21 chars |
| `ACCEPT TIME` | `FUNCTION CURRENT-DATE(9:8)` | — |
| `STOP 'msg'` | `DISPLAY 'msg'` + `STOP RUN` | Compile error in EC 6.5 |
| `VALUE` on `OCCURS` subordinate | Remove `VALUE`; add `INITIALIZE` in Procedure Division | IKF2066S in NOCMPR2 |
| `MOVE 'Y' TO sw` | `SET condition-name TO TRUE` | ANSI 85 idiom |
| Reserved word conflict | Rename the data-name with a program-specific prefix | Use `FLAGMIG` to scan |

Reference document for each fix: `Cobol-Skills/skill-lang-changes.md`.

## Step 3 — Check for New EC 6.5 Features Worth Adopting

After fixing incompatibilities, suggest relevant new constructs:

- `EVALUATE TRUE` replacing nested `IF`
- `JSON GENERATE / JSON PARSE` (EC 6.1/6.2) for REST integration
- `ALLOCATE / FREE` (EC 6.1) replacing `GETMAIN`
- `FUNCTION CURRENT-DATE` replacing all date/time `ACCEPT` variants
- `EXIT PERFORM / EXIT PARAGRAPH / EXIT SECTION` (EC 5.2) replacing `GO TO`

## Step 4 — Flag Functional Equivalence Risks

For each change, state explicitly whether functional equivalence is guaranteed:

- `VALUE` in `OCCURS` → **Not guaranteed** — compile fails; must test after adding `INITIALIZE`
- `ACCEPT DATE` → **Not guaranteed** — format changes from YYMMDD to YYYYMMDD; fix field length
- `ALTER` → **Not guaranteed** — requires logic restructuring; manual test mandatory
- All others → Guaranteed if replacement is applied exactly as shown

## Step 5 — Produce a Summary Table

Output a Markdown table with columns: **Line**, **Construct**, **Action**, **Risk**.
