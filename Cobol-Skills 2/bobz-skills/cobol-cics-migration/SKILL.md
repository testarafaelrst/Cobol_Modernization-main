---
name: cobol-cics-migration
description: >-
  Use when the user asks about migrating CICS COBOL II programs to Enterprise
  COBOL 6.5 — including replacing the DFHECP1$ translator step with the
  integrated CICS option, removing STOP RUN, replacing HANDLE CONDITION with
  RESP checking, updating CALL conventions for CICS subprograms, DFHRPL and
  CSD setup, or EXEC CICS ABEND without RESP.
---

# Skill: CICS Migration — COBOL II to Enterprise COBOL 6.5

Follow these steps when the user needs to migrate a CICS COBOL II program.

## Step 1 — Read the Program

Ask the user to provide the source if not already given. Identify:

1. Whether the JCL has a `DFHECP1$` (CICSTRAN) step
2. Any `STOP RUN` statements in the Procedure Division
3. Any `EXEC CICS HANDLE CONDITION` commands
4. Any `CALL` to a CICS-translated subprogram
5. Any `EXEC CICS ABEND` without `RESP`

## Step 2 — JCL: Replace DFHECP1$ with Integrated Translator

Show a before/after diff of the JCL:

```jcl
* REMOVE this entire step:
//CICSTRAN EXEC PGM=DFHECP1$, PARM='COBOL2,CICS'
//SYSIN    DD DSN=&&DB2OUT,...  (or source dataset)
//SYSPUNCH DD DSN=&&CICSOUT,...

* UPDATE the COBCOMP step PARM to add:
CICS('COBOL2')

* UPDATE COBCOMP SYSIN to point directly to source:
//SYSIN DD DSN=BANCO.CICS.SRC(&MEMBER),DISP=SHR
```

Key compiler options for CICS programs (ref: `Cobol-Skills/skill-cics-migration.md` Table 52):

| Option | Required? | Notes |
|---|---|---|
| `CICS('COBOL2')` | Yes | Activates integrated translator |
| `RENT` | Yes | Mandatory for CICS reentrancy |
| `NODYNAM` | Recommended | Static calls — lower overhead |
| `TRUNC(OPT)` | Recommended | If BINARY data conforms to PIC |

## Step 3 — Remove STOP RUN

`STOP RUN` in a CICS program under LE terminates the LE enclave — causes
`S0C4` or unpredictable behavior. Remove every occurrence.

```cobol
* BEFORE (COBOL II — unsafe)
EXEC CICS RETURN TRANSID(WS-TRANSID) COMMAREA(DFHCOMMAREA)
    LENGTH(900) RESP(WS-RESP) END-EXEC.
STOP RUN.          <- REMOVE

* AFTER (EC 6.5 — correct)
EXEC CICS RETURN
    TRANSID  (WS-TRANSID)
    COMMAREA (DFHCOMMAREA)
    LENGTH   (900)
    RESP     (WS-RESP)
END-EXEC.
```

## Step 4 — Replace HANDLE CONDITION with RESP

```cobol
* BEFORE
EXEC CICS HANDLE CONDITION NOTFND(900-NOT-FOUND) ERROR(890-ERR) END-EXEC.
EXEC CICS READ DATASET('FILE') INTO(REC) RIDFLD(KEY) END-EXEC.

* AFTER
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

## Step 5 — Add RESP to EXEC CICS ABEND

```cobol
* BEFORE
EXEC CICS ABEND ABCODE(WS-CODE) END-EXEC.

* AFTER
EXEC CICS ABEND ABCODE(WS-CODE) RESP(WS-CICS-RESP) END-EXEC.
```

## Step 6 — Update DFHRPL and CSD

Remind the user that the recompiled load modules must be placed in a
new or updated DFHRPL dataset and that the CICS CSD `LANGUAGE(COBOL)`
entry remains unchanged. Reference: `Cobol-Skills/skill-cics-migration.md`
§"CSD and DFHRPL".

## Step 7 — Produce a Change Summary

Output a table: **Location** | **COBOL II Pattern** | **EC 6.5 Change** | **Risk Level**.
Flag any change where functional equivalence cannot be guaranteed without testing.
