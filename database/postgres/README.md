# PostgreSQL remoto do GymApp

Este diretório contém somente dados compartilhados: identidade, grupos, temporadas/regras, claims, ranking, fauna social e mural. O banco local SQLite continua sendo a fonte do histórico pessoal, importações e cache offline.

## Requisitos

- PostgreSQL **15+** e cliente `psql` no `PATH`.
- Uma base vazia ou dedicada ao GymApp.
- Uma URL semitada, por exemplo `postgresql://gymapp:senha@localhost:5432/gymapp`.
- Para o smoke test completo de RLS, uma credencial de desenvolvimento com `CREATEROLE`; o teste cria um papel `NOLOGIN` e o descarta com `ROLLBACK`.

Não registre `DATABASE_URL` com senha no Git. A API autenticada deve executar `SET LOCAL app.user_id = '<uuid-do-perfil>'` no começo de toda transação de cliente. Migrations e operações administrativas devem usar uma credencial separada, nunca exposta ao app Flutter.

## Aplicar migrations

Windows (PowerShell):

```powershell
$env:DATABASE_URL = 'postgresql://user:password@localhost:5432/gymapp'
.\database\postgres\scripts\apply_postgres_migrations.ps1
```

macOS/Linux:

```bash
export DATABASE_URL='postgresql://user:password@localhost:5432/gymapp'
chmod +x database/postgres/scripts/*.sh
./database/postgres/scripts/apply_postgres_migrations.sh
```

O runner cria `gymapp.schema_migrations`, aplica os arquivos em ordem lexical e não reaplica migrations já registradas.

## Verificar

Os testes criam dados determinísticos dentro de uma transação e sempre terminam com `ROLLBACK`.

```powershell
.\database\postgres\scripts\verify_postgres_schema.ps1
```

```bash
./database/postgres/scripts/verify_postgres_schema.sh
```

O smoke test verifica crédito mínimo/máximo, limite diário, fonte recusada, idempotência, imutabilidade da regra, ranking, relações do mural e presença de RLS.

## Próximo passo de integração

Escolher o host e o adaptador de autenticação. Qualquer provedor deve mapear seu identificador estável para `gymapp.auth_identities(provider, subject)` e nunca enviar diretamente credenciais administrativas ao aplicativo.
