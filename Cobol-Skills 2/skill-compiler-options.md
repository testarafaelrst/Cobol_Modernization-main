# Skill: Opcoes de Compilador — COBOL II para Enterprise COBOL 6.5

> Fontes: `skill-migration-v65.md` Tables 22, 23, 46 / Ch.19 e 20 /
> `skill-perf-tuning.md` §"Compiler options that affect run-time performance"

---

## 1. Mapa de Migracao de Opcoes

### 1.1 Opcoes Removidas — Acao Obrigatoria

| Opcao COBOL II | Status em EC 6.5 | Acao |
|---|---|---|
| `RES` / `NORES` | **Removida** em EC 5+ | Remover do JCL/PROC |
| `RESIDENT` / `NORESIDENT` | **Removida** em EC 5+ | Remover do JCL/PROC |
| `CMPR2` / `NOCMPR2` | **Removida** em EC 6+ | Remover; converter programa para ANSI 85 |
| `SIZE(MAX)` | **Removida** em EC 5.2 | Remover |
| `ZONECHECK` | **Substituida** por `NUMCHECK(ZON)` | Atualizar para `NUMCHECK(ZON)` |
| `ZONEDATA` | **Substituida** por `INVDATA` | Atualizar para `INVDATA` |

> **Ref:** `skill-migration-v65.md` Table 46 "Compiler options not available in EC 5 and 6"

---

### 1.2 Opcoes Equivalentes — Migrar Normalmente

| Opcao COBOL II | Equivalente Enterprise COBOL 6.5 | Notas |
|---|---|---|
| `OPTIMIZE` | `OPT(FULL)` | `OPT(FULL)` e mais granular |
| `NOOPTIMIZE` | `OPT(0)` | Para desenvolvimento/debug |
| `NUMPROC(PFD)` | `INVDATA(NOFIXUP,NODECIMAL)` | Controle mais fino |
| `NUMPROC(NOPFD)` | `INVDATA(FIXUP,DECIMAL)` | Padrao conservador |
| `TRUNC(OPT)` | `TRUNC(OPT)` | Mantido — recomendado para CICS |
| `TRUNC(BIN)` | `TRUNC(BIN)` | Mantido |
| `TRUNC(STD)` | `TRUNC(STD)` | Padrao ANSI |
| `TEST` | `TEST(DWARF,SEPARATE)` | Debug sem overhead no load module |
| `NOTEST` | `NOTEST` | Producao |
| `RENT` | `RENT` | Obrigatorio para CICS — mantido |
| `NODYNAM` | `NODYNAM` | Calls estaticas — recomendado para CICS |
| `DYNAM` | `DYNAM` | Calls dinamicas |
| `SSRANGE` | `SSRANGE(MSG)` | Mensagem em vez de abend |
| `NOSSRANGE` | `NOSSRANGE` | Producao — sem overhead |
| `AWO` | `AWO` | Files sequenciais variavel |
| `LIB` | `LIB` | Processa COPY |
| `APOST` | `APOST` | Literais com apostrofe |
| `FASTSRT` | `FASTSRT` | SORT otimizado |

---

### 1.3 Opcoes Novas em Enterprise COBOL 6.x — Adotar

| Opcao | Versao | Descricao | Quando Usar |
|---|---|---|---|
| `CICS` | EC 5+ | Integrated CICS Translator | Todo programa CICS |
| `SQL` | EC 5+ | Integrated DB2 Coprocessor | Todo programa DB2 |
| `OPT(FULL)` | EC 5+ | Otimizacao completa | Producao |
| `ARCH(10)` | EC 6.3 | Instrucoes z15/z16 | Novo desenvolvimento |
| `TUNE(10)` | EC 6.3 | Ajuste de performance para z15/z16 | Junto com ARCH |
| `LP(64)` | EC 6.3 | Modo 64-bit (AMODE 64) | Programas grandes |
| `INVDATA` | EC 6.3 | Substitui NUMPROC + ZONEDATA | Todos os programas |
| `NUMCHECK` | EC 6.2 | Detecta dados invalidos em compile time | Qualidade de codigo |
| `INITCHECK` | EC 6.2 | Detecta variaveis nao inicializadas | Qualidade de codigo |
| `PARMCHECK` | EC 6.2 | Verifica tipos de parametros em CALLs | Qualidade de codigo |
| `SMARTBIN` | EC 6.4 | Metadados para IBM ABO | Producao estavel |
| `CONDCOMP` | EC 6.4 | Compilacao condicional | Codigo multiplos ambientes |

---

## 2. PARM de Compilacao Recomendado

### 2.1 COBOL II (original)
```jcl
//COBCOMP  EXEC PGM=IGYCRCTL,
//         PARM='APOST,LIB,RENT,RES,OPT,NODYNAM,NODECK'
```

### 2.2 Enterprise COBOL 6.5 — Minimo para migracao
```jcl
//COBCOMP  EXEC PGM=IGYCRCTL,
//         PARM='APOST,LIB,RENT,OPT(FULL),NODYNAM,NODECK,NOSSRANGE'
*                                ^^^^^^^^^                ^^^^^^^^^
*                     RES removido         SIZE removido
```

### 2.3 Enterprise COBOL 6.5 — Programa CICS + DB2 (recomendado)
```jcl
//COBCOMP  EXEC PGM=IGYCRCTL,
//         PARM='APOST,LIB,RENT,OPT(FULL),NODYNAM,NODECK,NOSSRANGE',
//         PARM='CICS(''COBOL2''),SQL,ARCH(10),TUNE(10),TRUNC(OPT)',
//         PARM='INVDATA(NOFIXUP),NUMCHECK,INITCHECK,TEST(NODWARF)'
```

> **Nota:** Em compilacoes longas, use `CEEOPTS DD` para opcoes LE em vez
> de incluir tudo no `PARM` do JCL.

---

## 3. Opcao `INVDATA` — Substitui `NUMPROC` e `ZONEDATA`

| COBOL II | Enterprise COBOL 6.5 | Comportamento |
|---|---|---|
| `NUMPROC(PFD)` | `INVDATA(NOFIXUP,NODECIMAL)` | Assume dado correto — maximo performance |
| `NUMPROC(NOPFD)` | `INVDATA(FIXUP,DECIMAL)` | Corrige sinal — compatibilidade maxima |
| `NUMPROC(MIG)` | `INVDATA(FIXUP,NODECIMAL)` | Corrige apenas receivers |
| `ZONEDATA(PFD)` | `INVDATA(NOFIXUP)` | Zoned decimal sem fix-up |
| `ZONEDATA(MIG)` | `INVDATA(FIXUP)` | Zoned decimal com fix-up |

**Recomendacao de migracao:**
1. Comece com `INVDATA(FIXUP,DECIMAL)` — comportamento mais conservador,
   equivalente a `NUMPROC(NOPFD)`.
2. Teste de regressao completo.
3. Avance para `INVDATA(NOFIXUP,NODECIMAL)` em programas que confirmam
   dados sempre validos (equivale a `NUMPROC(PFD)` — melhor performance).

---

## 4. Opcao `OPT` — Performance em Producao

| COBOL II | Enterprise COBOL 6.5 | Efeito |
|---|---|---|
| `OPTIMIZE` | `OPT(FULL)` | Todas as otimizacoes disponiveis |
| `NOOPTIMIZE` | `OPT(0)` | Sem otimizacao (desenvolvimento) |
| — | `OPT(1)` | Otimizacoes basicas de fluxo |
| — | `OPT(2)` | Otimizacoes de storage e dados |

> **Ref:** `skill-perf-tuning.md` §"OPTIMIZE or NOOPTIMIZE"

**Importante:** `OPT(FULL)` com `TEST` provoca conflito — o compilador
desativa automaticamente otimizacoes incompativeis com debug.
Para debug em producao: `TEST(DWARF,SEPARATE)` + `OPT(FULL)`.

---

## 5. Opcoes de Diagnostico — Qualidade de Codigo

### `NUMCHECK` — dados numericos invalidos
```jcl
NUMCHECK(PAC,ZON,BIN)  *> verifica COMP-3, DISPLAY e BINARY
```
Detecta em compile time dados com sinal errado, zone bits invalidos ou
valores fora do range do PIC.

### `INITCHECK` — variaveis nao inicializadas
```jcl
INITCHECK(STRICT)  *> erro se qualquer caminho logico nao inicializa
INITCHECK(LAX)     *> aviso apenas se nenhum caminho inicializa
```

### `PARMCHECK` — tipos de parametros em CALL
```jcl
PARMCHECK(MSG)  *> aviso de incompatibilidade de tipos
PARMCHECK(ABD)  *> abend em incompatibilidade de tipos
```

---

## 6. ARCH e TUNE — Geracao de Codigo para Hardware Atual

| Opcao | Hardware Alvo | Recomendacao |
|---|---|---|
| `ARCH(10)` | z14 | Default em EC 6.4 |
| `ARCH(11)` | z15 | z15 e posterior |
| `ARCH(12)` | z16 | z16 e posterior |
| `ARCH(13)` | EC 6.3+ | Futuro |
| `TUNE(10)` | z14 | Junto com ARCH(10) |
| `TUNE(11)` | z15 | Junto com ARCH(11) |

> Usar `ARCH` e `TUNE` correspondentes ao hardware de execucao produz
> codigo com instrucoes vetoriais e SIMD que podem melhorar performance
> de loops e operacoes de string em ate 30-50%.
>
> **Ref:** `skill-migration-v65.md` §Ch.19 "Compiler option changes in EC 6"
