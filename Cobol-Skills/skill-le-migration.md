# Skill: Language Environment Migration — COBOL II to EC 6.5

> Sources: `skill-le-runtime.md` Ch.1 and 2 /
> `skill-migration-v65.md` §Ch.20 "Language Environment option changes" and §Ch.21

---

## 1. Overview: From COBOL II Runtime to LE

In COBOL II, the runtime was managed by its own modules (`IGZ*`).
In Enterprise COBOL 6.5, the runtime is **IBM Language Environment (LE)**,
shared with PL/I, C/C++, and Fortran — forming a unified environment.

```
COBOL II Runtime (IGZ*)          Language Environment (CEE*)
================================ ================================
IGZERRE  - init/term runtime  -> CEEPIPI  - init/term enclave
IGZETUN  - condition handler  -> CEESIGT  - register condition handler
IGZCLOC  - runtime date/time  -> CEEDATM  - LE date/time
IGZCPAC  - library COBPACK    -> CEE.SCEERUN (LE library)
IGZEPCL  - library (CICS)     -> CEE.SCEERUN (automatic)
RTEREUS  - reuse runtime      -> TRAP(ON,NOSPIE) + CEEBXITA
LIBKEEP  - keep library       -> CEEBXITA exit or TRAP(ON)
STAE     - intercept abend    -> CEEHDLR (condition handler)
NOSTAE   - no intercept       -> TRAP(OFF)
```

---

## 2. Runtime Calls — Replacement Table

### 2.1 `IGZERRE` → `CEEPIPI`
**COBOL II:** Initialized and terminated the VS COBOL II runtime from a
non-COBOL program (assembler or PL/I driver).

```cobol
* COBOL II
01 WS-FUNC  PIC X(2) VALUE 'IN'.   *> 'IN'=init 'TM'=term
CALL 'IGZERRE' USING WS-FUNC.

* Enterprise COBOL 6.5 with LE
* CEEPIPI is the standard LE interface for initializing an enclave
* Refer to skill-le-runtime.md Ch.2 "Downward compatibility considerations"
* For most cases, LE initializes automatically — it is not necessary
* to call CEEPIPI explicitly in COBOL programs under CICS or batch z/OS.
```

> **Ref:** `skill-le-runtime.md` §Ch.2 "HLL compatibility considerations /
> COBOL considerations"

---

### 2.2 `IGZETUN` — Condition Handler
**COBOL II:** Registered a routine to intercept conditions (similar to ESTAE).

```cobol
* COBOL II
CALL 'IGZETUN' USING WS-HANDLER-ADDR.

* Enterprise COBOL 6.5 with LE
* Use CEEHDLR to register an LE condition handler
01 WS-TOKEN  PIC S9(9) BINARY VALUE ZERO.
CALL 'CEEHDLR' USING MY-HANDLER-RTN
                     WS-TOKEN
                     FC.
```

---

### 2.3 Option `RTEREUS` → Equivalent LE Behavior
**COBOL II:** `RTEREUS` kept the COBOL environment initialized between
invocations, treating each COBOL program as a subroutine.

**Enterprise COBOL 6.5:** LE manages the enclave lifecycle
automatically. For reuse semantics, use:
- `TRAP(ON,NOSPIE)` in the LE runtime option
- Or the `CEEBXITA` exit for lifecycle control

> **Ref:** `skill-le-runtime.md` §Ch.2 "Planning to link-edit and run"

---

### 2.4 `LIBKEEP` → LE loads automatically
**COBOL II:** `LIBKEEP` kept the `IGZ*` modules in storage after the
first load, avoiding reload for each program.

**Enterprise COBOL 6.5:** LE (`CEE.SCEERUN`) is automatically kept
in storage while the enclave is active. There is no direct equivalent
because the default LE behavior already incorporates what `LIBKEEP` did.

---

## 3. Runtime Options — Comparison

| COBOL II (IGZOPT) | Language Environment (CEEDOPT / CEEOPTS) |
|---|---|
| `RTEREUS` | `REUSE` (simulated via LE configuration) |
| `LIBKEEP` | Default LE behavior |
| `STAE` | `TRAP(ON)` — default |
| `NOSTAE` | `TRAP(OFF)` |
| `WSCLEAR` | `STORAGE(00,00,00)` — zeros WS |
| `SSRANGE` | Activated by the compiler with the `SSRANGE` option |
| `MIXRES` | Not needed — LE manages everything |
| `SPOUT` | Space management dump — replaced by LE dump |

---

## 4. STEPLIB / Link-Edit — Library Changes

### COBOL II (JCL)
```jcl
//JOBLIB DD DSN=IGY.V2R4M0.SIGYCOMP,DISP=SHR   *> compiler
//       DD DSN=COB2.SCOB2LKE,DISP=SHR          *> COBOL II runtime
//       DD DSN=COB2.SCOB2LOD,DISP=SHR          *> COBOL II library
```

### Enterprise COBOL 6.5 (JCL)
```jcl
//JOBLIB DD DSN=IGY.V6R5M0.SIGYCOMP,DISP=SHR   *> EC 6.5 compiler
//       DD DSN=CEE.SCEERUN,DISP=SHR            *> LE runtime
//       DD DSN=CEE.SCEECICS,DISP=SHR           *> LE CICS (if applicable)
```

> **Rule:** Never mix `COB2.SCOB2LKE` (COBOL II runtime) with
> `CEE.SCEERUN` (LE runtime) in the same STEPLIB concatenation.
> `skill-le-runtime.md` §Ch.2 "Downward compatibility considerations"

---

## 5. AMODE and Addressing Considerations

| Mode | COBOL II | Enterprise COBOL 6.5 |
|---|---|---|
| `AMODE 24` | Supported (data below 16MB) | Deprecated — avoid |
| `AMODE 31` | Default | Default (LP(32)) |
| `AMODE 64` | Not supported | Available with `LP(64)` in EC 6.3+ |

**Migration to 64-bit:**
- Declare pointers as `USAGE POINTER` (4 bytes in AMODE 31)
  or `USAGE POINTER-64` for AMODE 64
- `POINTER-32` available for compatibility in LP(64) mode
- Check `DATA(31)` vs `DATA(24)` for WS location

> **Ref:** `skill-le-runtime.md` §Ch.2 "C/C++ AMODE/RMODE considerations" /
> `skill-migration-v65.md` §Ch.20 "AMODE and RMODE considerations"

---

## 6. Dump and Diagnostics

| COBOL II | Enterprise COBOL 6.5 |
|---|---|
| `IGZSNAP` — WS dump | `CEEDUMP` — LE structured dump |
| `IGZDUMP` — full dump | LE SYSMDUMP / SYSUDUMP |
| `EXEC CICS DUMP TASK` | Maintained for CICS programs |

To activate formatted LE dump in batch:
```jcl
//CEESNAP  DD SYSOUT=*
//CEEDUMP  DD SYSOUT=*
//SYSABEND DD SYSOUT=*
```
