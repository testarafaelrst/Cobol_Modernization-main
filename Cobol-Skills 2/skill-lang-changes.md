# Skill: Mudancas de Linguagem — COBOL II para Enterprise COBOL 6.5

> Fonte: `skill-migration-v65.md` Cap. 11, 13, 19, 20 e Appendix B (Reserved Word Comparison)

---

## 1. Construtos Removidos ou Incompativeis

### 1.1 `ALTER` Statement
**COBOL II:** Alterava destino de `GO TO` em runtime — considerado pratica obsoleta.
**Enterprise COBOL 6.5:** **Nao suportado** em `NOCMPR2`. Causa `IKF2xxx-E`.

```cobol
* COBOL II (proibido)
ALTER 100-GO TO PROCEED TO 200-PROCESS.

* Enterprise COBOL 6.5
* Eliminar completamente. Reestruturar logica com EVALUATE ou IF.
```

---

### 1.2 `ACCEPT DATE` / `ACCEPT TIME` / `ACCEPT DAY`
**COBOL II:** Usava os registros especiais `DATE`, `TIME`, `DAY` via `ACCEPT`.
**Enterprise COBOL 6.5:** Continua compilando, mas a precisao e limitada. Preferir `FUNCTION CURRENT-DATE` ou `EXEC CICS ASKTIME` em programas CICS.

```cobol
* COBOL II
ACCEPT WS-DATA FROM DATE.   *> retorna YYMMDD

* Enterprise COBOL 6.5 — Opcao 1: funcao intrinseca
MOVE FUNCTION CURRENT-DATE  TO WS-TIMESTAMP.
*   retorna 21 chars: YYYYMMDDHHmmssxx±HHmm

* Enterprise COBOL 6.5 — Opcao 2: em CICS
EXEC CICS ASKTIME ABSTIME(WS-ABSTIME) END-EXEC
EXEC CICS FORMATTIME ABSTIME(WS-ABSTIME) YYYYMMDD(WS-DATA) END-EXEC
```

> **Ref:** `skill-migration-v65.md` §Ch.11 "ACCEPT statement" /
> `skill-cics-standards.md` §"Date and Time"

---

### 1.3 `STOP literal`
**COBOL II:** `STOP 'mensagem'` exibia mensagem no console e aguardava operador.
**Enterprise COBOL 6.5:** **Nao suportado**. Causa erro de compilacao.

```cobol
* COBOL II
STOP 'AGUARDANDO CONFIRMACAO OPERADOR'.

* Enterprise COBOL 6.5
DISPLAY 'AGUARDANDO CONFIRMACAO OPERADOR'
STOP RUN.
```

---

### 1.4 `VALUE` em subordinados de `OCCURS`
**COBOL II com CMPR2:** Permitia `VALUE` em itens subordinados de `OCCURS`.
**Enterprise COBOL 6.5 com NOCMPR2:** Causa **IKF2066S** — erro fatal de compilacao.

```cobol
* COBOL II (CMPR2) — incompativel
01  WSBK-TABELA.
    12  WSBK-ENTRY OCCURS 5 TIMES.
        16  WSBK-VALOR  PIC 9(5) VALUE ZERO.   *> ERRO em NOCMPR2

* Enterprise COBOL 6.5 — Correcao
01  WSBK-TABELA.
    12  WSBK-ENTRY OCCURS 5 TIMES.
        16  WSBK-VALOR  PIC 9(5).              *> sem VALUE

* Inicializar na Procedure Division:
INITIALIZE WSBK-TABELA.
```

> **Ref:** `skill-migration-v65.md` §Ch.11 "85 COBOL Standard interpretation changes" / Table 26

---

### 1.5 Palavras Reservadas Novas
Enterprise COBOL 6.5 acrescentou diversas palavras reservadas que podem
conflitar com nomes de variaveis ou paragrafos em programas COBOL II.
Verificar a lista completa em `skill-migration-v65.md` Appendix B.

**Palavras de alto risco de conflito (exemplos):**

| Nova Palavra Reservada | Versao Introduzida |
|---|---|
| `JSON` | EC 6.1 |
| `UTF-8` | EC 6.3 |
| `DYNAMIC` | EC 6.3 |
| `FUNCTION` | EC 4.x |
| `FREE` | EC 6.1 |
| `ALLOCATE` | EC 6.1 |
| `VOLATILE` | EC 5.2 |
| `CONVERT` | EC 6.3 |

**Acao:** Use o compilador com opcao `FLAGMIG` para identificar conflitos
antes da migracao. Se um nome de variavel colidir, prefixe com o nome do
programa ou use um sinonimo descritivo.

---

## 2. Mudancas de Comportamento em NOCMPR2

A opcao `CMPR2` gerava codigo compativel com COBOL II Release 2 (ANSI 1974).
Em Enterprise COBOL 6.5 com `NOCMPR2` (padrao), valem as semanticas
ANSI 1985 e 2002. As principais diferencas estao documentadas em
`skill-migration-v65.md` Table 26 — as mais criticas sao:

| Area | Comportamento CMPR2 | Comportamento NOCMPR2 |
|---|---|---|
| `MOVE CORRESPONDING` | Move apenas itens de mesmo nome no nivel 01 | Move recursivamente todos os niveis coincidentes |
| `INSPECT REPLACING` | Nao substitui nas mesmas posicoes ja substituidas | Pode substituir posicoes ja processadas |
| `STRING/UNSTRING` overflow | Silencioso | Aciona condicao `OVERFLOW` |
| `PERFORM VARYING` com `UNTIL` | Testa condicao *antes* da primeira iteracao | Igual — mas diferencas em variaveis indexadas |
| Escopo de `IF` sem `END-IF` | Ambiguidade com ponto final | `END-IF` obrigatorio para clareza |
| Comparacao numerica DISPLAY | Sign fix-up em todo acesso | Controlado por `INVDATA` / `NUMCHECK` |

**Estrategia:** Compile com `CMPR2` primeiro para confirmar que o programa
funciona, depois migre para `NOCMPR2` item a item, usando `FLAGMIG` para
identificar os construtos a converter.

---

## 3. Novos Recursos de Linguagem Recomendados

### 3.1 `EVALUATE` — substitui IF-ELSEIF-GO TO
```cobol
* Padrao antigo COBOL II
IF EIBAID = DFHPF3
    ...
ELSE
    IF EIBAID = DFHENTER
        ...
    ELSE
        ...

* Enterprise COBOL 6.5 — padrao recomendado
EVALUATE TRUE
    WHEN EIBAID = DFHPF3
        PERFORM 700-EXIT THRU 700-EXIT
    WHEN EIBAID = DFHENTER
        PERFORM 400-QUERY THRU 400-EXIT
    WHEN OTHER
        MOVE 'TECLA INVALIDA' TO WS-MSG
END-EVALUATE
```

---

### 3.2 `FUNCTION CURRENT-DATE` — substitui ACCEPT DATE/TIME
```cobol
01  WS-TIMESTAMP.
    12  WS-YYYY     PIC X(4).
    12  WS-MM       PIC X(2).
    12  WS-DD       PIC X(2).
    12  FILLER      PIC X(13).

MOVE FUNCTION CURRENT-DATE  TO WS-TIMESTAMP.
```

---

### 3.3 `SET condition-name TO TRUE` — substitui `MOVE 'Y'/'N'`
```cobol
* COBOL II — direto na variavel
MOVE 'Y' TO WS-EDIT-ERROR-SW.

* Enterprise COBOL 6.5 — idiom correto ANSI 85
SET  WS-EDIT-ERROR  TO TRUE.   *> onde 88 WS-EDIT-ERROR VALUE 'Y'
SET  WS-NO-EDIT-ERROR TO TRUE. *> onde 88 WS-NO-EDIT-ERROR VALUE 'N'
```

---

### 3.4 `JSON GENERATE / JSON PARSE` — nova capacidade 6.1/6.2
```cobol
01  WS-CONTA-JSON   PIC X(500).
01  WS-JSON-LEN     PIC S9(9) BINARY VALUE ZERO.

JSON GENERATE WS-CONTA-JSON FROM DCLCONTA
    COUNT WS-JSON-LEN
    ON EXCEPTION
        DISPLAY 'ERRO JSON: ' JSON-CODE
END-JSON
```

---

### 3.5 `ALLOCATE / FREE` — gestao dinamica de storage (6.1)
```cobol
01  WS-PTR USAGE POINTER.

ALLOCATE 4096 CHARACTERS INITIALIZED RETURNING WS-PTR
FREE WS-PTR
```

---

## 4. Equivalencia de Statements — Tabela Rapida

| COBOL II | Enterprise COBOL 6.5 | Notas |
|---|---|---|
| `ACCEPT DATE` | `FUNCTION CURRENT-DATE` | 8 vs 21 chars |
| `ACCEPT TIME` | `FUNCTION CURRENT-DATE(9:8)` | Subfield |
| `STOP 'msg'` | `DISPLAY 'msg' STOP RUN` | — |
| `ALTER p1 TO PROCEED TO p2` | Reestruturar com EVALUATE | Eliminar |
| `MOVE 'Y' TO flag-sw` | `SET condition-name TO TRUE` | ANSI 85 |
| `CALL 'IGZERRE'` | `CALL 'CEEPIPI'` | Ver skill-le-migration |
| `IF A = B` (sem `END-IF`) | `IF A = B ... END-IF` | Obrigatorio |
| `PERFORM p1 THRU p2` | `PERFORM p1 THRU p2` | Sem mudanca |
| `EXEC CICS HANDLE CONDITION` | Verificar `RESP` apos cada comando | Ver skill-cics-migration |
