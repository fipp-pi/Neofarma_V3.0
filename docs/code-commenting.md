# Guia de comentários e documentação de código — NeoFarma

Este documento define **como** e **quando** comentar no projeto, para manter código legível sem ruído.

## Princípios

1. **O código deve ser autoexplicativo** — nomes claros, funções pequenas, fluxo óbvio.
2. **Comente o “porquê” e o contexto de negócio**, não o óbvio (`// incrementa i`).
3. **Prefira JSDoc** em funções exportadas ou em handlers HTTP com regras não triviais.
4. **Evite comentários desatualizados** — ao mudar a lógica, atualize ou remova o comentário.

## Quando comentar

| Situação | O que fazer |
|----------|-------------|
| Regra de negócio (FEFO, cancelamento, pagamento simulado) | Bloco curto ou JSDoc `@description` |
| Transação SQL / locks (`FOR UPDATE`, rollback) | Uma linha explicando a garantia |
| Integração externa (Melhor Envio, APIs) | Onde configurar e o que acontece se falhar |
| Dados simulados (Pix, boleto, QR) | Deixar explícito que é **simulação**, não produção |
| Segurança (whitelist de ORDER BY, validação de ownership) | Breve nota |

## Quando **não** comentar

- Código que já se lê como frase em inglês/português claro.
- Repetir o que o nome da função já diz.
- Comentar cada linha de um `if` simples.

## Padrão JSDoc (handlers e services)

```js
/**
 * Breve descrição em uma linha.
 *
 * Detalhe opcional: pré-condições, efeitos colaterais, transações.
 *
 * @param {import('express').Request} req
 * @param {import('express').Response} res
 * @param {import('express').NextFunction} next
 * @returns {Promise<void>}
 */
async function handlerName(req, res, next) {}
```

Para funções puras:

```js
/**
 * @param {number[]} ids
 * @returns {Promise<Map<number, number>>}
 */
async function loadMap(ids) {}
```

## Rotas e convenção

- Onde fizer sentido, documente a rota HTTP no JSDoc: `GET /account`, `POST /admin/produtos`.
- Controllers devem delegar lógica pesada a **models** e **services**; comente a orquestração, não duplique documentação do model.

## Idioma

- Comentários e JSDoc podem estar em **português** (alinhado ao restante do projeto e à equipe).
- Nomes de variáveis e funções permanecem em inglês quando já estabelecidos no código.

## Referência de arquivos bem documentados

- `controllers/commerceController.js` — checkout transacional, FEFO
- `controllers/accountController.js` — perfil, endereços, cancelamento de pedido
- `controllers/inventoryAdminController.js` — lotes e auditoria
- `controllers/financeAdminController.js` — painel financeiro e APIs
- `models/FinanceAdmin.js` — agregações financeiras e marcação de pagamento
- `models/Order.js` — pedidos/itens e consultas por cliente
- `models/InventoryBatch.js` — lotes, FEFO e estoque válido
- `services/paymentService.js` — payloads simulados de pagamento

---

*Última atualização: documento vivo; revise ao mudar fluxos críticos.*
