import 'package:flutter/material.dart';
import '../models/pedido_item.dart';
import '../controllers/produto_controller.dart';
import '../models/produto.dart';

class FormPedidoItem extends StatefulWidget {
  final PedidoItem? item;

  const FormPedidoItem({super.key, this.item});

  @override
  State<FormPedidoItem> createState() => _FormPedidoItemState();
}

class _FormPedidoItemState extends State<FormPedidoItem> {
  final produtoController = ProdutoController();
  List<Produto> produtos = [];
  Produto? produtoSelecionado;

  final quantidadeController = TextEditingController();
  final precoVendaController = TextEditingController();

  @override
  void initState() {
    super.initState();
    carregarProdutos();
    if (widget.item != null) {
      quantidadeController.text = widget.item!.quantidade.toString();
    }
  }

  void carregarProdutos() async {
    produtos = await produtoController.listarProdutos();
    setState(() {
      if (widget.item != null) {
        produtoSelecionado = produtos.firstWhere(
          (p) => p.id == widget.item!.id,
          orElse: () => produtos.first,
        );
      }
    });
  }

  void salvar() {
    final produtoId = produtoSelecionado!.id;
    final quantidade = double.tryParse(quantidadeController.text);

    if (produtoId == null || quantidade == null) {
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(const SnackBar(content: Text('Campos inválidos!')));
      return;
    }

    if (produtoId == null) {
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(const SnackBar(content: Text('Selecione um produto.')));
      return;
    }

    final total =
        quantidade * produtoSelecionado!.precoVenda; // Exemplo de preço fixo

    final item = PedidoItem(
      id: widget.item?.id ?? DateTime.now().millisecondsSinceEpoch,
      idProduto: produtoId,
      quantidade: quantidade,
      totalItem: total,
    );

    Navigator.pop(context, item);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Adicionar Item')),
      body: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          children: [
            produtos.isEmpty
                ? const CircularProgressIndicator()
                : DropdownButtonFormField<Produto>(
                  value: produtoSelecionado,
                  items:
                      produtos.map((p) {
                        return DropdownMenuItem(
                          value: p,
                          child: Text('${p.nome}'),
                        );
                      }).toList(),
                  onChanged: (value) {
                    setState(() {
                      produtoSelecionado = value;
                    });
                  },
                  decoration: const InputDecoration(labelText: 'Produto'),
                ),
            const SizedBox(height: 12),

            TextField(
              controller: quantidadeController,
              decoration: const InputDecoration(labelText: 'Quantidade'),
              keyboardType: TextInputType.number,
            ),
            const SizedBox(height: 24),
            ElevatedButton(
              onPressed: salvar,
              style: ElevatedButton.styleFrom(
                backgroundColor: const Color(0xFFDC3002),
                foregroundColor: Colors.white,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
              ),
              child: const Text('Salvar Item'),
            ),
          ],
        ),
      ),
    );
  }
}
