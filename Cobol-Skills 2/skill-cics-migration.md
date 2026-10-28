# Skill: Migracao CICS — COBOL II para Enterprise COBOL 6.5

> Fontes: `skill-migration-v65.md` §Ch.24 "CICS conversion considerations" /
> `skill-cics-standards.md` §"Special Considerations" e "Error Handling" /
> `skill-perf-tuning.md` §"CICS"

---

## 1. Integrated CICS Translator — Principal Mudanca

Em COBOL II, o processo de compilacao de programas CICS exigia um step
separado com o programa `DFHECP1$` (CICS Translator) **antes** da compilacao.

Em Enterprise COBOL 6.5, o translator e **integrado** ao compilador —
ativado pela opcao `CICS`.

### JCL COBOL II (3 steps relevantes)

```jcl
*-- STEP ANTIGO: CICS TRANSLATOR SEPARADO --
//CICSTRAN EXEC PGM=DFHECP1$,
//             PARM='COBOL2,CICS'
//SYSLIB  DD DSN=BANCO.CICS.COPYLIB,DISP=SHR
//SYSIN   DD DSN=BANCO.CICS.SRC(MYPGM),DISP=SHR
//SYSUT1  DD UNIT=SYSDA,SPACE=(TRK,(5,5))
//SYSPUNCH DD DSN=&&CICSOUT,DISP=(NEW,PASS),...
//SYSPRINT DD SYSOUT=*

*-- STEP ANTIGO: COMPILACAO --
//COBCOMP EXEC PGM=IGYCRCTL,
//            PARM='RENT,RES,LIB,...'
//SYSIN   DD DSN=&&CICSOUT,DISP=(OLD,DELETE)
```

### JCL Enterprise COBOL 6.5 (step unico)

```jcl
*-- STEP NOVO: COMPILACAO COM TRANSLATOR INTEGRADO --
//COBCOMP EXEC PGM=IGYCRCTL,
//            PARM='RENT,LIB,OPT(FULL),CICS(''COBOL2''),NODYNAM'
*                                      ^^^^^^^^^^^^^^^^^^
*                          Opcao CICS ativa o integrated translator
//SYSLIB  DD DSN=BANCO.CICS.COPYLIB,DISP=SHR
//        DD DSN=CICS.SDFHCOB,DISP=SHR
//SYSIN   DD DSN=BANCO.CICS.SRC(MYPGM),DISP=SHR
//SYSLIN  DD DSN=&&COBOUT,DISP=(NEW,PASS),...
//SYSPRINT DD SYSOUT=*
```

**Principais subopcoes da opcao `CICS`:**

| Subopcao | Descricao |
|---|---|
| `CICS('COBOL2')` | Compatibilidade com programas COBOL II |
| `CICS('SP')` | Service point programs |
| `CICS('NOSPIE')` | Desativa SPIE handling do CICS |
| `CICS('NODBCS')` | Sem suporte DBCS |

> **Ref:** `skill-migration-v65.md` Table 52/53 "Compiler options for programs
> that run under CICS" e "Key compiler options for the integrated CICS translator"

---

## 2. `STOP RUN` — Substituicao Obrigatoria

Em programas CICS, `STOP RUN` **nunca deveria ter sido usada** — mas alguns
programas COBOL II a continham como sentinela apos o ultimo `EXEC CICS RETURN`.

**Por que e critico:**
- Em COBOL II: `STOP RUN` encerrava o run-unit e poderia afetar a task CICS.
- Em Enterprise COBOL 6.5 + LE: `STOP RUN` encerra o **enclave LE** inteiro,
  causando abend `S0C4` ou loop de retorno para o CICS dispatcher.

```cobol
* COBOL II — incompativel
EXEC CICS RETURN TRANSID('ABCD') COMMAREA(DFHCOMMAREA) END-EXEC.
STOP RUN.           *> REMOVER

* Enterprise COBOL 6.5 — correto
EXEC CICS RETURN
    TRANSID  (WS-TRANSID)
    COMMAREA (DFHCOMMAREA)
    LENGTH   (900)
    RESP     (WS-RESP)
END-EXEC.
*> Nenhum statement apos o RETURN — ou apenas um ponto final
```

> **Ref:** `skill-cics-standards.md` §"Special Considerations — STOP RUN"

---

## 3. `HANDLE CONDITION` — Substituicao Recomendada

`EXEC CICS HANDLE CONDITION` usa GO TO implicito — incompativel com
programas estruturados e com o modelo de programacao de Enterprise COBOL.

```cobol
* COBOL II (estilo antigo — nao recomendado)
EXEC CICS HANDLE CONDITION
    NOTFND(900-NOT-FOUND)
    ERROR (890-CICS-ERROR)
END-EXEC.
EXEC CICS READ DATASET('MYFIL') INTO(MY-REC) RIDFLD(MY-KEY) END-EXEC.

* Enterprise COBOL 6.5 (estilo correto — RESP)
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

## 4. CALL para Subprogramas com CICS

**COBOL II:** Para chamar subprograma traduzido pelo CICS translator,
era necessario passar `DFHEIB` e `DFHCOMMAREA` como primeiros parametros.

**Enterprise COBOL 6.5:** Com o integrated translator, o mecanismo mudou.

```cobol
* COBOL II — chamada a subprograma com CICS
CALL 'SUBPGM' USING DFHEIB
                    DFHCOMMAREA
                    MY-PARM1
                    MY-PARM2.

* Enterprise COBOL 6.5 — EXEC CICS LINK (preferido)
EXEC CICS LINK
    PROGRAM  (WS-LINK-SUBPGM)
    COMMAREA (MY-COMMAREA)
    LENGTH   (LENGTH OF MY-COMMAREA)
    RESP     (WS-CICS-RESP)
END-EXEC

* Enterprise COBOL 6.5 — CALL estatico (se subprograma nao tem CICS)
CALL 'SUBPGM' USING MY-PARM1
                    MY-PARM2.
```

> **Ref:** `skill-perf-tuning.md` §"CICS — Using CALLs" /
> `skill-migration-v65.md` §Ch.24 "Static calls from COBOL 5 or 6 to VS COBOL II"

---

## 5. CSD e DFHRPL — Mudancas de Setup

Em Enterprise COBOL 5+, o formato do load module muda com o uso do
integrated translator. O CSD (CICS System Definition) e o DFHRPL devem
apontar para os modulos recompilados.

| Item | COBOL II | Enterprise COBOL 6.5 |
|---|---|---|
| Load library | `BANCO.CICS.LOAD` (modulos COBOL II) | `BANCO.EC65.LOAD` (novos load modules) |
| DFHRPL | Contem modulos COBOL II | Deve ser atualizado para EC 6.5 modules |
| CSD entry | `LANGUAGE(COBOL)` | `LANGUAGE(COBOL)` — sem alteracao |
| Mapset | Reusa `BKCONS0` sem alteracao | BMS mapset nao muda |

> **Ref:** `skill-migration-v65.md` §Ch.24 "CSD setup differences" e
> "DFHRPL setup differences with EC 5 and 6"

---

## 6. Padrao para `EXEC CICS ABEND`

Em COBOL II, `EXEC CICS ABEND ABCODE(...)` era aceitavel sem `RESP`.
Em Enterprise COBOL 6.5, sempre incluir `RESP` para capturar erros no
proprio ABEND (ex: codigo invalido):

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

## 7. Checklist CICS para Migracao

```
[ ] Step DFHECP1$ removido do JCL
[ ] Opcao CICS('COBOL2') adicionada no compilador
[ ] SYSLIB inclui CICS.SDFHCOB
[ ] Todos os STOP RUN removidos ou substituidos por EXEC CICS RETURN
[ ] HANDLE CONDITION substituido por verificacao de RESP
[ ] EXEC CICS ABEND inclui RESP
[ ] DFHRPL atualizado para load modules EC 6.5
[ ] CICS.SDFHLOAD na SYSLIB do link-edit
[ ] Testes de regressao para todos os fluxos de transacao
```
