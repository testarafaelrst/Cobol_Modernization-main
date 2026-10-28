# Skill: Migracao DB2 — COBOL II para Enterprise COBOL 6.5

> Fonte: `skill-migration-v65.md` §Ch.25 "Db2 coprocessor conversion considerations"

---

## 1. Integrated DB2 Coprocessor — Principal Mudanca

Em COBOL II, o acesso DB2 exigia um step de **pre-compilacao** separado
com o programa `DSNHPC` antes da compilacao COBOL.

Em Enterprise COBOL 6.5, o DB2 coprocessor e **integrado** ao compilador
— ativado pela opcao `SQL`.

### JCL COBOL II (4 steps relevantes)

```jcl
*-- STEP 1: DB2 PRECOMPILE --
//DB2PREC EXEC PGM=DSNHPC,
//            PARM='HOST(COBOL),VERSION(AUTO),APOSTSQL(YES)'
//DBRMLIB DD DSN=BANCO.DBRMLIB(MYPGM),DISP=SHR
//SYSCIN  DD DSN=&&DB2OUT,DISP=(NEW,PASS),...
//SYSLIB  DD DSN=BANCO.CICS.COPYLIB,DISP=SHR
//        DD DSN=BANCO.DB2.DCLGEN,DISP=SHR
//SYSIN   DD DSN=BANCO.CICS.SRC(MYPGM),DISP=SHR
//SYSPRINT DD SYSOUT=*

*-- STEP 2: (CICS TRANSLATOR se aplicavel) ...

*-- STEP 3: COMPILACAO --
//COBCOMP EXEC PGM=IGYCRCTL,PARM='RENT,RES,...'
//SYSIN   DD DSN=&&DB2OUT,DISP=(OLD,DELETE)  *> saida do precompiler
```

### JCL Enterprise COBOL 6.5 (step unico)

```jcl
*-- STEP UNICO: COMPILACAO COM COPROCESSOR INTEGRADO --
//COBCOMP EXEC PGM=IGYCRCTL,
//            PARM='RENT,LIB,OPT(FULL),SQL,CICS(''COBOL2''),NODYNAM'
*                                      ^^^
*                   Opcao SQL ativa o integrated DB2 coprocessor
//SYSLIB  DD DSN=BANCO.CICS.COPYLIB,DISP=SHR
//        DD DSN=BANCO.DB2.DCLGEN,DISP=SHR   *> DCLGENs na SYSLIB
//        DD DSN=CICS.SDFHCOB,DISP=SHR
//SYSIN   DD DSN=BANCO.CICS.SRC(MYPGM),DISP=SHR  *> fonte original
//SYSLIN  DD DSN=&&COBOUT,...
//SYSPRINT DD SYSOUT=*
*> DBRMLIB e gerado automaticamente via DBRM DD:
//DBRM    DD DSN=BANCO.DBRMLIB(MYPGM),DISP=SHR
```

> **Ref:** `skill-migration-v65.md` §Ch.25 "Db2 coprocessor integration" e
> "Differences between the Db2 precompiler and the integrated Db2 coprocessor"

---

## 2. DECLARE CURSOR — Localizacao Obrigatoria

Esta e a **mudanca mais critica** para programas DB2.

Com o pre-compilador `DSNHPC`, o `DECLARE CURSOR` podia estar tanto na
Working-Storage quanto na Procedure Division.

Com o **integrated DB2 coprocessor**, o `DECLARE CURSOR` **deve estar
obrigatoriamente na DATA DIVISION** (Working-Storage ou Linkage Section).

```cobol
* COBOL II com DSNHPC — aceito (cursor na Procedure Division)
PROCEDURE DIVISION.
000-MAINLINE.
    ...
    EXEC SQL
        DECLARE MEUCSRSOR CURSOR FOR
        SELECT COL1, COL2
        FROM   MINHA.TABELA
        WHERE  COL3 = :WS-CHAVE
    END-EXEC

* Enterprise COBOL 6.5 com coprocessor — OBRIGATORIO na DATA DIVISION
WORKING-STORAGE SECTION.
    ...
    EXEC SQL
        DECLARE MEUCSRSOR CURSOR FOR
        SELECT COL1, COL2
        FROM   MINHA.TABELA
        WHERE  COL3 = :WS-CHAVE
    END-EXEC.

PROCEDURE DIVISION.
000-MAINLINE.
    ...
    EXEC SQL OPEN  MEUCSRSOR  END-EXEC
    EXEC SQL FETCH MEUCSRSOR INTO :WS-COL1, :WS-COL2 END-EXEC
    EXEC SQL CLOSE MEUCSRSOR  END-EXEC
```

---

## 3. Diferencas Precompiler vs Coprocessor Integrado

| Aspecto | DSNHPC (Precompiler) | Integrated Coprocessor |
|---|---|---|
| `DECLARE CURSOR` na Proc. Div. | Permitido | **Proibido** — deve ser na DATA DIV. |
| `EXEC SQL INCLUDE` | Processado no step DSNHPC | Processado direto pelo compilador |
| Host variables em macros COPY | Processadas pelo precompiler | Processadas pelo coprocessor |
| DBRM gerado | Via DD DBRMLIB no step DSNHPC | Via DD DBRM no step de compilacao |
| Code page conversion | Controlado por DSNHPC | Opcao `CODEPAGE` no coprocessor |
| `APOSTSQL` | Parametro do DSNHPC | Opcao `SQL(APOST)` no compilador |

---

## 4. EXEC SQL INCLUDE — Sem Alteracao de Sintaxe

A sintaxe do `EXEC SQL INCLUDE` para DCLGENs permanece identica.
O que muda e onde o compilador a procura:

```cobol
* Ambos COBOL II e Enterprise COBOL 6.5 — mesma sintaxe
EXEC SQL
    INCLUDE BKCTCD    *> DCLGEN da tabela BANCO.CONTA
END-EXEC.

EXEC SQL
    INCLUDE SQLCA
END-EXEC.
```

**Regra:** No JCL, garantir que o DCLGEN dataset esteja na concatenacao
`SYSLIB` do compilador (nao mais no `SYSLIB` do step `DSNHPC`).

---

## 5. SQLCA e SQLCODE — Tratamento Padrao

O `SQLCA` (SQL Communications Area) e comportamento dos codigos continuam:

```cobol
EVALUATE SQLCODE
    WHEN 0
        *> Sucesso
        SET WS-FOUND TO TRUE
    WHEN 100
        *> NOT FOUND
        SET WS-NOT-FOUND TO TRUE
        MOVE 'REGISTRO NAO ENCONTRADO' TO WS-MSG-ERROR
    WHEN OTHER
        *> Erro SQL
        PERFORM 880-DB2-ERROR THRU 880-EXIT
END-EVALUATE
```

**Novas opcoes de diagnostico em EC 6.5:**

| Opcao | Descricao |
|---|---|
| `NUMCHECK(PAC)` | Verifica COMP-3 com numero par de digitos |
| `RULES(NOEVENPACK)` | Nao emite mensagem para campos DFH/DSN/EYU/SQL |

---

## 6. BIND e DBRM — Sem Alteracao

O processo de BIND do DBRM no DB2 subsystem **nao muda**. O DBRM gerado
pelo integrated coprocessor e compativel com o DB2 BIND da mesma forma
que o gerado pelo DSNHPC.

```jcl
//DSNUPROC EXEC PGM=IKJEFT01
//SYSTSPRT DD SYSOUT=*
//SYSTSIN  DD *
  DSN SYSTEM(DB2P)
  BIND PACKAGE(BANCPKG) -
       MEMBER(MYPGM)    -
       LIBRARY('BANCO.DBRMLIB') -
       ISOLATION(CS) -
       VALIDATE(BIND)
  END
/*
```

---

## 7. Checklist DB2 para Migracao

```
[ ] Step DB2PREC (DSNHPC) removido do JCL
[ ] Opcao SQL adicionada no compilador
[ ] DD DBRM adicionada no step de compilacao
[ ] SYSLIB inclui os datasets de DCLGEN
[ ] Todos os DECLARE CURSOR movidos para WORKING-STORAGE SECTION
[ ] EXEC SQL INCLUDE permanece na DATA DIVISION (sem alteracao)
[ ] BIND re-executado com os novos DBRMs gerados pelo coprocessor
[ ] Testes de regressao de todos os acessos SQL
```
