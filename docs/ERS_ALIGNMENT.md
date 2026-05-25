# Alinhamento com a ERS NeoFarma

## Banco de dados

**Instalação nova:** use apenas o script consolidado (já inclui tabelas ERS):

```bash
mysql -u root -p < scripts/DB_Neofarma_clean.sql
```

**Banco já existente** (criado antes das melhorias ERS): execute a migration uma vez:

```bash
mysql -u root -p neofarma < scripts/migrations/001_ers_alignments.sql
```
## Implementado nesta entrega

| Requisito | Situação |
|-----------|----------|
| **RF_F2** Baixa de estoque após pagamento | PIX/Boleto: itens em `order_pending_items`; baixa no pagamento (cliente ou admin). Cartão: baixa na confirmação. |
| **RF_B3** Tipos de produto | `/admin/tipos-produto` + campo no cadastro de produto |
| **RF_F3** Compras | `/admin/compras` — rascunho → pagamento → **AWAITING_DELIVERY** → conferência → entrada em lote |
| **RF_F5** Descarte | `/admin/descartes` — motivo obrigatório, baixa no lote |
| **RF_F4** Promoção | Preço promocional no admin; cupons fictícios removidos do checkout |
| **RF_F6/F7** Agendamentos | Já existente (horários livres, 10 min, conclusão) |
| **RF_S1–S3, RF_04** Relatórios | `/admin/financas/relatorios` — abas Produtos, Vendas, Clientes, Serviços |
| **RF_B1** Funcionários | `/admin/funcionarios` — perfis ADMIN, FUNCIONARIO, ESTOQUISTA |

## Ainda simulado (documentar na ERS ou integrar depois)

- PagSeguro / gateway real (vendas e serviços)
- NF-e / SEFAZ
- Cadastro unificado de “pessoa” (cliente e funcionário ainda em telas separadas)
- PagSeguro mencionado na ERS — usar texto “simulação acadêmica” na apresentação

## Fluxos principais

### Venda (cliente)

1. Checkout → pedido `PENDING` (PIX/Boleto) sem baixa de estoque  
2. Botão “Confirmar pagamento (simulação)” na confirmação **ou** admin em Finanças  
3. `fulfillOrderStock` aplica FEFO e grava `order_items`

### Compra (admin)

1. Nova compra → status `DRAFT`  
2. Confirmar pagamento → `AWAITING_DELIVERY`  
3. Detalhes → conferir lote/validade/qtd → `RECEIVED` + `inventory_batches`
