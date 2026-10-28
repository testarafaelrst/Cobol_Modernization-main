# 🔄 zCOBOL Modernization — Mode & Skills for IBM Bob

> Complete installation and usage guide for the **COBOL II → Enterprise COBOL 6.5**  
> specialist Mode and Skills on IBM Bob.

---

## Table of Contents

1. [Overview](#1-overview)
2. [Repository Structure](#2-repository-structure)
3. [Prerequisites](#3-prerequisites)
4. [Installing the Mode](#4-installing-the-mode)
5. [Installing the Skills](#5-installing-the-skills)
6. [Available Skills](#6-available-skills)
7. [How to Use](#7-how-to-use)
8. [Reference Resources](#8-reference-resources)
9. [Usage Examples](#9-usage-examples)

---

## 1. Overview

This package delivers to IBM Bob a **specialist Mode** and **8 specialized Skills** to guide the migration of COBOL II (VS COBOL II) programs to Enterprise COBOL 6.5 on z/OS.

### What you get

| Component | Count | Purpose |
|---|---|---|
| Custom Mode | 1 | COBOL modernization specialist persona |
| Specialized Skills | 8 | Modular coverage of each migration area |
| IBM Guides in Markdown | 4 | Curated technical knowledge base |
| Sample programs | 1 (COBOL II) + 1 (EC 6.5) | Test validation and migration reference |

### Technical coverage

The Mode and Skills cover the following migration areas:

- **Language changes** — obsolete verbs, reserved word conflicts, deprecated constructs
- **Compiler options** — removing `RES`/`CMPR2`, adding `OPT(FULL)`, `ARCH`, `TUNE`
- **Language Environment (LE)** — replacing `IGZERRE`, `IGZETUN`, `COB2.SCOB2LKE`
- **CICS adaptations** — removing `DFHECP1$`, `STOP RUN`, `HANDLE CONDITION`
- **DB2 adaptations** — removing `DSNHPC`, relocating `DECLARE CURSOR`
- **JCL migration** — consolidating the compile process from 6 steps to 4 steps
- **Performance** — `TRUNC(OPT)`, `SMARTBIN`, data type tuning, table access
- **Full assessment** — impact report with checklist and corrected code snippets

---

## 2. Repository Structure

```
Cobol_Modernization/
│
├── Cobol-Mode/                          ← Mode definition (ready to install)
│   └── zCobol-Modernization.yaml        ← Mode YAML — paste this into Bob
│
├── Cobol-Skills/                        ← Skill reference documents
│   ├── skill-migration-v65.md           ← COBOL II → EC 6.5 migration guide
│   ├── skill-perf-tuning.md             ← VS COBOL II performance tuning
│   ├── skill-le-runtime.md              ← Language Environment runtime
│   ├── skill-cics-standards.md          ← CICS COBOL II coding standards
│   ├── skill-cics-migration.md          ← CICS migration reference
│   ├── skill-compiler-options.md        ← Compiler options reference
│   ├── skill-db2-migration.md           ← DB2 migration reference
│   ├── skill-jcl-procedures.md          ← JCL procedures reference
│   ├── skill-lang-changes.md            ← Language changes reference
│   ├── skill-le-migration.md            ← LE migration reference
│   ├── skill-perf-modernization.md      ← EC 6.5 performance reference
│   └── bobz-skills/                     ← Skills in Bob format (ready to install)
│       ├── cobol-modernization-code/    ← Full assessment skill
│       ├── cobol-cics-migration/        ← CICS skill
│       ├── cobol-db2-migration/         ← DB2 skill
│       ├── cobol-compiler-options/      ← Compiler options skill
│       ├── cobol-jcl-migration/         ← JCL skill
│       ├── cobol-lang-changes/          ← Language changes skill
│       ├── cobol-le-migration/          ← Language Environment skill
│       └── cobol-perf-tuning/           ← Performance skill
│
├── IBM-Guides/                          ← Original IBM manuals (PDF)
│   ├── Enterprise-COBOL-for-zOS-Programming-Guide-v65.pdf
│   ├── COBOL-Language-Environment-Migration-Guide-v65.pdf
│   └── ... (all versions)
│
├── IBM-Guides-Markdown/                 ← IBM guides converted to Markdown
│   ├── Enterprise-COBOL-for-zOS-Programming-Guide-v65.md
│   ├── COBOL-Language-Environment-Migration-Guide-v65.md
│   ├── COBOL-II-Performance-Tuning.md
│   ├── Structured-CICS-COBOLII-Programming-Standards.md
│   └── migration-cost-measurement-checklist.md
│
├── Source-Code/                         ← Sample program (original COBOL II)
│   ├── src/BKC01.cbl                    ← COBOL II source with known migration issues
│   ├── copybooks/                       ← DCLGENs and copybooks
│   ├── jcl/BKJCL01J.jcl               ← COBOL II compile JCL
│   ├── maps/BKCONS0.bms                ← BMS mapset
│   └── docs/BKC01-DOCUMENTATION.md     ← Technical documentation
│
└── Source-Code-Refactor/                ← Migration result for EC 6.5
    ├── BKC01V65.cbl                     ← Corrected source (EC 6.5)
    └── BKC01-MIGRATION.md               ← Statement-by-statement migration mapping
```

> **About the Markdown guides:** The files in `IBM-Guides-Markdown/` are converted versions of the original IBM manuals in Markdown format. This conversion optimizes reading and processing by Bob — language models perform significantly better when processing Markdown documentation compared to PDFs. These files are the technical knowledge base used by all skills.

---

## 3. Prerequisites

Before installing, confirm:

- **IBM Bob** is installed and running on your machine
- Access to the Bob interface (chat or VS Code)
- The files from this repository copied or cloned locally

No prior knowledge of Bob Mode or Skill creation is required — this guide covers everything from scratch.

---

## 4. Installing the Mode

### What is a Mode?

A **Mode** in Bob is a specialist persona with instructions, permissions, and behavior configured for a specific task. The `zCOBOL Modernization` Mode turns Bob into a COBOL II → EC 6.5 migration expert.

### Step-by-step: creating the Mode with `create-mode`

Bob has a built-in skill called `create-mode` that guides the creation of custom modes. Follow the steps below.

#### Step 1 — Open Bob and activate the `create-mode` skill

In the Bob chat, type:

```
Use the create-mode skill to help me create a new custom mode
```

Bob will prompt you for the information needed to build the Mode.

#### Step 2 — Paste the full YAML content

When Bob asks for the configuration, paste the complete content of the file [`Cobol-Mode/zCobol-Modernization.yaml`](Cobol-Mode/zCobol-Modernization.yaml):

```
Use the create-mode skill. Here is the full mode definition in YAML format:

[paste the contents of Cobol-Mode/zCobol-Modernization.yaml here]
```

The file already contains all required fields. For reference:

| Field | Value |
|---|---|
| **Slug (ID)** | `zCobol-Modernization` |
| **Display name** | `🔄 zCOBOL Modernization` |
| **Description** | Specialist in migrating COBOL II programs to Enterprise COBOL 6.5 on z/OS |
| **Permission groups** | `read`, `edit` (restricted to `.cbl`, `.cob`, `.cpy`, `.jcl`, `.md`, `.txt`), `execute`, `todo` |

#### Step 3 — Confirm the installation

After creation, the Mode will appear in Bob's available modes list. To verify, open the mode selector in the chat and confirm that `🔄 zCOBOL Modernization` is listed.

> **Important:** The Mode references skill documents at the relative path `Cobol-Skills/`. Make sure the workspace open in Bob points to the root folder of this repository — otherwise the reference skill documents will not be found.

---

## 5. Installing the Skills

### What is a Skill?

A **Skill** in Bob is a set of specialized instructions that Bob loads on demand to solve a specific type of problem. Skills are activated automatically by Bob when it recognizes that the question context matches the skill's description.

### Where are the Skills?

The ready-to-install skills are in the `Cobol-Skills/bobz-skills/` folder. Each subfolder contains a `SKILL.md` file with a YAML frontmatter that defines the skill's name, description, and instructions.

### Step-by-step: creating each Skill with `create-skill`

Bob has a built-in skill called `create-skill` that guides the creation of custom skills. Repeat the process below for each of the 8 skills.

#### Step 1 — Activate the `create-skill` skill

In the Bob chat (any mode), type:

```
Use the create-skill skill to help me create a new skill
```

#### Step 2 — Provide the SKILL.md content

When Bob asks for the information, paste the content of the corresponding `SKILL.md` file:

```
Here is the complete SKILL.md content for the skill I want to create:

[paste the contents of the desired SKILL.md here]
```

#### Step 3 — Repeat for each skill

Install all 8 skills in the following recommended order (most general to most specific):

| Order | Skill | SKILL.md File |
|---|---|---|
| 1 | `cobol-modernization-code` | `Cobol-Skills/bobz-skills/cobol-modernization-code/SKILL.md` |
| 2 | `cobol-lang-changes` | `Cobol-Skills/bobz-skills/cobol-lang-changes/SKILL.md` |
| 3 | `cobol-compiler-options` | `Cobol-Skills/bobz-skills/cobol-compiler-options/SKILL.md` |
| 4 | `cobol-le-migration` | `Cobol-Skills/bobz-skills/cobol-le-migration/SKILL.md` |
| 5 | `cobol-cics-migration` | `Cobol-Skills/bobz-skills/cobol-cics-migration/SKILL.md` |
| 6 | `cobol-db2-migration` | `Cobol-Skills/bobz-skills/cobol-db2-migration/SKILL.md` |
| 7 | `cobol-jcl-migration` | `Cobol-Skills/bobz-skills/cobol-jcl-migration/SKILL.md` |
| 8 | `cobol-perf-tuning` | `Cobol-Skills/bobz-skills/cobol-perf-tuning/SKILL.md` |

#### Step 4 — Confirm all skills are installed

After installing all skills, you can verify they are available by asking Bob:

```
List all available skills related to COBOL migration
```

---

## 6. Available Skills

### 6.1 `cobol-modernization-code` — Full Modernization Assessment

**When to use:** When you want a complete migration analysis of a program — impact report, checklist, corrected code snippets, and updated JCL.

**What the skill does:**
1. Collects the COBOL source, JCL, and CICS/DB2 usage context
2. Classifies program migration complexity: **Simple** / **Medium** / **Complex**
3. Scans the program across 6 categories: Language Changes, Compiler Options, Language Environment, CICS, DB2, JCL
4. Generates a Markdown migration checklist with severity ratings 🔴/🟡/🟢
5. Produces functional equivalence statements for each mandatory item
6. Delivers before/after code snippets annotated with `*>> Cn`
7. Produces the updated JCL with change annotations

**Complexity classification:**

| Rating | Criteria |
|---|---|
| **Simple** | No CICS, no DB2, no CMPR2, no deprecated verbs — recompile with updated PARM |
| **Medium** | CICS or DB2 (not both), CMPR2 in use, obsolete JCL options — 2–4 targeted fix areas |
| **Complex** | CICS + DB2, IGZERRE/IGZETUN calls, VALUE in OCCURS, STOP RUN, HANDLE CONDITION — full review + test cycle |

**How to trigger:** *"Analyze this COBOL program for migration"*, *"give me a migration checklist"*, *"assess this program for modernization"*, *"what needs to change to compile with EC 6.5"*

---

### 6.2 `cobol-lang-changes` — Language Changes

**When to use:** To identify and fix COBOL II constructs incompatible with EC 6.5 at the source code level.

**Issues handled:**

| COBOL II Construct | EC 6.5 Replacement | Notes |
|---|---|---|
| `ALTER` statement | Eliminate — restructure with `EVALUATE` | Not supported in NOCMPR2 |
| `ACCEPT DATE / TIME / DAY` | `FUNCTION CURRENT-DATE` or `EXEC CICS ASKTIME` | Format changes from 6 to 8/21 characters |
| `STOP 'literal'` | `DISPLAY 'msg'` + `STOP RUN` | Compile error in EC 6.5 |
| `VALUE` on `OCCURS` subordinate | Remove `VALUE`; add `INITIALIZE` in Procedure Division | Causes **IKF2066S** in NOCMPR2 |
| `MOVE 'Y'/'N' TO flag` | `SET condition-name TO TRUE` | ANSI 85 standard idiom |
| Reserved word conflicts | Rename data-name with program-specific prefix | `JSON`, `FREE`, `ALLOCATE`, `DYNAMIC`, `VOLATILE` |

**How to trigger:** *"What language changes are needed?"*, *"my VALUE in OCCURS is failing"*, *"ACCEPT DATE migration"*, *"reserved word conflict"*

---

### 6.3 `cobol-compiler-options` — Compiler Options

**When to use:** To migrate the compile PARM — removing obsolete options and adding the new recommended ones.

**Removed options (cause compile errors in EC 6.5):**

| COBOL II Option | Action |
|---|---|
| `RES` / `NORES` | Remove — eliminated in EC 5+ |
| `RESIDENT` / `NORESIDENT` | Remove — eliminated in EC 5+ |
| `CMPR2` / `NOCMPR2` | Remove — eliminated in EC 6+; convert source to NOCMPR2 semantics first |
| `SIZE(MAX)` or `SIZE(n)` | Remove — eliminated in EC 5.2 |
| `ZONECHECK` | Replace with `NUMCHECK(ZON)` |
| `ZONEDATA` | Replace with `INVDATA` |

**New recommended options:**

```
OPT(FULL), ARCH(10), TUNE(10), TRUNC(OPT), CICS('COBOL2'), SQL
INVDATA(NOFIXUP), NUMCHECK, INITCHECK, SMARTBIN, REGION=0M
```

> **Note:** `REGION=0M` is mandatory — EC 6.5 uses storage above the 2 GB bar during compilation.

**How to trigger:** *"Update my compiler PARM"*, *"RES option is causing an error"*, *"what ARCH and TUNE values should I use?"*

---

### 6.4 `cobol-le-migration` — Language Environment

**When to use:** To replace COBOL II runtime calls (`IGZERRE`, `IGZETUN`, etc.) with their Language Environment equivalents.

**Key replacements:**

| COBOL II | Language Environment |
|---|---|
| `CALL 'IGZERRE'` | `CALL 'CEEPIPI'` |
| `CALL 'IGZETUN'` | `CALL 'CEESIGT'` |
| `CALL 'IGZCLOC'` | `CALL 'CEEDATM'` |
| `CALL 'ILBOSTP0'` | Remove — use LE enclave lifecycle |
| `COB2.SCOB2LKE` in STEPLIB | `CEE.SCEERUN` |
| `RTEREUS` runtime option | `TRAP(ON,NOSPIE)` + `CEEBXITA` exit |
| `MIXRES` | Remove — LE manages all modules |

> **Never mix** `COB2.SCOB2LKE` and `CEE.SCEERUN` in the same STEPLIB concatenation.

**Also covers:** AMODE 31 → AMODE 64 migration, diagnostic DD configuration (`CEEDUMP`, `CEESNAP`), replacing `IGZSNAP`/`IGZDUMP`.

**How to trigger:** *"IGZERRE call migration"*, *"replace COB2.SCOB2LKE"*, *"AMODE 64 migration"*, *"RTEREUS replacement"*

---

### 6.5 `cobol-cics-migration` — CICS Adaptations

**When to use:** To migrate CICS programs — from the JCL compile procedure through the program source.

**What the skill eliminates:**
- The `DFHECP1$` (CICSTRAN) step from JCL → replaced by the `CICS('COBOL2')` compiler option
- `STOP RUN` in the Procedure Division → causes `S0C4` abend under Language Environment
- `EXEC CICS HANDLE CONDITION` → replaced by `RESP` on each individual command

**Before/after pattern — HANDLE CONDITION:**

```cobol
* BEFORE (COBOL II)
EXEC CICS HANDLE CONDITION NOTFND(900-NOT-FOUND) ERROR(890-ERR) END-EXEC.
EXEC CICS READ DATASET('FILE') INTO(REC) RIDFLD(KEY) END-EXEC.

* AFTER (EC 6.5)
EXEC CICS READ
    DATASET ('FILE')
    INTO    (REC)
    RIDFLD  (KEY)
    RESP    (WS-CICS-RESP)
END-EXEC
EVALUATE WS-CICS-RESP
    WHEN DFHRESP(NORMAL)  CONTINUE
    WHEN DFHRESP(NOTFND)  PERFORM 900-NOT-FOUND THRU 900-EXIT
    WHEN OTHER            PERFORM 890-ERR THRU 890-EXIT
END-EVALUATE
```

**Before/after pattern — STOP RUN:**

```cobol
* BEFORE (COBOL II — unsafe under LE)
EXEC CICS RETURN TRANSID(WS-TRANSID) COMMAREA(DFHCOMMAREA)
    LENGTH(900) RESP(WS-RESP) END-EXEC.
STOP RUN.        <- REMOVE

* AFTER (EC 6.5 — correct)
EXEC CICS RETURN
    TRANSID  (WS-TRANSID)
    COMMAREA (DFHCOMMAREA)
    LENGTH   (900)
    RESP     (WS-RESP)
END-EXEC.
```

**How to trigger:** *"remove DFHECP1$ step"*, *"STOP RUN in CICS program"*, *"HANDLE CONDITION migration"*, *"EXEC CICS ABEND without RESP"*

---

### 6.6 `cobol-db2-migration` — DB2 Adaptations

**When to use:** To migrate DB2 integration — from the separate precompiler to the integrated coprocessor.

**Key changes:**

| Item | COBOL II | EC 6.5 |
|---|---|---|
| DB2 precompiler step | `DSNHPC` step in JCL | Removed — `SQL` compiler option replaces it |
| `DBRM DD` location | On the `DSNHPC` step | Must be on the `COBCOMP` step |
| `DECLARE CURSOR` location | Procedure Division | **Must move to Working-Storage Section** |
| `SYSIN` source | `&&DB2OUT` (DSNHPC output) | Original source dataset |
| Post-compile BIND | Required | Still required — re-run with the new DBRM |

> ⚠️ **Critical:** Moving `DECLARE CURSOR` to Working-Storage is the most impactful change. Placing it in the Procedure Division was a COBOL II precompiler convention — the integrated coprocessor processes declarations at compile time and requires them in the Data Division. Regression testing is mandatory after this change.

**Before/after — DECLARE CURSOR:**

```cobol
* BEFORE (COBOL II — Procedure Division)
 530    EXEC SQL
 531        DECLARE MYCSRSOR CURSOR FOR
 532        SELECT COL1 FROM TABLE WHERE KEY = :WS-KEY
 533    END-EXEC

* AFTER (EC 6.5 — Working-Storage Section)
 WORKING-STORAGE SECTION.
     EXEC SQL INCLUDE SQLCA END-EXEC.
     EXEC SQL
         DECLARE MYCSRSOR CURSOR FOR
         SELECT COL1 FROM TABLE WHERE KEY = :WS-KEY
     END-EXEC.
```

**How to trigger:** *"remove DSNHPC step"*, *"DECLARE CURSOR migration"*, *"DB2 coprocessor setup"*, *"DBRM DD statement"*

---

### 6.7 `cobol-jcl-migration` — JCL and Procedure Migration

**When to use:** To update the full compile JCL — from the legacy 6-step process to the consolidated 4-step process.

**Step comparison:**

| Step | COBOL II | EC 6.5 |
|---|---|---|
| BMS assembly | ✅ ASMMAP (`ASMA90`) | ✅ ASMMAP (unchanged) |
| BMS link-edit | ✅ LNKMAP (`IEWL`) | ✅ LNKMAP (unchanged) |
| DB2 precompile | ✅ DB2PREC (`DSNHPC`) | ❌ Removed |
| CICS translate | ✅ CICSTRAN (`DFHECP1$`) | ❌ Removed |
| Compile | ✅ COBCOMP (`IGYCRCTL`) | ✅ COBCOMP (updated) |
| Link-edit | ✅ LNKPGM (`IEWL`) | ✅ LNKPGM (updated) |

**Required changes on the COBCOMP step:**

```jcl
//COBCOMP  EXEC PGM=IGYCRCTL,
//    REGION=0M,                              <- ADD (mandatory)
//    PARM=('APOST,LIB,RENT,OPT(FULL),NODYNAM,NODECK,NOSSRANGE',
//          'CICS(''COBOL2''),SQL,ARCH(10),TUNE(10)',    <- ADD CICS + SQL
//          'INVDATA(NOFIXUP),NUMCHECK,INITCHECK')
//STEPLIB  DD DSN=IGY.V6R5M0.SIGYCOMP,DISP=SHR  <- UPDATE version
//SYSLIB   DD DSN=BANCO.CICS.COPYLIB,DISP=SHR
//         DD DSN=BANCO.DB2.DCLGEN,DISP=SHR
//         DD DSN=CICS.SDFHCOB,DISP=SHR
//         DD DSN=CEE.SCEEH,DISP=SHR              <- ADD (LE headers)
//DBRM     DD DSN=BANCO.DBRMLIB(&MEMBER),DISP=SHR <- ADD (DB2 coprocessor output)
//SYSIN    DD DSN=&LIB(&MEMBER),DISP=SHR          <- original source (not &&CICSOUT)
```

**Required changes on the LNKPGM step:**
- Update `IGY.V2R4M0.SIGYCOMP` → `IGY.V6R5M0.SIGYCOMP`
- Remove `COB2.SCOB2LKE` and `COB2.SCOB2LOD` from SYSLIB
- Confirm `CEE.SCEERUN` is in SYSLIB (Language Environment runtime)

**How to trigger:** *"update my compile JCL"*, *"consolidate compile procedure"*, *"REGION=0M for EC 6.5"*, *"remove pre-processing steps"*

---

### 6.8 `cobol-perf-tuning` — Performance Tuning

**When to use:** To optimize COBOL programs in EC 6.5 — through compiler options and source code improvements.

**Compiler options — quick wins:**

| Current Option | EC 6.5 Recommendation | CPU Impact |
|---|---|---|
| `OPTIMIZE` / `NOOPTIMIZE` | `OPT(FULL)` | Largest single gain |
| No `ARCH` or old value | `ARCH(10)` + `TUNE(10)` | +10–25% on loops and string operations |
| `NUMPROC(NOPFD)` | `INVDATA(NOFIXUP,NODECIMAL)` | Eliminates sign fix-up code |
| `TRUNC(STD)` | `TRUNC(OPT)` if data is clean | Eliminates base-10 divide |
| `SSRANGE` in production | `NOSSRANGE` | Removes bounds-check overhead |
| `TEST` in production | `NOTEST` | Removes debug instrumentation |

**Target production PARM:**
```
OPT(FULL),ARCH(10),TUNE(10),TRUNC(OPT),NOSSRANGE,NOTEST,NODYNAM
INVDATA(NOFIXUP,NODECIMAL),RENT,LIB,SMARTBIN
```

**Data type recommendations for hot paths:**

| Type | Recommendation |
|---|---|
| Loop counters / subscripts | `PIC S9(4) BINARY` — avoids DISPLAY conversion |
| Accumulators | `PIC S9(8) BINARY` |
| Packed decimal | `COMP-3` with odd digit count (e.g., `S9(13)V99`) — 8 bytes, efficient |
| Table access | Prefer `INDEX` over subscripts — offset is pre-calculated |
| Large sorted tables | Use `SEARCH ALL` — O(log n) vs O(n) |

**How to trigger:** *"tune COBOL performance"*, *"OPT(FULL) configuration"*, *"BINARY vs DISPLAY performance"*, *"SEARCH ALL vs SEARCH"*

---

## 7. How to Use

### Activating the Mode

1. In Bob, click the mode selector (gear icon or mode dropdown)
2. Select **🔄 zCOBOL Modernization**
3. Bob will adopt the COBOL migration specialist behavior

### Recommended workflow

```
1. Open Source-Code/ or the program to be migrated in your workspace
2. Activate the zCOBOL Modernization mode
3. Start with the cobol-modernization-code skill for the overall assessment
4. Follow the generated checklist, using specific skills for each category
5. Validate the result against Source-Code-Refactor/ (already migrated program)
```

### Typical session example

```
User: Analyze this COBOL program for migration to Enterprise COBOL 6.5.
      The program uses CICS and DB2.
      [pastes Source-Code/src/BKC01.cbl]

Bob:  (activates cobol-modernization-code)
      Complexity: Complex (CICS + DB2 + deprecated patterns)

      ## Migration Checklist — BKC01

      🔴 Mandatory (7 items):
      - [ ] Remove RES compiler option — compile error in EC 6.5
      - [ ] Remove DFHECP1$ step; add CICS('COBOL2') compiler option
      - [ ] Remove DSNHPC step; add SQL compiler option
      - [ ] Move DECLARE CURSOR to Working-Storage Section
      - [ ] Remove STOP RUN (line 208) — causes S0C4 under LE
      - [ ] Remove VALUE on OCCURS subordinates (lines 122-128) — IKF2066S
      - [ ] Add RESP to EXEC CICS ABEND (line 720)

      🟡 Recommended (5 items):
      - [ ] Replace COMP with BINARY (lines 91, 95, 109)
      - [ ] Replace MOVE 'Y'/'N' TO sw with SET condition-name TO TRUE
      - [ ] Add ARCH(10) and TUNE(10) to compiler PARM
      ...
```

---

## 8. Reference Resources

### IBM Guides (Markdown)

The files in `IBM-Guides-Markdown/` are the technical knowledge base used by all skills. They were converted from the original IBM manuals to Markdown to ensure efficient processing by Bob.

| File | Contents |
|---|---|
| `Enterprise-COBOL-for-zOS-Programming-Guide-v65.md` | Complete EC 6.5 programming guide |
| `COBOL-Language-Environment-Migration-Guide-v65.md` | Language Environment migration guide |
| `COBOL-II-Performance-Tuning.md` | VS COBOL II performance tuning reference |
| `Structured-CICS-COBOLII-Programming-Standards.md` | CICS COBOL II programming standards |
| `migration-cost-measurement-checklist.md` | Migration ROI formulas and business case checklist |

### Sample programs

| File | Description |
|---|---|
| `Source-Code/src/BKC01.cbl` | Banking CICS+DB2 program written in COBOL II — intentionally contains the most common migration issues |
| `Source-Code-Refactor/BKC01V65.cbl` | Version migrated to EC 6.5 — all changes annotated with `*>>` inline comments |
| `Source-Code-Refactor/BKC01-MIGRATION.md` | Statement-by-statement mapping with 🔴/🟡/🟢 severity ratings |
| `Source-Code/docs/BKC01-DOCUMENTATION.md` | Full technical documentation of the original program (BMS layout, Working-Storage fields, DB2 tables, CICS commands) |

### Original IBM manuals (PDF)

The `IBM-Guides/` folder contains all original IBM manuals in PDF format, covering all versions of Enterprise COBOL (v3.1 through v6.5), plus COBOL II and CICS manuals. These PDFs are the primary source for the Markdown files in `IBM-Guides-Markdown/`.

---

## 9. Usage Examples

### Full program assessment

```
[Mode: zCOBOL Modernization]

Analyze program BKC01.cbl for migration to Enterprise COBOL 6.5.
The program uses CICS and DB2. Generate a complete migration checklist.
```

### JCL update

```
[Mode: zCOBOL Modernization]

My compile JCL still uses the DSNHPC and DFHECP1$ steps.
Show me how to update it for Enterprise COBOL 6.5.
[paste the JCL]
```

### Compiler option question

```
[Mode: zCOBOL Modernization]

I have RES and CMPR2 in my PARM string.
What do I need to change for EC 6.5?
What is the recommended production PARM?
```

### DECLARE CURSOR migration

```
[Mode: zCOBOL Modernization]

I have a DECLARE CURSOR in my Procedure Division.
The integrated DB2 coprocessor does not accept that.
How do I fix it?
```

### Performance tuning after migration

```
[Mode: zCOBOL Modernization]

My program compiled successfully with Enterprise COBOL 6.5.
What compiler and code optimizations can I apply to reduce CPU consumption?
```

### Language Environment replacement

```
[Mode: zCOBOL Modernization]

My program calls IGZERRE and IGZETUN at startup.
What are the Language Environment equivalents?
Do I also need to update the STEPLIB?
```

---

## Support

This Mode/Skills package was developed as a demonstration and reference asset for the COBOL II → Enterprise COBOL 6.5 modernization journey on IBM Bob.

For questions about Bob Mode and Skill installation, consult the official IBM Bob documentation or ask Bob directly:

```
Ask Bob about how to create a custom mode
Ask Bob about how to create a skill
```

---

*Technical basis: IBM Enterprise COBOL for z/OS Programming Guide v6.5, IBM Language Environment Migration Guide v6.5, Structured CICS COBOL II Programming Standards (ISU-ATS)*
