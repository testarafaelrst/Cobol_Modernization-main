# Skill: CICS Migration — COBOL II to Enterprise COBOL 6.5

> Sources: `skill-migration-v65.md` §Ch.24 "CICS conversion considerations" /
> `skill-cics-standards.md` §"Special Considerations" and "Error Handling" /
> `skill-perf-tuning.md` §"CICS"

---

## 1. Integrated CICS Translator — Main Change

In COBOL II, compiling CICS programs required a separate step running the
`DFHECP1$` program (CICS Translator) **before** the COBOL compilation.

In Enterprise COBOL 6.5, the translator is **integrated** into the compiler —
activated by the `CICS` option.

### COBOL II JCL (3 relevant steps)

```jcl
*-- OLD STEP: SEPARATE CICS TRANSLATOR --
//CICSTRAN EXEC PGM=DFHECP1$,
//             PARM='COBOL2,CICS'
//SYSLIB  DD DSN=BANCO.CICS.COPYLIB,DISP=SHR
//SYSIN   DD DSN=BANCO.CICS.SRC(MYPGM),DISP=SHR
//SYSUT1  DD UNIT=SYSDA,SPACE=(TRK,(5,5))
//SYSPUNCH DD DSN=&&CICSOUT,DISP=(NEW,PASS),...
//SYSPRINT DD SYSOUT=*

*-- OLD STEP: COMPILE --
//COBCOMP EXEC PGM=IGYCRCTL,
//            PARM='RENT,RES,LIB,...'
//SYSIN   DD DSN=&&CICSOUT,DISP=(OLD,DELETE)
```

### Enterprise COBOL 6.5 JCL (single step)

```jcl
*-- NEW STEP: COMPILE WITH INTEGRATED TRANSLATOR --
//COBCOMP EXEC PGM=IGYCRCTL,
//            PARM='RENT,LIB,OPT(FULL),CICS(''COBOL2''),NODYNAM'
*                                      ^^^^^^^^^^^^^^^^^^
*                          The CICS option activates the integrated translator
//SYSLIB  DD DSN=BANCO.CICS.COPYLIB,DISP=SHR
//        DD DSN=CICS.SDFHCOB,DISP=SHR
//SYSIN   DD DSN=BANCO.CICS.SRC(MYPGM),DISP=SHR
//SYSLIN  DD DSN=&&COBOUT,DISP=(NEW,PASS),...
//SYSPRINT DD SYSOUT=*
```

**Main suboptions of the `CICS` option:**

| Suboption | Description |
|---|---|
| `CICS('COBOL2')` | Compatibility with COBOL II programs |
| `CICS('SP')` | Service point programs |
| `CICS('NOSPIE')` | Disables CICS SPIE handling |
| `CICS('NODBCS')` | No DBCS support |

> **Ref:** `skill-migration-v65.md` Table 52/53 "Compiler options for programs
> that run under CICS" and "Key compiler options for the integrated CICS translator"

---

## 2. `STOP RUN` — Mandatory Replacement

In CICS programs, `STOP RUN` **should never have been used** — but some
COBOL II programs contained it as a sentinel after the last `EXEC CICS RETURN`.

**Why it is critical:**
- In COBOL II: `STOP RUN` ended the run-unit and could affect the CICS task.
- In Enterprise COBOL 6.5 + LE: `STOP RUN` terminates the entire **LE enclave**,
  causing an `S0C4` abend or a return loop to the CICS dispatcher.

```cobol
* COBOL II — incompatible
EXEC CICS RETURN TRANSID('ABCD') COMMAREA(DFHCOMMAREA) END-EXEC.
STOP RUN.           *> REMOVE

* Enterprise COBOL 6.5 — correct
EXEC CICS RETURN
    TRANSID  (WS-TRANSID)
    COMMAREA (DFHCOMMAREA)
    LENGTH   (900)
    RESP     (WS-RESP)
END-EXEC.
*> No statement after the RETURN — or just a period
```

> **Ref:** `skill-cics-standards.md` §"Special Considerations — STOP RUN"

---

## 3. `HANDLE CONDITION` — Recommended Replacement

`EXEC CICS HANDLE CONDITION` uses an implicit GO TO — incompatible with
structured programs and with the Enterprise COBOL programming model.

```cobol
* COBOL II (old style — not recommended)
EXEC CICS HANDLE CONDITION
    NOTFND(900-NOT-FOUND)
    ERROR (890-CICS-ERROR)
END-EXEC.
EXEC CICS READ DATASET('MYFIL') INTO(MY-REC) RIDFLD(MY-KEY) END-EXEC.

* Enterprise COBOL 6.5 (correct style — RESP)
EXEC CICS READ
    DATASET ('MYFIL')
    INTO    (MY-REC)
    RIDFLD  (MY-KEY)
    RESP    (WS-CICS-RESP)
END-EXEC

EVALUATE WS-CICS-RESP
    WHEN DFHRESP(NORMAL)
        CONTINUE
    WHEN DFHRESP(NOTFND)
        PERFORM 900-NOT-FOUND THRU 900-EXIT
    WHEN OTHER
        PERFORM 890-CICS-ERROR THRU 890-EXIT
END-EVALUATE
```

> **Ref:** `skill-cics-standards.md` §"Error Handling — RESP Parameter"

---

## 4. CALL to Subprograms with CICS

**COBOL II:** To call a subprogram translated by the CICS translator,
`DFHEIB` and `DFHCOMMAREA` had to be passed as the first parameters.

**Enterprise COBOL 6.5:** With the integrated translator, the mechanism changed.

```cobol
* COBOL II — call to a subprogram with CICS
CALL 'SUBPGM' USING DFHEIB
                    DFHCOMMAREA
                    MY-PARM1
                    MY-PARM2.

* Enterprise COBOL 6.5 — EXEC CICS LINK (preferred)
EXEC CICS LINK
    PROGRAM  (WS-LINK-SUBPGM)
    COMMAREA (MY-COMMAREA)
    LENGTH   (LENGTH OF MY-COMMAREA)
    RESP     (WS-CICS-RESP)
END-EXEC

* Enterprise COBOL 6.5 — static CALL (if the subprogram has no CICS)
CALL 'SUBPGM' USING MY-PARM1
                    MY-PARM2.
```

> **Ref:** `skill-perf-tuning.md` §"CICS — Using CALLs" /
> `skill-migration-v65.md` §Ch.24 "Static calls from COBOL 5 or 6 to VS COBOL II"

---

## 5. CSD and DFHRPL — Setup Changes

In Enterprise COBOL 5+, the load module format changes with the use of the
integrated translator. The CSD (CICS System Definition) and DFHRPL must
point to the recompiled modules.

| Item | COBOL II | Enterprise COBOL 6.5 |
|---|---|---|
| Load library | `BANCO.CICS.LOAD` (COBOL II modules) | `BANCO.EC65.LOAD` (new load modules) |
| DFHRPL | Contains COBOL II modules | Must be updated to EC 6.5 modules |
| CSD entry | `LANGUAGE(COBOL)` | `LANGUAGE(COBOL)` — no change |
| Mapset | Reuses `BKCONS0` unchanged | BMS mapset does not change |

> **Ref:** `skill-migration-v65.md` §Ch.24 "CSD setup differences" and
> "DFHRPL setup differences with EC 5 and 6"

---

## 6. Pattern for `EXEC CICS ABEND`

In COBOL II, `EXEC CICS ABEND ABCODE(...)` was acceptable without `RESP`.
In Enterprise COBOL 6.5, always include `RESP` to capture errors in the
ABEND itself (e.g., an invalid abend code):

```cobol
* COBOL II
EXEC CICS ABEND ABCODE(WS-ABEND-CODE) END-EXEC.

* Enterprise COBOL 6.5
EXEC CICS ABEND
    ABCODE (WS-ABEND-CODE)
    RESP   (WS-CICS-RESP)
END-EXEC.
```

---

## 7. CICS Migration Checklist

```
[ ] DFHECP1$ step removed from the JCL
[ ] CICS('COBOL2') option added to the compiler
[ ] SYSLIB includes CICS.SDFHCOB
[ ] All STOP RUN statements removed or replaced by EXEC CICS RETURN
[ ] HANDLE CONDITION replaced by RESP checking
[ ] EXEC CICS ABEND includes RESP
[ ] DFHRPL updated to EC 6.5 load modules
[ ] CICS.SDFHLOAD in the link-edit SYSLIB
[ ] Regression tests for all transaction flows
```
