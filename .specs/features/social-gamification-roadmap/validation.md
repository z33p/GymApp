# Fauna Foundation — Validation

**Scope:** Fase 0 — rank local, mascote e Habitat/Home
**Status:** PASS — implementação parcial intencional do roadmap social

## Entregas verificadas

- Forma usa janela móvel de 28 dias e Legado conta workouts do ano corrente.
- Tiers locais determinísticos: Rato, Lobo, Urso, Rinoceronte, Gorila e ápice Leão/Dragão.
- Mascote mostra cada espécie/tier, Forma, Legado e semântica acessível.
- Habitat é a rota/tab inicial; `/feed` continua acessível.
- Habitat mostra sincronização, progresso, próximo tier, Legado e atividade recente.
- Estado vazio mostra Rato e CTA para sincronizar.

## Gates

- `flutter analyze`: PASS — sem issues.
- `flutter test`: PASS — 13 testes, 0 falhas; inclui loading, vazio, populado e todos os tiers do mascote.
- `flutter build apk --debug`: PASS — APK em `build/app/outputs/flutter-apk/app-debug.apk`.

## Limites conhecidos

- Thresholds ainda são valores provisórios de protótipo e precisam de balanceamento com telemetria.
- Facção ainda não é selecionável; o ápice mostra `Leão ou Dragão`.
- Grupos, login, backend, ranking remoto, posts e regras configuráveis permanecem nas fases seguintes.
- A arte do mascote usa emoji com uma seam de widget; assets ilustrados podem substituir a apresentação sem alterar o domínio.
