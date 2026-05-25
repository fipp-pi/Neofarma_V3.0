# Neofarma_V3.0
Projeto desenvolvido na disciplina de Projeto Integrado 3 (TEMA: Farmacia)

## Padrões de Rotas

Consulte `ROUTES_CONVENTION.md` para o guia rápido de organização das rotas.

## Alinhamento ERS (banco de dados)

**Instalação nova** — o script consolidado já inclui as tabelas ERS:

```bash
mysql -u root -p < scripts/DB_Neofarma_clean.sql
```

**Banco já existente** — execute a migration uma vez:

```bash
mysql -u root -p neofarma < scripts/migrations/001_ers_alignments.sql
```

Detalhes dos requisitos cobertos: `docs/ERS_ALIGNMENT.md`.

## Base de demonstração (dados realistas)

Após o schema, popule o ambiente com dados operacionais para testar catálogo, estoque, pedidos, compras, agendamentos e finanças:

```bash
mysql -u root -p neofarma < scripts/demo_neofarma.sql
```

Ou via Node (usa credenciais do `.env` / `config/database.js`):

```bash
node scripts/run_demo_import.js
```

O script é **idempotente**: pode ser executado várias vezes — ele remove os dados anteriores da base demo e recria tudo.

Para **regenerar** o SQL (após alterar contagens ou nomes no gerador):

```bash
node scripts/generate_demo_brasil.js
```

### Logins principais

| Perfil | E-mail | Senha |
|--------|--------|-------|
| Admin (schema) | `admin@neofarma.com` | `Admin@123` |
| Gerente | `marcos.ribeiro@loja.neofarma.com.br` | `NeoFarma@2026` |
| Atendente | `eliane.moraes@loja.neofarma.com.br` | `NeoFarma@2026` |
| Estoquista | `robson.lima@loja.neofarma.com.br` | `NeoFarma@2026` |
| Cliente PF | `ana.beatriz@loja.neofarma.com.br` | `NeoFarma@2026` |
| Cliente PJ | `contato@clinicabemviver.com.br` | `NeoFarma@2026` |

Todos os usuários `@loja.neofarma.com.br` usam a senha **`NeoFarma@2026`**.

### Volume aproximado

110 produtos, 333 lotes (FEFO com vencidos/críticos/válidos), 32 clientes, 75 pedidos, 12 ordens de compra, 45 agendamentos, 10 receitas médicas, 6 profissionais de saúde.

> O seed legado de estresse (`scripts/old/generate_seed_stress_sql.js`) permanece apenas como referência histórica.
