# Padrão de Rotas (Guia Rápido)

Este arquivo define um padrão simples para organizar as rotas do projeto.

## Objetivo

Deixar os arquivos de rota fáceis de ler, manter e revisar.

## Regras

1. Separar as rotas por blocos de serviço.
   - Exemplo: `clientes`, `produtos`, `finanças`, `agendamentos`.

2. Dentro de cada bloco, manter a ordem:
   - `GET` -> `POST` -> `PUT` -> `DELETE`

3. Manter rotas específicas antes das genéricas.
   - Exemplo: `GET /produtos/:id/imagens` antes de `GET /produtos/:id`

4. Cada bloco deve ter um comentário curto explicando o domínio.
   - Exemplo: `// ===== Gestão de clientes =====`

5. Evitar misturar domínios no mesmo bloco.
   - Se o bloco é de `clientes`, não colocar rota de `finanças` nele.

## Arquivos que seguem este padrão

- `routes/indexRoutes.js`
- `routes/adminRoutes.js`
- `routes/apiRoutes.js`
- `routes/authRoutes.js`

## Observação

Ao adicionar rota nova, siga o bloco correto e mantenha a ordem dos métodos.
