# Checklist de Pontos de Medição — Business Case de Migração COBOL II → EC 6.5

Use este checklist para coletar os dados necessários para construir um business case
quantitativo da migração. Cada seção indica a fonte do dado e o que calcular com ele.

---

## 1. Consumo de CPU Atual (linha de base)

### Dados a coletar
- [ ] **Relatório RMF/SMF Type 30** — tempo de CPU por job batch e por região CICS
  - Ferramenta: `IBM RMF Monitor III` ou `CA Mainview` / `BMC MAINVIEW`
  - Período recomendado: 30 dias representativos (evitar datas atípicas)
- [ ] **MSU médio por hora** — extraído do RMF Workload Activity Report
- [ ] **Breakdown por subsistema** — separar CICS, Batch, IMS (se aplicável)
- [ ] **Top 20 programas por consumo de CPU** — candidatos prioritários à migração

### O que calcular
```
CPU_antes (em MSU·hora/mês) = soma dos consumos dos programas COBOL II no período
```

---

## 2. Volume e Frequência de Execução

### Dados a coletar
- [ ] **Número de execuções mensais** por programa (SMF Type 30, campo SMFJBRCL)
- [ ] **Elapsed time médio** por execução (batch) ou por transação (CICS)
- [ ] **Número de transações CICS/mês** por programa convertido
- [ ] **Janela de batch** — horário de início e fim dos jobs críticos

### O que calcular
```
Frequência × CPU_por_execução = carga total mensal por programa
```

---

## 3. Custo por MSU (contrato IBM)

### Dados a coletar
- [ ] **Tipo de contrato de software IBM** — IPLA, MLC (ex.: MWLC, EWLC, AWLC)
- [ ] **Valor do MSU** no contrato vigente (em USD ou BRL)
  - Fonte: área de procurement / IBM Client Representative
- [ ] **Rolling 4-Hour Average (R4HA)** atual — métrica base para cobrança MLC
- [ ] **Sub-capacity reporting** — se ativo, identificar janelas de pico

### O que calcular
```
Custo_mensal_sw = R4HA_pico × preço_por_MSU × fator_contrato
```

---

## 4. Estimativa de Redução de CPU com EC 6.5

### Referências técnicas (IBM)
- [ ] Revisar **IBM EC 6.5 Performance Report** (documento SC27-xxxx) para benchmarks OPT(FULL)
- [ ] Identificar quais programas usam aritmética intensiva (candidatos a maior ganho com `TRUNC(OPT)`)
- [ ] Identificar quais programas têm loops sobre tabelas grandes (candidatos a vetorização com `ARCH`)

### Faixas típicas de referência (não garantidas — validar com benchmark próprio)

| Cenário | Redução estimada de CPU |
|---|---|
| Recompilação simples (sem OPT) | 0–5% |
| `OPT(FULL)` + `ARCH` + `TUNE` | 10–25% |
| `OPT(FULL)` + `TRUNC(OPT)` + aritmética intensiva | 20–40% |
| Programas com loops e tabelas grandes (`ARCH(14)` z16) | até 50% em casos específicos |

> ⚠️ Esses valores são baseados em benchmarks IBM publicados e relatos de clientes.
> **Sempre valide com um piloto** antes de projetar para toda a carteira.

### O que calcular
```
CPU_depois = CPU_antes × (1 - redução_estimada)
Economia_CPU_MSU = CPU_antes - CPU_depois
Economia_financeira_CPU = Economia_CPU_MSU × preço_por_MSU
```

---

## 5. Redução de Custo de JCL / Processamento de Jobs

### Dados a coletar
- [ ] **Número de jobs com pré-processamento** (DSNHPC + DFHECP1$ + COBCOMP)
  - Fonte: JCL library / CA7 / TWS scheduler
- [ ] **Elapsed time médio do step DSNHPC** e do step **DFHECP1$** por job de compilação
- [ ] **Frequência de compilações** (ambiente de CI/CD, promoções, builds noturnos)
- [ ] **Custo de datasets temporários** alocados nos steps eliminados (SMS/DASD pricing)

### O que calcular
```
Steps eliminados × elapsed_médio × custo_por_hora_de_job = economia de elapsed/DASD
```

---

## 6. Redução de Custo de Manutenção (OPEX)

### Dados a coletar
- [ ] **Horas mensais gastas em análise de abends** (IGZSNAP/IGZDUMP) vs. CEEDUMP
  - Fonte: registro de chamados / ticketing (ServiceNow, JIRA)
- [ ] **Custo/hora do desenvolvedor mainframe** (taxa interna ou de contrato)
- [ ] **Número de incidentes relacionados a construções COBOL II obsoletas**
  - Ex.: comportamento de `RTEREUS`, `IGZERRE`, `HANDLE CONDITION`
- [ ] **Tempo médio de onboarding** de novos desenvolvedores em código COBOL II vs. EC 6.5

### O que calcular
```
Horas_economizadas × custo_hora = economia de manutenção mensal
```

---

## 7. Custo da Migração (investimento)

### Dados a estimar
- [ ] **Número de programas a migrar** — separar por complexidade (Simple / Medium / Complex)
- [ ] **Horas estimadas por complexidade**:
  - Simple: ~2–4h por programa
  - Medium: ~8–16h por programa
  - Complex: ~24–40h por programa
- [ ] **Custo de testes de regressão** — suites existentes, automação, ambientes
- [ ] **Custo de treinamento** da equipe em EC 6.5 e Language Environment
- [ ] **Custo de licença** do compilador EC 6.5 (se não incluso no contrato IBM)

### O que calcular
```
CAPEX_total = Σ(horas_por_programa × custo_hora) + testes + treinamento
```

---

## 8. Cálculo do ROI

Com os dados acima, o ROI pode ser calculado da seguinte forma:

```
Economia_mensal = Economia_CPU + Economia_JCL + Economia_manutencao
Payback (meses) = CAPEX_total / Economia_mensal
ROI_12m = (Economia_mensal × 12 - CAPEX_total) / CAPEX_total × 100
```

### Template de resumo executivo

| Item | Valor mensal (R$ ou USD) |
|---|---|
| Economia de CPU (MSU) | ___ |
| Economia de JCL/Elapsed | ___ |
| Economia de manutenção | ___ |
| **Total economia mensal** | ___ |
| **CAPEX da migração** | ___ |
| **Payback estimado** | ___ meses |
| **ROI em 12 meses** | ___% |

---

## 9. Próximos Passos Recomendados

- [ ] Selecionar 2–3 programas **candidatos a piloto** (alto consumo de CPU + complexidade Medium)
- [ ] Executar compilação com `OPT(FULL)` + `ARCH` + `TUNE` e medir CPU antes/depois
- [ ] Comparar saída funcional (regressão) entre versão COBOL II e EC 6.5
- [ ] Extrair R4HA antes e depois do piloto para validar redução de MSU real
- [ ] Apresentar resultado do piloto como base para aprovação do projeto completo

---

*Referências técnicas: `Cobol-Skills/skill-perf-tuning.md`, `Cobol-Skills/skill-migration-v65.md`,
`Cobol-Skills/skill-le-runtime.md`, `Cobol-Skills/skill-cics-standards.md`*
