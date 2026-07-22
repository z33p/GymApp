# Tasks: Design System

## Fase 1: Fundação de Tokens e Abstração (SOLID)
- [x] 1. Criar `lib/core/design_system/tokens/ds_spacing.dart` com tamanhos em T-shirt sizes (`xs`, `s`, `m`, `l`, `xl`...).
- [x] 2. Criar `lib/core/design_system/tokens/ds_colors.dart` abstraindo paletas primitivas.
- [x] 3. Criar `lib/core/design_system/tokens/ds_typography.dart` para centralizar TextStyles.
- [x] 4. Criar a `ThemeExtension` em `lib/core/design_system/ds_theme.dart` que agrupa Cores, Espaços e Tipografia. (Isso implementa a Injeção de Dependência na UI via `Theme.of(context)`).

## Fase 2: Configuração e Provisão
- [x] 5. Injetar o `DsTheme` no `ThemeData` global do app (em `lib/core/theme/app_theme.dart` ou similar).

## Fase 3: Componentes Genéricos
- [x] 6. Criar `DsGap` (`lib/core/design_system/widgets/ds_gap.dart`) para substituir `SizedBox` em espaçamentos (recebendo `DsSpacing`).
- [x] 7. Criar `DsCard` (`lib/core/design_system/widgets/ds_card.dart`) abstraindo paddings e raios de borda.

## Fase 4: Refatoração Prática (Evidência)
- [x] 8. Refatorar `lib/features/workouts/presentation/history_screen.dart` para usar `DsSpacing`, `DsGap` e remover todos os `EdgeInsets` e `SizedBox` literais numéricos, atestando que a abstração funciona na prática.
