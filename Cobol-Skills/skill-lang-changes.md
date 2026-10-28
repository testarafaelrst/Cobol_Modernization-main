# Skill: Language Changes — COBOL II to Enterprise COBOL 6.5

> Source: `skill-migration-v65.md` Ch.11, 13, 19, 20 and Appendix B (Reserved Word Comparison)

---

## 1. Removed or Incompatible Constructs

### 1.1 `ALTER` Statement
**COBOL II:** Changed the destination of `GO TO` at runtime — considered an obsolete practice.
**Enterprise COBOL 6.5:** **Not supported** in `NOCMPR2`. Causes `IKF2xxx-E`.

```cobol
* COBOL II (prohibited)
ALTER 100-GO TO PROCEED TO 200-PROCESS.

* Enterprise COBOL 6.5
* Eliminate completely. Restructure logic with EVALUATE or IF.
```

---

### 1.2 `ACCEPT DATE` / `ACCEPT TIME` / `ACCEPT DAY`
**COBOL II:** Used the special registers `DATE`, `TIME`, `DAY` via `ACCEPT`.
**Enterprise COBOL 6.5:** Still compiles, but precision is limited. Prefer `FUNCTION CURRENT-DATE` or `EXEC CICS ASKTIME` in CICS programs.

```cobol
* COBOL II
ACCEPT WS-DATA FROM DATE.   *> returns YYMMDD

* Enterprise COBOL 6.5 — Option 1: intrinsic function
MOVE FUNCTION CURRENT-DATE  TO WS-TIMESTAMP.
*   returns 21 chars: YYYYMMDDHHmmssxx±HHmm

* Enterprise COBOL 6.5 — Option 2: in CICS
EXEC CICS ASKTIME ABSTIME(WS-ABSTIME) END-EXEC
EXEC CICS FORMATTIME ABSTIME(WS-ABSTIME) YYYYMMDD(WS-DATA) END-EXEC
```

> **Ref:** `skill-migration-v65.md` §Ch.11 "ACCEPT statement" /
> `skill-cics-standards.md` §"Date and Time"

---

### 1.3 `STOP literal`
**COBOL II:** `STOP 'message'` displayed a message on the console and waited for the operator.
**Enterprise COBOL 6.5:** **Not supported**. Causes a compilation error.

```cobol
* COBOL II
STOP 'WAITING FOR OPERATOR CONFIRMATION'.

* Enterprise COBOL 6.5
DISPLAY 'WAITING FOR OPERATOR CONFIRMATION'
STOP RUN.
```

---

### 1.4 `VALUE` in subordinates of `OCCURS`
**COBOL II with CMPR2:** Allowed `VALUE` in items subordinate to `OCCURS`.
**Enterprise COBOL 6.5 with NOCMPR2:** Causes **IKF2066S** — fatal compilation error.

```cobol
* COBOL II (CMPR2) — incompatible
01  WSBK-TABLE.
    12  WSBK-ENTRY OCCURS 5 TIMES.
        16  WSBK-VALUE  PIC 9(5) VALUE ZERO.   *> ERROR in NOCMPR2

* Enterprise COBOL 6.5 — Fix
01  WSBK-TABLE.
    12  WSBK-ENTRY OCCURS 5 TIMES.
        16  WSBK-VALUE  PIC 9(5).              *> no VALUE

* Initialize in the Procedure Division:
INITIALIZE WSBK-TABLE.
```

> **Ref:** `skill-migration-v65.md` §Ch.11 "85 COBOL Standard interpretation changes" / Table 26

---

### 1.5 New Reserved Words
Enterprise COBOL 6.5 added several reserved words that may
conflict with variable or paragraph names in COBOL II programs.
Check the complete list in `skill-migration-v65.md` Appendix B.

**High-risk conflict words (examples):**

| New Reserved Word | Version Introduced |
|---|---|
| `JSON` | EC 6.1 |
| `UTF-8` | EC 6.3 |
| `DYNAMIC` | EC 6.3 |
| `FUNCTION` | EC 4.x |
| `FREE` | EC 6.1 |
| `ALLOCATE` | EC 6.1 |
| `VOLATILE` | EC 5.2 |
| `CONVERT` | EC 6.3 |

**Action:** Use the compiler with the `FLAGMIG` option to identify conflicts
before migration. If a variable name conflicts, prefix it with the program
name or use a descriptive synonym.

---

## 2. Behavior Changes in NOCMPR2

The `CMPR2` option generated code compatible with COBOL II Release 2 (ANSI 1974).
In Enterprise COBOL 6.5 with `NOCMPR2` (default), ANSI 1985 and 2002 semantics apply.
The main differences are documented in `skill-migration-v65.md` Table 26 — the most critical are:

| Area | CMPR2 Behavior | NOCMPR2 Behavior |
|---|---|---|
| `MOVE CORRESPONDING` | Moves only items with the same name at level 01 | Recursively moves all matching levels |
| `INSPECT REPLACING` | Does not replace positions already replaced | May replace already-processed positions |
| `STRING/UNSTRING` overflow | Silent | Raises `OVERFLOW` condition |
| `PERFORM VARYING` with `UNTIL` | Tests condition *before* the first iteration | Same — but differences in indexed variables |
| Scope of `IF` without `END-IF` | Ambiguity with period | `END-IF` required for clarity |
| DISPLAY numeric comparison | Sign fix-up on every access | Controlled by `INVDATA` / `NUMCHECK` |

**Strategy:** Compile with `CMPR2` first to confirm the program works,
then migrate to `NOCMPR2` item by item, using `FLAGMIG` to
identify constructs to convert.

---

## 3. New Recommended Language Features

### 3.1 `EVALUATE` — replaces IF-ELSEIF-GO TO
```cobol
* Old COBOL II pattern
IF EIBAID = DFHPF3
    ...
ELSE
    IF EIBAID = DFHENTER
        ...
    ELSE
        ...

* Enterprise COBOL 6.5 — recommended pattern
EVALUATE TRUE
    WHEN EIBAID = DFHPF3
        PERFORM 700-EXIT THRU 700-EXIT
    WHEN EIBAID = DFHENTER
        PERFORM 400-QUERY THRU 400-EXIT
    WHEN OTHER
        MOVE 'INVALID KEY' TO WS-MSG
END-EVALUATE
```

---

### 3.2 `FUNCTION CURRENT-DATE` — replaces ACCEPT DATE/TIME
```cobol
01  WS-TIMESTAMP.
    12  WS-YYYY     PIC X(4).
    12  WS-MM       PIC X(2).
    12  WS-DD       PIC X(2).
    12  FILLER      PIC X(13).

MOVE FUNCTION CURRENT-DATE  TO WS-TIMESTAMP.
```

---

### 3.3 `SET condition-name TO TRUE` — replaces `MOVE 'Y'/'N'`
```cobol
* COBOL II — direct to variable
MOVE 'Y' TO WS-EDIT-ERROR-SW.

* Enterprise COBOL 6.5 — correct ANSI 85 idiom
SET  WS-EDIT-ERROR  TO TRUE.   *> where 88 WS-EDIT-ERROR VALUE 'Y'
SET  WS-NO-EDIT-ERROR TO TRUE. *> where 88 WS-NO-EDIT-ERROR VALUE 'N'
```

---

### 3.4 `JSON GENERATE / JSON PARSE` — new capability 6.1/6.2
```cobol
01  WS-ACCOUNT-JSON   PIC X(500).
01  WS-JSON-LEN       PIC S9(9) BINARY VALUE ZERO.

JSON GENERATE WS-ACCOUNT-JSON FROM DCLACCOUNT
    COUNT WS-JSON-LEN
    ON EXCEPTION
        DISPLAY 'JSON ERROR: ' JSON-CODE
END-JSON
```

---

### 3.5 `ALLOCATE / FREE` — dynamic storage management (6.1)
```cobol
01  WS-PTR USAGE POINTER.

ALLOCATE 4096 CHARACTERS INITIALIZED RETURNING WS-PTR
FREE WS-PTR
```

---

## 4. Statement Equivalence — Quick Reference Table

| COBOL II | Enterprise COBOL 6.5 | Notes |
|---|---|---|
| `ACCEPT DATE` | `FUNCTION CURRENT-DATE` | 8 vs 21 chars |
| `ACCEPT TIME` | `FUNCTION CURRENT-DATE(9:8)` | Subfield |
| `STOP 'msg'` | `DISPLAY 'msg' STOP RUN` | — |
| `ALTER p1 TO PROCEED TO p2` | Restructure with EVALUATE | Eliminate |
| `MOVE 'Y' TO flag-sw` | `SET condition-name TO TRUE` | ANSI 85 |
| `CALL 'IGZERRE'` | `CALL 'CEEPIPI'` | See skill-le-migration |
| `IF A = B` (without `END-IF`) | `IF A = B ... END-IF` | Required |
| `PERFORM p1 THRU p2` | `PERFORM p1 THRU p2` | No change |
| `EXEC CICS HANDLE CONDITION` | Check `RESP` after each command | See skill-cics-migration |
