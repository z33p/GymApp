# Device Integrations Specification

**Product baseline**: `../product-baseline/spec.md`  
**Implementation state**: Apple Health no iOS + preview; Health Connect/Garmin planejados

## Problem Statement

O usuário precisa saber de onde os workouts vêm, se uma integração está disponível e como disparar nova importação. A UI não pode confundir dados simulados ou placeholders com conexões reais.

## Capability Status

| Provider | Plataforma | Estado | Comportamento atual |
| --- | --- | --- | --- |
| Apple Health | iOS com HealthKit | Implementado | disponibilidade, autorização read-only, status e sync |
| Preview Data | sem HealthKit | Implementado como fallback | dois workouts locais demonstrativos |
| Health Connect | Android | Planejado | card `Coming soon`; nenhuma autorização/importação nativa |
| Garmin | todas | Planejado | card `Coming soon`; nenhuma API/OAuth/importação |
| Manual | modelo de workout | Não entregue | enum existe, mas não há card ou criação manual |

## Tela Connect Devices

A rota `/devices` contém:

- card Apple Health somente quando `Platform.isIOS`;
- cards Health Connect e Garmin sempre visíveis com chip `Coming soon`;
- card de sync manual em todas as plataformas;
- status de carregamento/erro do controller.

Em plataforma não iOS, Apple Health não aparece como dispositivo conectável, mas o botão manual ainda chama o fluxo Apple Health, que seleciona preview por indisponibilidade.

## Apple Health connection

### Disponibilidade

- Plataforma diferente de iOS: `isAvailable = false` sem chamar MethodChannel.
- iOS: invoca `isHealthDataAvailable`; `PlatformException` é convertida em `false`.

### Conectar

1. Se HealthKit estiver indisponível, solicita autorização mock, retorna conexão `connected = true`, `permissionStatus = preview`, `isPreviewMode = true`.
2. Se disponível, chama `requestAuthorization`, consulta status e retorna `connected` igual ao booleano concedido.

### Consultar status

1. HealthKit indisponível retorna preview ativo e conectado.
2. HealthKit disponível considera conectado quando status é `authorized` ou `sharingAuthorized`.
3. A mensagem de sucesso do status usa `Apple Health connected.` somente para `authorized`; demais valores orientam conectar.

## HealthKit data permissions

O bridge solicita leitura de:

- `HKWorkoutType`;
- active energy burned;
- walking/running distance;
- cycling distance;
- heart rate.

Não solicita escrita. As chaves `NSHealthShareUsageDescription` e `NSHealthUpdateUsageDescription` estão no Info.plist, e o entitlement HealthKit está habilitado. Apesar da permissão de heart rate, o serializer ainda grava média/máxima como nulas.

## Critérios de aceite

### P1 — Estado honesto da integração

1. WHEN a tela abre em iOS com HealthKit disponível e autorizado THEN o card Apple Health SHALL mostrar `Active` e a última sync bem-sucedida quando existir.
2. WHEN a tela abre em iOS sem HealthKit disponível THEN o card SHALL mostrar `Preview mode` e explicar que workouts de preview serão usados.
3. WHEN a tela abre fora do iOS THEN o card Apple Health SHALL permanecer oculto.
4. WHEN Health Connect ou Garmin são exibidos THEN cada card SHALL mostrar `Coming soon` e não SHALL oferecer botão funcional de conexão.
5. WHEN o provider mock é consultado diretamente THEN o repository SHALL retornar disponível, conectado e em preview.

### P1 — Ações Apple Health

1. WHEN o usuário toca `Connect Apple Health` THEN o sistema SHALL solicitar autorização e atualizar os providers de estado.
2. WHEN a conexão conclui THEN a UI SHALL mostrar `Apple Health connection updated.`; essa mensagem indica conclusão da tentativa, não garante concessão.
3. WHEN o usuário toca `Sync now` no card Apple THEN o sistema SHALL executar sync e mostrar `Workout sync complete.` após retorno do controller.
4. WHEN o usuário toca `Sync now` no card manual THEN o sistema SHALL executar o mesmo fluxo e mostrar `Manual sync finished.`.
5. WHEN o controller possui erro THEN o card manual SHALL mostrar `Sync error: <error>`.

### P2 — Segurança de permissão

1. WHEN autorização HealthKit é solicitada THEN `toShare` SHALL ser `nil`.
2. WHEN qualquer tipo obrigatório não pode ser criado THEN a tentativa SHALL retornar `false` sem iniciar request incompleto.
3. WHEN HealthKit retorna erro de autorização THEN o bridge SHALL retornar FlutterError `authorization_failed` com mensagem do sistema.

## Edge Cases e limitações

- Snackbars de conexão/sync são mostrados após `await` mesmo quando o `AsyncNotifier` guardou erro; o controller não relança. O card de erro é a fonte real do resultado.
- Health Connect é marcado `available` no Android pelo repository, mas continua `connected = false` e `coming_soon`.
- A UI não mostra card Apple Health em Android/Windows, portanto o estado preview é percebido principalmente pelos dados e pelo sync manual.
- Não existe desconexão/revogação dentro do app.
- Não existe observação reativa de mudança de permissão fora dos refreshes locais.
- O status HealthKit é uma string de bridge; valores inesperados resultam em não conectado.

## Evidência e cobertura automatizada

| Área | Evidência | Cobertura atual |
| --- | --- | --- |
| UI/status/ações | `DevicesScreen` | Sem widget test |
| Decisão real vs preview | `DeviceIntegrationRepositoryImpl` | Sem teste dedicado |
| MethodChannel | `AppleHealthDataSource` | Sem teste dedicado |
| Permissões/queries | `ios/Runner/AppDelegate.swift` | Sem XCTest |
| Preview | `MockFitnessDataSource` | Exercitado indiretamente, sem teste próprio |

## Requirement Traceability

| ID | Requisito | Implementação | Estado documental |
| --- | --- | --- | --- |
| DEV-01 | Estado Apple Health/preview | `DeviceIntegrationRepositoryImpl` | Documented |
| DEV-02 | Card e ações iOS | `DevicesScreen` | Documented |
| DEV-03 | Sync manual cross-platform | `DevicesScreen`, `SyncController` | Documented |
| DEV-04 | Permissão HealthKit read-only | `AppDelegate.swift` | Documented |
| DEV-05 | Health Connect/Garmin honestamente planejados | `DevicesScreen` | Documented |
| DEV-06 | Erros e limitações explícitos | esta spec | Documented |

**Open questions**: nenhuma para o baseline. Cada integração real futura deve possuir spec própria de auth, importação, rate limits, revogação e falhas.

