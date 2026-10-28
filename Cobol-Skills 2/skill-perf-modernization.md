# Skill: Performance — COBOL II para Enterprise COBOL 6.5

> Fontes: `skill-perf-tuning.md` (completo) /
> `skill-migration-v65.md` §Ch.19 "Changes with EC 6" e Appendix A "FAQ / Performance"

---

## 1. O que Muda na Performance de COBOL II para EC 6.5

Enterprise COBOL 6.5 traz melhorias significativas de performance em
relacao ao COBOL II, especialmente em:

| Area | Ganho Tipico | Mecanismo |
|---|---|---|
| Codigo numerico COMP-3 | 10-30% | Instrucoes DFP (Decimal Floating Point) do z/OS |
| Loops e tabelas | 20-50% | Vetorizacao automatica com ARCH(10+) |
| Operacoes de string | 15-25% | Instrucoes SIMD vetoriais |
| Chamadas de subprograma | 5-15% | Reducao de overhead do enclave LE |
| Compilacao | 2-3x mais rapida | Compilador EC 6.5 usa armazenamento acima da barra |

---

## 2. Opcoes de Compilador para Performance

### 2.1 Substituicoes Obrigatorias

| COBOL II | EC 6.5 | Impacto |
|---|---|---|
| `OPTIMIZE` | `OPT(FULL)` | Melhor otimizacao disponivel |
| `NUMPROC(PFD)` | `INVDATA(NOFIXUP,NODECIMAL)` | Elimina sign fix-up — ate +15% |
| `TRUNC(OPT)` | `TRUNC(OPT)` | Mantido — recomendado para CICS |
| `NOSSRANGE` | `NOSSRANGE` | Elimina overhead de verificacao de bounds |
| `NODYNAM` | `NODYNAM` | Calls estaticas — menor overhead |

### 2.2 Novas Opcoes de Performance em EC 6.5

```jcl
*-- Configuracao de producao recomendada:
PARM='OPT(FULL),ARCH(10),TUNE(10),TRUNC(OPT),NOSSRANGE,NODYNAM'
PARM='INVDATA(NOFIXUP,NODECIMAL),RENT,LIB,NOTEST'
```

**`ARCH(n)` e `TUNE(n)`:**
Geram instrucoes especificas do hardware, incluindo:
- Instrucoes vetoriais SIMD para loops
- DFP para aritmetica decimal (COMP-3)
- Instrucoes de string aceleradas por hardware

> **Ref:** `skill-perf-tuning.md` §"OPTIMIZE or NOOPTIMIZE" e §"TRUNC"

---

## 3. Tecnicas de Codificacao para Performance

### 3.1 Tipos de Dados — Regras de Ouro

| Tipo | Uso Recomendado | Por que |
|---|---|---|
| `PIC S9(4) BINARY` | Contadores, subscripts, campos de controle | Instrucoes halfword — mais rapidas |
| `PIC S9(8) BINARY` | Acumuladores, totais moderados | Instrucoes fullword |
| `PIC S9(15) COMP-3` | Valores monetarios, calculos decimais | DFP no EC 6.5 — instrucoes nativas |
| `PIC S9(9) BINARY` | **Evitar** — fullword converte para doubleword | +1 instrucao de conversao |
| `PIC 9(n) DISPLAY` | **Nao usar em calculos** — overhead de conversao | Requer library routine call |

> **Ref:** `skill-perf-tuning.md` §"Data Types"

**Exemplo de otimizacao:**
```cobol
* LENTO — DISPLAY requer conversao
01  WS-CONTADOR  PIC 9(4) DISPLAY.
PERFORM VARYING WS-CONTADOR FROM 1 BY 1
    UNTIL WS-CONTADOR > 1000

* RAPIDO — BINARY usa instrucoes halfword diretas
01  WS-CONTADOR  PIC S9(4) BINARY.
PERFORM VARYING WS-CONTADOR FROM 1 BY 1
    UNTIL WS-CONTADOR > 1000
```

---

### 3.2 Tabelas — INDEX vs SUBSCRIPT

```cobol
* SUBSCRIPT — calcula deslocamento em cada acesso (mais lento)
01  WS-TABELA.
    12  WS-ITEM OCCURS 100 PIC X(10).
01  WS-SUB  PIC S9(4) BINARY.

MOVE WS-ITEM(WS-SUB) TO WS-DESTINO.
*-- WS-SUB contem numero de ocorrencia: converte para offset em runtime

* INDEX — offset pre-calculado (mais rapido)
01  WS-TABELA.
    12  WS-ITEM OCCURS 100 INDEXED BY WS-IDX PIC X(10).

SET WS-IDX TO 5
MOVE WS-ITEM(WS-IDX) TO WS-DESTINO.
*-- WS-IDX ja contem o offset: sem conversao em runtime
```

> **Ref:** `skill-perf-tuning.md` §"Data Types — indexes vs subscripts"

---

### 3.3 COMP-3 — Regras de Precisao

```cobol
* BOAS PRATICAS PARA COMP-3 EM EC 6.5:

* 1. Numero impar de digitos (usa numero inteiro de bytes)
01  WS-VALOR  PIC S9(13)V99 COMP-3.   *> 8 bytes - eficiente

* 2. Maximo 15 digitos para multiplicacao/divisao inline
01  WS-BASE   PIC S9(15)    COMP-3.   *> calculo inline (sem library call)
01  WS-GRANDE PIC S9(17)    COMP-3.   *> pode chamar library routine

* 3. Evitar 16 digitos (par, e menos eficiente)
01  WS-RUIM   PIC S9(16)    COMP-3.   *> evitar — par e grande
```

> **Ref:** `skill-perf-tuning.md` §"Data Types — packed decimal COMP-3"

---

### 3.4 Estrutura do Programa — Impacto no Otimizador

```cobol
* BOM para o otimizador — codigo estruturado, sem GO TO irregular:
EVALUATE TRUE
    WHEN WS-CONDICAO-A
        PERFORM 200-PROCESSA-A THRU 200-EXIT
    WHEN WS-CONDICAO-B
        PERFORM 300-PROCESSA-B THRU 300-EXIT
END-EVALUATE

* RUIM para o otimizador — GO TO interrompe o fluxo de otimizacao:
IF WS-CONDICAO-A
    GO TO 200-PROCESSA-A
IF WS-CONDICAO-B
    GO TO 300-PROCESSA-B
```

O compilador EC 6.5 com `OPT(FULL)` pode mover paragraphs de PERFORM
inline quando o fluxo e estruturado — reducao de overhead de call.

> **Ref:** `skill-perf-tuning.md` §"Program Design — coding style and optimizer"

---

### 3.5 SEARCH vs SEARCH ALL

```cobol
* SEARCH (sequencial) — O(n) — para tabelas pequenas ou nao-ordenadas
SEARCH WS-ITEM
    AT END MOVE 'N' TO WS-FOUND-SW
    WHEN WS-ITEM-KEY(WS-IDX) = WS-CHAVE
        MOVE 'Y' TO WS-FOUND-SW
END-SEARCH

* SEARCH ALL (binario) — O(log n) — para tabelas grandes ORDENADAS
* Requer ASCENDING/DESCENDING KEY na definicao da tabela
SEARCH ALL WS-ITEM
    AT END MOVE 'N' TO WS-FOUND-SW
    WHEN WS-ITEM-KEY(WS-IDX) = WS-CHAVE
        MOVE 'Y' TO WS-FOUND-SW
END-SEARCH
```

> **Ref:** `skill-perf-tuning.md` §"Program Design — SEARCH statement"

---

## 4. Opcao SMARTBIN — IBM Automatic Binary Optimizer (ABO)

Disponivel em EC 6.4+, a opcao `SMARTBIN` inclui metadados no load module
que permitem ao IBM ABO otimizar o modulo **sem recompilacao**:

```jcl
PARM='OPT(FULL),ARCH(10),TUNE(10),SMARTBIN,...'
```

**Beneficio:** Modulos ja compilados e em producao podem ser otimizados
pelo ABO para hardware futuro (z16, z17...) sem alterar o codigo-fonte.

> **Ref:** `skill-migration-v65.md` §Ch.19 "Improved integration with IBM ABO"

---

## 5. Performance em Ambientes CICS

Recomendacoes especificas para programas CICS (fonte: `skill-perf-tuning.md` §"CICS"):

| Opcao | Recomendacao | Motivo |
|---|---|---|
| `TRUNC(OPT)` | **Usar** se dados BINARY estao corretos | Elimina divisoes por potencia de 10 |
| `NODYNAM` | **Usar** | Calls estaticas sao mais rapidas que dinamicas |
| `RENT` | **Obrigatorio** | Reentrada para execucao paralela |
| `OPT(FULL)` | **Usar** | Maxima otimizacao |
| `NOSSRANGE` | **Usar em producao** | Elimina overhead de verificacao de bounds |
| `NOTEST` | **Usar em producao** | Elimina codigo de debug |
| `ARCH(10)+TUNE(10)` | **Usar** | Instrucoes nativas do hardware atual |

---

## 6. Checklist de Performance para Migracao

```
COMPILACAO
[ ] OPT(FULL) no lugar de OPTIMIZE
[ ] ARCH(10) e TUNE(10) adicionados
[ ] TRUNC(OPT) verificado (dados BINARY conformes ao PIC)
[ ] NOSSRANGE em producao
[ ] NOTEST em producao
[ ] INVDATA(NOFIXUP,NODECIMAL) se dados sao sempre validos

CODIGO
[ ] Variaveis de loop e subscripts declarados como PIC S9(4) BINARY
[ ] Campos COMP-3 com numero impar de digitos
[ ] COMP-3 com no maximo 15 digitos para calculo inline
[ ] INDEX usado em vez de SUBSCRIPT para tabelas de alta frequencia
[ ] SEARCH ALL para tabelas grandes e ordenadas
[ ] Sem USAGE DISPLAY em areas de calculo intenso
[ ] Estrutura de programa sem GO TO irregular

PROFILING
[ ] Medir CPU time antes e apos a migracao (referencia de regressao)
[ ] Usar RMF/SMF para baseline de producao
[ ] Comparar com NOTEST vs TEST para quantificar overhead de debug
```
