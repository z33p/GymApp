# Design System Specification

## Problem Statement

Atualmente o GymApp possui valores mágicos de layout (ex: `EdgeInsets.fromLTRB(20, 0, 20, 16)`, `SizedBox(height: 12)`), cores hardcoded e falta de padronização em widgets base. Isso gera inconsistência visual, dificulta o desenvolvimento de novas features, impossibilita um controle global do tema e viola o princípio de abstração (SOLID) por acoplar a UI a valores primitivos e classes de framework sem inversão de dependência (ex: depender de `Colors.red` diretamente ao invés de `context.theme.colors.error`).

## Goals

- [ ] Criar um Design System abstrato (Theme/Tokens) que remova 100% dos valores em pixels hardcoded de margens, paddings, gaps, tamanhos de fonte e raios de borda.
- [ ] Criar um conjunto de Design Tokens para Cores e Tipografia.
- [ ] Abstrair componentes comuns (Botões, Cards, Inputs, ListTiles) em widgets do Design System (ex: `DsButton`, `DsCard`).
- [ ] Garantir que o acesso ao Design System respeite princípios SOLID, especificamente injetando as dependências de design através de abstrações (ex: `ThemeExtension` no Flutter ou `InheritedWidget` fortemente tipado).

## Out of Scope

Explicitly excluded. Documented to prevent scope creep.

| Feature     | Reason         |
| ----------- | -------------- |
| Dark Mode dinâmico imediato | Pode ser preparado estruturalmente, mas a implementação das cores do dark mode não bloqueia o refatoramento estrutural inicial. |
| Animações complexas (Motion DS) | Foco inicial apenas em tipografia, espaçamento, cores e componentes estáticos fundamentais. |

---

## Assumptions & Open Questions

Every ambiguity is resolved or recorded here — nothing is left silently unclear.

| Assumption / decision | Chosen default  | Rationale | Confirmed? |
| --------------------- | --------------- | --------- | ---------- |
| Método de Abstração (SOLID) | `ThemeExtension` do Flutter | Padrão profissional de mercado do Flutter. Garante injeção de dependência tipo-segura (SOLID) nativamente pelo `Theme.of(context)`, desacoplando totalmente as cores e tamanhos do Material. | Sim |
| Nomenclatura e Componentes | Prefixo `Ds` e T-shirt sizes | Componentes serão chamados de `DsCard`, `DsButton` e tamanhos serão `DsSpacing.m`. É o padrão da indústria para escalar de forma semântica. | Sim |

**Open questions:** nenhuma — todas resolvidas. O spec está fechado.

---

## User Stories

### P1: Abstração de Espaçamentos e Cores ⭐ MVP

**User Story**: Como desenvolvedor de interface, quero acessar espaçamentos e cores através de uma abstração tipada, para não hardcodar pixels ou instanciar primitivas (SOLID - DIP).

**Why P1**: Resolve o débito técnico principal de valores em hardcode apontado.

**Acceptance Criteria**:

1. WHEN um widget precisar de padding THEN o desenvolvedor SHALL utilizar tokens do DS (ex: `DsSpacing.m`) ao invés de números fixos.
2. WHEN o layout exigir um gap entre elementos THEN o desenvolvedor SHALL usar um componente semântico de gap (ex: `DsGap.s()`) ao invés de `SizedBox(height: 8)`.
3. WHEN uma cor for solicitada THEN o desenvolvedor SHALL acessar através da interface de cores do tema atual (`context.theme.colors.primary`).

**Independent Test**: Garantir que as páginas refatoradas (como `HistoryScreen`) compilem e renderizem sem utilizar nenhum `double` literal para espaços.

---

### P1: Componentes Padrões (Widgets) ⭐ MVP

**User Story**: Como desenvolvedor, quero compor telas usando widgets de Design System ao invés de primitivas puras do Flutter.

**Why P1**: Reduz duplicação de código e centraliza o comportamento visual em um único lugar.

**Acceptance Criteria**:

1. WHEN renderizar um botão THEN o sistema SHALL usar o widget padrão do DS, que já herda tokens de cor, padding e tipografia internamente.
2. WHEN renderizar um card (ex: WorkoutCard) THEN o sistema SHALL usar o widget `DsCard` ou o wrapper de bordas e paddings do DS.

**Independent Test**: Alterar a cor primária ou o raio de borda do botão no tema do Design System refletirá em toda a aplicação instantaneamente.

---

## Edge Cases

- WHEN um widget de terceiros exigir um primitivo Flutter (`Color` ou `double`) THEN o sistema SHALL prover adaptadores no DS para ler o valor bruto do token de forma segura (ex: `DsSpacing.m.value`).
- WHEN uma cor for utilizada que não existe no tema semântico THEN o sistema SHALL quebrar em tempo de compilação ou prover uma cor fallback óbvia (como magenta/error) se não for resolvível.

---

## Requirement Traceability

| Requirement ID | Story       | Phase  | Status  |
| -------------- | ----------- | ------ | ------- |
| DS-01          | P1: Abstração | Design | Pending |
| DS-02          | P1: Componentes | Design | Pending |

**Coverage:** 2 total, 0 mapped to tasks, 2 unmapped ⚠️

---

## Success Criteria

- [ ] Zero instâncias de `EdgeInsets.all(número)` nas features refatoradas.
- [ ] A HistoryScreen e Widgets associados não possuem menção direta a construtores de estilo do Material, usando as abstrações do Design System.
