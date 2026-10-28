# BKC01 — Correlação de Statements COBOL II → Enterprise COBOL 6.5

> **Referências:**
> - [`skill-migration-v65.md`](../Cobol-Skills/skill-migration-v65.md) — Cap. 11, 24, 25 e Appendix C
> - [`skill-perf-tuning.md`](../Cobol-Skills/skill-perf-tuning.md) — Compiler options / Run-time options
> - [`skill-cics-standards.md`](../Cobol-Skills/skill-cics-standards.md) — Special Considerations, Error Handling
> - [`skill-le-runtime.md`](../Cobol-Skills/skill-le-runtime.md) — LE considerations / COBOL considerations

---

## 1. Resumo Executivo

O programa [`BKC01.cbl`](src/BKC01.cbl) foi escrito em COBOL II (VS COBOL II) com padrão CICS
execute-level e acesso DB2. A migração para Enterprise COBOL 6.5 exige **7 correções obrigatórias**
e **5 melhorias recomendadas** listadas nas seções abaixo.

| Severidade | Qtd | Descrição |
|---|---|---|
| 🔴 **Obrigatória** | 7 | Falha de compilação ou comportamento incorreto em COBOL 6.5 |
| 🟡 **Recomendada** | 5 | Deprecações ou padrões substituídos; compilam mas geram warnings |
| 🟢 **Compatível** | — | Statements que funcionam sem alteração |

---

## 2. Mapeamento Statement a Statement

### 2.1 IDENTIFICATION DIVISION

| Linha | Construto COBOL II | Status | Equivalente Enterprise COBOL 6.5 | Referência |
|---|---|---|---|---|
| 37 | `*PROGRAM-TITLE.` | 🟡 Deprecated | Remover — não é palavra reservada em 6.5; manter só como comentário puro `*` | `skill-migration-v65.md` §Ch.11 "New reserved words" |
| 38 | `*AUTHOR.` | 🟡 Deprecated | Idem — `AUTHOR` continua aceito mas foi removido do padrão ANSI 85; usar comentário `*` | `skill-migration-v65.md` §Ch.11 |
| 39 | `*DATE-WRITTEN.` | 🟡 Deprecated | Idem — `DATE-WRITTEN` foi removido do padrão; manter como comentário `*` | `skill-migration-v65.md` §Ch.11 |

> **Impacto:** Os três já estão comentados com `*` na coluna 7, portanto são ignorados pelo
> compilador. Nenhuma mudança de código é necessária — mas documentar a intenção é boa prática.

---

### 2.2 ENVIRONMENT DIVISION

| Linha | Construto COBOL II | Status | Equivalente Enterprise COBOL 6.5 | Referência |
|---|---|---|---|---|
| 44 | `ENVIRONMENT DIVISION.` (vazia) | 🟢 Compatível | Permitida vazia; o compilador gera aviso informativo apenas. Pode ser omitida. | `skill-cics-standards.md` §"Environment Division" |

---

### 2.3 DATA DIVISION — WORKING-STORAGE

| Linha | Construto COBOL II | Status | Equivalente Enterprise COBOL 6.5 | Referência |
|---|---|---|---|---|
| 62–63 | `01 WSBK-BEGINS PIC X(16) VALUE 'BKC01 WS BEGINS'.` | 🟢 Compatível | Mantido. Boa prática para identificar WS em dumps. | `skill-cics-standards.md` §"Working-Storage Section §3" |
| 91 | `PIC S9(4) VALUE -1 COMP.` | 🟡 Recomendada | `COMP` em COBOL II = `BINARY`. Em 6.5 continua válido; preferência pelo termo `BINARY` ou `COMP-4` para clareza | `skill-migration-v65.md` §Ch.11 "85 COBOL Standard changes" |
| 100 | `PIC S9(15) COMP-3.` | 🟢 Compatível | `COMP-3` (PACKED-DECIMAL) suportado sem alteração | — |
| 109 | `01 WSBK-CICS-RESP PIC S9(8) COMP.` | 🟡 Recomendada | Tipo correto para RESP. Em 6.5 preferir `BINARY` explícito. Funcionalmente idêntico. | `skill-migration-v65.md` §"CMPR2 compiler option" |
| 119–128 | `OCCURS 5 TIMES INDEXED BY WSBK-EXT-IDX` com `VALUE` em subordinados | 🔴 **Obrigatória** | Em COBOL II com `CMPR2`, `VALUE` em itens subordinados de `OCCURS` era aceito. Em Enterprise COBOL 6.5 sem `CMPR2`, `VALUE` em subordinados de `OCCURS` causa **IKF2066S** (compilação falha). Mover as inicializações para `PROCEDURE DIVISION` ou usar `INITIALIZE`. | `skill-migration-v65.md` §Ch.11 "85 COBOL Standard interpretation changes" / Table 26 |
| 131–146 | `EXEC SQL INCLUDE BKAGCD/BKCTCD/BKEXCD END-EXEC.` | 🔴 **Obrigatória** | Em 6.5 com o **DB2 Coprocessor integrado** (sem pré-compilador separado), o `EXEC SQL INCLUDE` é processado diretamente. O JCL deve usar o compilador com `COPROCESSOR` em vez do step `DSNHPC`. A sintaxe do `INCLUDE` permanece idêntica. | `skill-migration-v65.md` §Ch.25 "Db2 coprocessor integration" |
| 149 | `COPY BKCON01.` | 🟢 Compatível | `COPY` sem restrições em 6.5. | — |
| 152 | `COPY DFHBMSCA.` | 🟢 Compatível | Copybook IBM fornecido pela CICS; sem mudança. | — |
| 155 | `COPY DFHAID.` | 🟢 Compatível | Copybook IBM fornecido pela CICS; sem mudança. | — |

---

### 2.4 DATA DIVISION — LINKAGE SECTION

| Linha | Construto COBOL II | Status | Equivalente Enterprise COBOL 6.5 | Referência |
|---|---|---|---|---|
| 162 | `01 DFHCOMMAREA PIC X(900).` | 🟢 Compatível | Sem alteração. Exigido pelo CICS para pseudo-conversação. | `skill-cics-standards.md` §"Linkage Section §1" |

---

### 2.5 PROCEDURE DIVISION — Estrutura e Controle

| Linhas | Construto COBOL II | Status | Equivalente Enterprise COBOL 6.5 | Referência |
|---|---|---|---|---|
| 174–199 | `PERFORM … THRU …-EXIT` / `EVALUATE TRUE` | 🟢 Compatível | `PERFORM THRU` e `EVALUATE` suportados sem mudança. | — |
| 201–206 | `EXEC CICS RETURN TRANSID(…) COMMAREA(…) LENGTH(900) RESP(…) END-EXEC` | 🟢 Compatível | Syntax e semântica idênticas em 6.5. | `skill-cics-standards.md` §"RETURN" |
| 208 | `STOP RUN.` em programa CICS | 🔴 **Obrigatória** | Em CICS COBOL II `STOP RUN` era tolerado mas retornava ao SO, não ao CICS. Em Enterprise COBOL 6.5 sob LE, `STOP RUN` encerra o enclave LE — **pode causar abend S0C4 ou loop** se atingido. Substituir por `EXEC CICS RETURN END-EXEC` ou remover (já existe RETURN na linha 201). | `skill-cics-standards.md` §"Special Considerations — STOP RUN" / `skill-migration-v65.md` §Ch.24 "CICS conversion" |
| 222–226 | `IF EIBCALEN = ZERO … ELSE … END-IF` | 🟢 Compatível | `EIBCALEN` disponível via DFHEIBLK; sem mudança. | — |
| 354–390 | `MOVE 'Y' TO WSBK-EDIT-ERROR-SW` (atribuição direta em vez de `SET`) | 🟡 Recomendada | Funcional, mas `SET condition-name TO TRUE/FALSE` é o idiom correto em 85 Standard (já usado em outros lugares do programa — inconsistência). | `skill-migration-v65.md` §Ch.11 "85 COBOL Standard" |

---

### 2.6 SQL — DB2 Statements

| Linhas | Construto COBOL II | Status | Equivalente Enterprise COBOL 6.5 | Referência |
|---|---|---|---|---|
| 429–440 | `EXEC SQL SELECT … INTO … FROM … WHERE … END-EXEC` (singleton) | 🟢 Compatível | Sintaxe DB2 SQL inalterada. Com coprocessor integrado, `SQLCODE` e `SQLCA` são gerados automaticamente. | `skill-migration-v65.md` §Ch.25 |
| 526–540 | `EXEC SQL DECLARE CSREXTRATO CURSOR FOR … FETCH FIRST 5 ROWS ONLY END-EXEC` | 🔴 **Obrigatória** | `DECLARE CURSOR` **deve estar na WORKING-STORAGE** quando o DB2 Coprocessor integrado é usado (não na Procedure Division como no pré-compilador antigo). Mover a declaração para a Working-Storage Section. | `skill-migration-v65.md` §Ch.25 "Differences between Db2 precompiler and integrated Db2 coprocessor" |
| 542–544 | `EXEC SQL OPEN CSREXTRATO END-EXEC` | 🟢 Compatível | Sem mudança. | — |
| 546–549 | `IF SQLCODE NOT = 0 … GO TO 530-EXIT END-IF` | 🟡 Recomendada | `GO TO` para parágrafo de saída é o único `GO TO` aceito pelo padrão ISU-ATS e por boas práticas. Funcionalmente correto; manter. | `skill-cics-standards.md` §"Go To Statements" |
| 552–580 | `PERFORM UNTIL SQLCODE NOT = 0 OR WSBK-EXTRATO-CTR = 5` com `FETCH` interno | 🟢 Compatível | Padrão de loop com cursor DB2 — sem mudança. | — |
| 582–584 | `EXEC SQL CLOSE CSREXTRATO END-EXEC` | 🟢 Compatível | Sem mudança. | — |

---

### 2.7 EXEC CICS Commands

| Linhas | Comando CICS | Status | Observação para 6.5 | Referência |
|---|---|---|---|---|
| 252–260 | `EXEC CICS SEND MAP … ERASE FREEKB CURSOR RESP(…) END-EXEC` | 🟢 Compatível | Sem mudança. | `skill-cics-standards.md` §"SEND" |
| 283–291 | `EXEC CICS SEND MAP … ERASE FREEKB CURSOR RESP(…) END-EXEC` | 🟢 Compatível | Idem. | — |
| 330–335 | `EXEC CICS RECEIVE MAP … INTO … RESP(…) END-EXEC` | 🟢 Compatível | Sem mudança. | `skill-cics-standards.md` §"RECEIVE" |
| 657–664 | `EXEC CICS SEND MAP … FREEKB CURSOR RESP(…) END-EXEC` (sem ERASE) | 🟢 Compatível | Correto para reenvio sem apagar tela. | — |
| 679–683 | `EXEC CICS XCTL PROGRAM … COMMAREA … RESP(…) END-EXEC` | 🟢 Compatível | Sem mudança. | `skill-cics-standards.md` §"XCTL" |
| 706–710 | `EXEC CICS DUMP TASK DUMPCODE('BKD2') RESP(…) END-EXEC` | 🟢 Compatível | Sem mudança em 6.5. | `skill-cics-standards.md` §"DUMP" |
| 720–722 | `EXEC CICS ABEND ABCODE(…) END-EXEC` | 🟢 Compatível | Sem mudança. | `skill-cics-standards.md` §"ABEND" |
| 732–735 | `EXEC CICS ASKTIME ABSTIME(…) RESP(…) END-EXEC` | 🟢 Compatível | Sem mudança. Correto para obter data/hora via CICS (não DATE/TIME registers). | `skill-cics-standards.md` §"Date and Time" |
| 742–747 | `EXEC CICS FORMATTIME ABSTIME … DDMMYYYY … DATESEP('/') RESP(…) END-EXEC` | 🟢 Compatível | Sem mudança. | — |

---

### 2.8 CICS Translator — Mudança de Compilação

| Aspecto | COBOL II | Enterprise COBOL 6.5 | Referência |
|---|---|---|---|
| **Translator** | Step separado `DFHECP1$` no JCL (CICSTRAN) | **Integrated CICS Translator** — ativado pela opção de compilador `CICS('…')` | `skill-migration-v65.md` §Ch.24 "Migrating from the separate CICS translator to the integrated translator" |
| **Opção compilador** | `PARM='COBOL2,CICS'` no step DFHECP1$ | `CICS('COBOL2')` ou `CICS` na opção do compilador `IGYCRCTL` | `skill-migration-v65.md` Table 52/53 |
| **DFHEIBPTR** | Gerado implicitamente pelo translator | Gerado pelo integrated translator; comportamento idêntico | — |

---

### 2.9 JCL — Opções de Compilador

| Opção COBOL II (IGYCRCTL) | Status em 6.5 | Equivalente / Ação |
|---|---|---|
| `APOST` | 🟢 Compatível | Mantido |
| `LIB` | 🟢 Compatível | Mantido (processa `COPY`) |
| `RENT` | 🟢 Compatível | Obrigatório para CICS; mantido |
| `RES` | 🔴 **Removida** | `RES`/`NORES` foram eliminados em Enterprise COBOL 5+. Remover do PARM. | `skill-migration-v65.md` Table 46 "Compiler options not available in EC 5 and 6" |
| `OPT` | 🟢 Compatível | Continua válido; em 6.5 usar `OPT(FULL)` para otimização máxima | `skill-perf-tuning.md` §"OPTIMIZE" |
| `NODYNAM` | 🟢 Compatível | Correto para CICS (static calls). Mantido. | `skill-perf-tuning.md` §"DYNAM" |
| `NODECK` | 🟢 Compatível | Mantido |
| *(ausente)* `CICS` | 🔴 **Obrigatória** | Adicionar opção `CICS` para ativar integrated translator (substituir step CICSTRAN) | `skill-migration-v65.md` §Ch.24 |
| *(ausente)* `SQL` ou `COPROCESSOR` | 🔴 **Obrigatória** | Adicionar opção `SQL` (ou `COPROCESSOR`) para ativar integrated DB2 coprocessor (substituir step DB2PREC) | `skill-migration-v65.md` §Ch.25 |
| *(ausente)* `ARCH(10)` | 🟡 Recomendada | Adicionar para geração de código otimizado para z15/z16 | `skill-perf-tuning.md` §"OPTIMIZE" |

---

## 3. Checklist de Migração — Prioridade

```
[OBRIGATORIO] ✅ 1. Remover opcao compilador RES do JCL BKJCL01J (step COBCOMP)
[OBRIGATORIO] ✅ 2. Remover step CICSTRAN (DFHECP1$); adicionar opcao CICS no compilador
[OBRIGATORIO] ✅ 3. Remover step DB2PREC  (DSNHPC);   adicionar opcao SQL  no compilador
[OBRIGATORIO] ✅ 4. Mover DECLARE CURSOR (linhas 526-540) para WORKING-STORAGE SECTION
[OBRIGATORIO] ✅ 5. Remover/reposicionar STOP RUN (linha 208) - substituir por comentario
[OBRIGATORIO] ✅ 6. Remover VALUE de itens subordinados em OCCURS (linhas 122-128)
                    Substituir por INITIALIZE em 100-INITIALIZE ou em 530-READ-EXTRATO
[OBRIGATORIO] ✅ 7. Adicionar RESP(WSBK-CICS-RESP) no EXEC CICS ABEND (linha 720)
                    (ABEND sem RESP pode gerar aviso W em 6.5)

[RECOMENDADO] ○ 8. Substituir COMP por BINARY nas linhas 91, 95, 109
[RECOMENDADO] ○ 9. Substituir MOVE 'Y'/'N' TO WSBK-EDIT-ERROR-SW por SET … TO TRUE (linhas 356,362,373,380,389)
[RECOMENDADO] ○ 10. Adicionar ARCH(10) e TUNE(ZARCH) no PARM do compilador
[RECOMENDADO] ○ 11. Adicionar STGOPT no PARM (Storage Optimization - 6.5 novidade)
[RECOMENDADO] ○ 12. Verificar palavra reservada FUNCTION - nao usada no programa (sem conflito)
```

---

## 4. Garantia de Equivalência Funcional

| Area | Equivalência garantida? |
|---|---|
| Logica de negocio (consulta agencia/conta/extrato) | ✅ Sim |
| Tela BMS (BKCONS0 / BKCON01) | ✅ Sim — BMS mapset nao muda |
| SQL DB2 (SELECT, CURSOR, FETCH, OPEN, CLOSE) | ✅ Sim — sintaxe SQL identica |
| EXEC CICS (SEND, RECEIVE, RETURN, XCTL, ASKTIME, FORMATTIME) | ✅ Sim |
| Tratamento de erros via RESP | ✅ Sim |
| `STOP RUN` linha 208 | ⚠️ **Nao garantida** — nunca deve ser atingido, mas deve ser removido |
| `VALUE` em subordinados de `OCCURS` | ⚠️ **Nao garantida** — falha de compilacao em NOCMPR2 |
| `DECLARE CURSOR` na Procedure Division | ⚠️ **Nao garantida** — erro com DB2 Coprocessor integrado |

---

## 5. Programa Corrigido

Veja [`BKC01V65.cbl`](src/BKC01V65.cbl) — versão do programa com todas as
correções obrigatórias aplicadas e melhorias recomendadas indicadas por comentários `*>>`.
