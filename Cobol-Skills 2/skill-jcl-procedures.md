# Skill: JCL e Procedures de Compilacao — COBOL II para EC 6.5

> Fontes: `skill-migration-v65.md` §Ch.20 "JCL and packaging changes" /
> `skill-perf-tuning.md` §"CICS" e §"IMS"

---

## 1. Visao Geral das Mudancas de JCL

| Componente | COBOL II | Enterprise COBOL 6.5 |
|---|---|---|
| Compilador | `IGYCRCTL` v2.4 | `IGYCRCTL` v6.5 |
| Runtime library | `COB2.SCOB2LKE` | `CEE.SCEERUN` |
| CICS step | `DFHECP1$` separado | Opcao `CICS` no compilador |
| DB2 step | `DSNHPC` separado | Opcao `SQL` no compilador |
| Opcoes removidas | `RES`, `NORES`, `RESIDENT`, `CMPR2`, `SIZE` | — |
| Novas DDs | — | `DBRM DD`, `CEEOPTS DD` |
| MEMLIMIT | Nao aplicavel | `REGION=0M` + `MEMLIMIT=3G` (compilacao) |

---

## 2. Procedure de Compilacao — Comparativo Completo

### 2.1 Procedure COBOL II (antes)

```jcl
//COBIIPROC PROC MEMBER=,LIB=BANCO.CICS.SRC,
//               LOADLIB=BANCO.CICS.LOAD
//*
//*--- STEP 1: DB2 PRECOMPILE ---
//DB2PREC  EXEC PGM=DSNHPC,
//             PARM='HOST(COBOL),VERSION(AUTO),APOSTSQL(YES)'
//DBRMLIB   DD DSN=BANCO.DBRMLIB(&MEMBER),DISP=SHR
//SYSCIN    DD DSN=&&DB2OUT,DISP=(NEW,PASS),
//             UNIT=SYSDA,SPACE=(TRK,(10,5))
//SYSLIB    DD DSN=BANCO.CICS.COPYLIB,DISP=SHR
//          DD DSN=BANCO.DB2.DCLGEN,DISP=SHR
//SYSPRINT  DD SYSOUT=*
//SYSIN     DD DSN=&LIB(&MEMBER),DISP=SHR
//*
//*--- STEP 2: CICS TRANSLATOR ---
//CICSTRAN  EXEC PGM=DFHECP1$,
//              PARM='COBOL2,CICS'
//SYSLIB    DD DSN=BANCO.CICS.COPYLIB,DISP=SHR
//          DD DSN=BANCO.DB2.DCLGEN,DISP=SHR
//          DD DSN=CICS.SDFHCOB,DISP=SHR
//SYSUT1    DD UNIT=SYSDA,SPACE=(CYL,(1,1))
//SYSPUNCH  DD DSN=&&CICSOUT,DISP=(NEW,PASS),
//             UNIT=SYSDA,SPACE=(TRK,(15,5))
//SYSPRINT  DD SYSOUT=*
//SYSIN     DD DSN=&&DB2OUT,DISP=(OLD,DELETE)
//*
//*--- STEP 3: COBOL II COMPILE ---
//COBCOMP   EXEC PGM=IGYCRCTL,
//              PARM='APOST,LIB,RENT,RES,OPT,NODYNAM,NODECK'
//STEPLIB   DD DSN=IGY.V2R4M0.SIGYCOMP,DISP=SHR
//SYSLIB    DD DSN=BANCO.CICS.COPYLIB,DISP=SHR
//          DD DSN=BANCO.DB2.DCLGEN,DISP=SHR
//          DD DSN=CICS.SDFHCOB,DISP=SHR
//SYSUT1    DD UNIT=SYSDA,SPACE=(CYL,(2,1))
//SYSPRINT  DD SYSOUT=*
//SYSLIN    DD DSN=&&COBOUT,DISP=(NEW,PASS),
//             UNIT=SYSDA,SPACE=(TRK,(15,5))
//SYSIN     DD DSN=&&CICSOUT,DISP=(OLD,DELETE)
//*
//*--- STEP 4: LINK-EDIT ---
//LNKPGM    EXEC PGM=IEWL,
//               PARM='LIST,LET,XREF,RENT,REUS'
//SYSLIB    DD DSN=CICS.SDFHLOAD,DISP=SHR
//          DD DSN=DSN.SDSNEXIT,DISP=SHR
//          DD DSN=DSN.SDSNLOAD,DISP=SHR
//          DD DSN=IGY.V2R4M0.SIGYCOMP,DISP=SHR
//          DD DSN=CEE.SCEERUN,DISP=SHR
//SYSPRINT  DD SYSOUT=*
//SYSLMOD   DD DSN=&LOADLIB(&MEMBER),DISP=SHR
//SYSLIN    DD DSN=&&COBOUT,DISP=(OLD,DELETE)
//          DD DDNAME=SYSIN
//SYSIN     DD *
 NAME &MEMBER(R)
/*
// PEND
```

---

### 2.2 Procedure Enterprise COBOL 6.5 (depois)

```jcl
//EC65PROC  PROC MEMBER=,LIB=BANCO.CICS.SRC,
//               LOADLIB=BANCO.EC65.LOAD
//*
//*--- STEP 1: COMPILACAO (CICS + DB2 INTEGRADOS) ---
//COBCOMP   EXEC PGM=IGYCRCTL,
//    REGION=0M,
//    PARM=('APOST,LIB,RENT,OPT(FULL),NODYNAM,NODECK,NOSSRANGE',
//          'CICS(''COBOL2''),SQL,ARCH(10),TUNE(10)',
//          'TRUNC(OPT),INVDATA(NOFIXUP),NUMCHECK,INITCHECK',
//          'TEST(NODWARF)')
//*
//STEPLIB   DD DSN=IGY.V6R5M0.SIGYCOMP,DISP=SHR
//SYSLIB    DD DSN=BANCO.CICS.COPYLIB,DISP=SHR
//          DD DSN=BANCO.DB2.DCLGEN,DISP=SHR
//          DD DSN=CICS.SDFHCOB,DISP=SHR
//          DD DSN=CEE.SCEEH,DISP=SHR
//SYSUT1    DD UNIT=SYSDA,SPACE=(CYL,(2,1))
//SYSUT2    DD UNIT=SYSDA,SPACE=(CYL,(2,1))
//SYSUT3    DD UNIT=SYSDA,SPACE=(CYL,(2,1))
//SYSPRINT  DD SYSOUT=*
//SYSLIN    DD DSN=&&COBOUT,DISP=(NEW,PASS),
//             UNIT=SYSDA,SPACE=(TRK,(15,5))
//DBRM      DD DSN=BANCO.DBRMLIB(&MEMBER),DISP=SHR
//*    ^^^^ DBRM gerado pelo coprocessor integrado
//SYSIN     DD DSN=&LIB(&MEMBER),DISP=SHR
//*         ^^^^ fonte original diretamente (sem pre-processamento)
//*
//*--- STEP 2: LINK-EDIT ---
//LNKPGM    EXEC PGM=IEWL,
//               PARM='LIST,LET,XREF,RENT,REUS',
//               COND=(4,LT,COBCOMP)
//SYSLIB    DD DSN=CICS.SDFHLOAD,DISP=SHR
//          DD DSN=DSN.SDSNEXIT,DISP=SHR
//          DD DSN=DSN.SDSNLOAD,DISP=SHR
//          DD DSN=IGY.V6R5M0.SIGYCOMP,DISP=SHR
//          DD DSN=CEE.SCEERUN,DISP=SHR
//*              ^^^^^^^^^^^^ LE runtime (substitui COB2.SCOB2LKE)
//SYSPRINT  DD SYSOUT=*
//SYSLMOD   DD DSN=&LOADLIB(&MEMBER),DISP=SHR
//SYSLIN    DD DSN=&&COBOUT,DISP=(OLD,DELETE)
//          DD DDNAME=SYSIN
//SYSIN     DD *
 NAME &MEMBER(R)
/*
// PEND
```

---

## 3. DD Statements — Mudancas

| DD | COBOL II | Enterprise COBOL 6.5 | Acao |
|---|---|---|---|
| `STEPLIB` — compiler | `IGY.V2R4M0.SIGYCOMP` | `IGY.V6R5M0.SIGYCOMP` | Atualizar dataset |
| `STEPLIB` — runtime | `COB2.SCOB2LKE` | **Remover** — LE e carregado automaticamente | Remover |
| `SYSLIB` — LE headers | Nao necessario | `CEE.SCEEH` | Adicionar |
| `SYSLIB` — CICS copybooks | `CICS.SDFHCOB` | `CICS.SDFHCOB` (mesmo) | Sem alteracao |
| `DBRM` | No step DSNHPC | No step de compilacao | Mover DD para COBCOMP |
| `SYSCIN` / `&&DB2OUT` | Saida do DSNHPC | **Eliminar** | Remover |
| `&&CICSOUT` | Saida do DFHECP1$ | **Eliminar** | Remover |
| `CEEOPTS` | Nao existe | Opcional — opcoes runtime LE | Adicionar se necessario |

---

## 4. REGION e MEMLIMIT para Compilacao

Enterprise COBOL 6.5 usa storage **acima da barra de 2GB** para compilar.
Sem configuracao adequada, pode ocorrer `IGYCB7145-U Insufficient memory`.

```jcl
//COBCOMP   EXEC PGM=IGYCRCTL,
//    REGION=0M
//*
//* No JOB card ou via IEFUSI:
//JOBCARD   JOB ...,REGION=0M
//* E na configuracao z/OS:
//* MEMLIMIT=3G (minimo recomendado para compilacoes grandes)
```

> **Ref:** `skill-migration-v65.md` §Ch.19 "Compiler behavior changes — MEMLIMIT"

---

## 5. CEEOPTS — Opcoes de Runtime LE

Para controlar opcoes de runtime LE em batch:

```jcl
//CEEOPTS  DD *
  TRAP(ON,NOSPIE)
  STORAGE(00,00,00)
  RPTOPTS(ON)
/*
```

Em CICS, as opcoes LE sao configuradas no CICS SIT (System Initialization
Table) ou via `CEEUOPT` nos parametros de install do LE.

---

## 6. BIND DB2 — Continuidade

O processo de BIND nao muda. Apenas o dataset `DBRMLIB` precisa conter
os DBRMs gerados pelo novo coprocessor integrado.

```jcl
//DSNBIND  EXEC PGM=IKJEFT01
//SYSTSPRT DD SYSOUT=*
//SYSTSIN  DD *
  DSN SYSTEM(DB2P)
  BIND PACKAGE(BANCPKG) -
       MEMBER(MYPGM)    -
       LIBRARY('BANCO.DBRMLIB') -
       ISOLATION(CS) VALIDATE(BIND) ACTION(REPLACE)
  END
/*
```

---

## 7. Checklist de JCL para Migracao

```
DATASETS
[ ] STEPLIB do compilador atualizado para IGY.V6R5M0.SIGYCOMP
[ ] COB2.SCOB2LKE removido do STEPLIB / JOBLIB
[ ] CEE.SCEERUN presente no SYSLIB do link-edit
[ ] CEE.SCEEH adicionado ao SYSLIB do compilador (headers LE)

STEPS REMOVIDOS
[ ] Step DSNHPC (DB2PREC) removido
[ ] Step DFHECP1$ (CICSTRAN) removido
[ ] DDs &&DB2OUT e &&CICSOUT removidas

STEPS ATUALIZADOS (COBCOMP)
[ ] Opcao SQL adicionada (coprocessor DB2)
[ ] Opcao CICS adicionada (translator integrado)
[ ] Opcao RES removida
[ ] Opcao RESIDENT removida
[ ] Opcao CMPR2 removida (se presente)
[ ] Opcao SIZE removida (se presente)
[ ] DD DBRM adicionada para output do coprocessor DB2
[ ] REGION=0M adicionado no step de compilacao
[ ] SYSIN aponta para fonte original (nao mais para &&DB2OUT ou &&CICSOUT)

LINK-EDIT
[ ] CEE.SCEERUN presente no SYSLIB
[ ] COB2.SCOB2LKE removido do SYSLIB

BIND DB2
[ ] Re-bind executado com DBRMs gerados pelo coprocessor integrado
```
