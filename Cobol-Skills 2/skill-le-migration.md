# Skill: Migracao Language Environment — COBOL II para EC 6.5

> Fontes: `skill-le-runtime.md` Ch.1 e 2 /
> `skill-migration-v65.md` §Ch.20 "Language Environment option changes" e §Ch.21

---

## 1. Visao Geral: De COBOL II Runtime para LE

Em COBOL II, o runtime era gerenciado por modulos proprios (`IGZ*`).
Em Enterprise COBOL 6.5, o runtime e o **IBM Language Environment (LE)**,
compartilhado com PL/I, C/C++ e Fortran — formando um ambiente unificado.

```
COBOL II Runtime (IGZ*)          Language Environment (CEE*)
================================ ================================
IGZERRE  - init/term runtime  -> CEEPIPI  - init/term enclave
IGZETUN  - condicao handler   -> CEESIGT  - registra condicao handler
IGZCLOC  - data/hora runtime  -> CEEDATM  - data/hora LE
IGZCPAC  - library COBPACK    -> CEE.SCEERUN (LE library)
IGZEPCL  - library (CICS)     -> CEE.SCEERUN (automatico)
RTEREUS  - reuse runtime      -> TRAP(ON,NOSPIE) + CEEBXITA
LIBKEEP  - manter library     -> CEEBXITA exit ou TRAP(ON)
STAE     - intercept abend    -> CEEHDLR (condition handler)
NOSTAE   - sem intercept      -> TRAP(OFF)
```

---

## 2. Chamadas de Runtime — Tabela de Substituicao

### 2.1 `IGZERRE` → `CEEPIPI`
**COBOL II:** Inicializava e terminava o runtime VS COBOL II a partir de
programa nao-COBOL (driver assembler ou PL/I).

```cobol
* COBOL II
01 WS-FUNC  PIC X(2) VALUE 'IN'.   *> 'IN'=init 'TM'=term
CALL 'IGZERRE' USING WS-FUNC.

* Enterprise COBOL 6.5 com LE
* CEEPIPI e a interface padrao LE para inicializar enclave
* Consultar skill-le-runtime.md Ch.2 "Downward compatibility considerations"
* Para a maioria dos casos, LE inicializa automaticamente — nao e necessario
* chamar CEEPIPI explicitamente em programas COBOL sob CICS ou batch z/OS.
```

> **Ref:** `skill-le-runtime.md` §Ch.2 "HLL compatibility considerations /
> COBOL considerations"

---

### 2.2 `IGZETUN` — Condition Handler
**COBOL II:** Registrava rotina para interceptar condicoes (semelhante a ESTAE).

```cobol
* COBOL II
CALL 'IGZETUN' USING WS-HANDLER-ADDR.

* Enterprise COBOL 6.5 com LE
* Usar CEEHDLR para registrar condition handler LE
01 WS-TOKEN  PIC S9(9) BINARY VALUE ZERO.
CALL 'CEEHDLR' USING MY-HANDLER-RTN
                     WS-TOKEN
                     FC.
```

---

### 2.3 Opcao `RTEREUS` → Comportamento LE equivalente
**COBOL II:** `RTEREUS` mantinha o ambiente COBOL inicializado entre
invocacoes, tratando cada programa COBOL como subrotina.

**Enterprise COBOL 6.5:** O LE gerencia o ciclo de vida do enclave
automaticamente. Para reuse semantics, usar:
- `TRAP(ON,NOSPIE)` na opcao runtime LE
- Ou `CEEBXITA` exit para controle do ciclo de vida

> **Ref:** `skill-le-runtime.md` §Ch.2 "Planning to link-edit and run"

---

### 2.4 `LIBKEEP` → LE carrega automaticamente
**COBOL II:** `LIBKEEP` mantinha os modulos `IGZ*` em storage apos a
primeira carga, evitando reload para cada programa.

**Enterprise COBOL 6.5:** O LE (CEE.SCEERUN) e mantido automaticamente
em storage enquanto o enclave esta ativo. Nao ha equivalente direto
porque o comportamento padrao do LE ja incorpora o que `LIBKEEP` fazia.

---

## 3. Opcoes de Runtime — Comparativo

| COBOL II (IGZOPT) | Language Environment (CEEDOPT / CEEOPTS) |
|---|---|
| `RTEREUS` | `REUSE` (simulado via configuracao LE) |
| `LIBKEEP` | Comportamento padrao do LE |
| `STAE` | `TRAP(ON)` — padrao |
| `NOSTAE` | `TRAP(OFF)` |
| `WSCLEAR` | `STORAGE(00,00,00)` — zera WS |
| `SSRANGE` | Ativado pelo compilador com opcao `SSRANGE` |
| `MIXRES` | Nao necessario — LE gerencia tudo |
| `SPOUT` | Dump de space management — substituido por LE dump |

---

## 4. STEPLIB / Link-Edit — Mudancas de Libraries

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
//       DD DSN=CEE.SCEECICS,DISP=SHR           *> LE CICS (se aplicavel)
```

> **Regra:** Nunca misturar `COB2.SCOB2LKE` (COBOL II runtime) com
> `CEE.SCEERUN` (LE runtime) no mesmo STEPLIB concatenation.
> `skill-le-runtime.md` §Ch.2 "Downward compatibility considerations"

---

## 5. AMODE e Consideracoes de Enderecamento

| Modo | COBOL II | Enterprise COBOL 6.5 |
|---|---|---|
| `AMODE 24` | Suportado (dados abaixo de 16MB) | Deprecado — evitar |
| `AMODE 31` | Padrao | Padrao (LP(32)) |
| `AMODE 64` | Nao suportado | Disponivel com `LP(64)` em EC 6.3+ |

**Migracao para 64-bit:**
- Declarar pointeiros como `USAGE POINTER` (4 bytes em AMODE 31)
  ou `USAGE POINTER-64` para AMODE 64
- `POINTER-32` disponivel para compatibilidade em modo LP(64)
- Verificar `DATA(31)` vs `DATA(24)` para localizacao do WS

> **Ref:** `skill-le-runtime.md` §Ch.2 "C/C++ AMODE/RMODE considerations" /
> `skill-migration-v65.md` §Ch.20 "AMODE and RMODE considerations"

---

## 6. Dump e Diagnostico

| COBOL II | Enterprise COBOL 6.5 |
|---|---|
| `IGZSNAP` — dump do WS | `CEEDUMP` — LE structured dump |
| `IGZDUMP` — dump completo | LE SYSMDUMP / SYSUDUMP |
| `EXEC CICS DUMP TASK` | Mantido para programas CICS |

Para ativar dump formatado LE em batch:
```jcl
//CEESNAP  DD SYSOUT=*
//CEEDUMP  DD SYSOUT=*
//SYSABEND DD SYSOUT=*
```
