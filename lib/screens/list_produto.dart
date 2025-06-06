import 'package:flutter/material.dart';
import '../controllers/produto_controller.dart';
import '../models/produto.dart';
import 'form_produto.dart';
import '../components/drawer_menu.dart';

class ListarProdutosScreen extends StatefulWidget {
  const ListarProdutosScreen({super.key});

  @override
  State<ListarProdutosScreen> createState() => _ListarProdutosScreenState();
}

class _ListarProdutosScreenState extends State<ListarProdutosScreen> {
  final ProdutoController controller = ProdutoController();
  List<Produto> produtos = [];

  @override
  void initState() {
    super.initState();
    carregarProdutos();
  }

  Future<void> carregarProdutos() async {
    produtos = await controller.listarProdutos();
    for (final prod in produtos) {
      print(prod.toJsonServidor());
    }
    setState(() {});
  }

  void excluirProduto(int id) async {
    await controller.inativarProduto(id);
    await carregarProdutos();
  }

  void editarProduto(Produto produto) async {
    final result = await Navigator.push(
      context,
      MaterialPageRoute(builder: (_) => FormProduto(produto: produto)),
    );
    if (result == true) carregarProdutos();
  }

  void novoProduto() async {
    final result = await Navigator.push(
      context,
      MaterialPageRoute(builder: (_) => const FormProduto()),
    );
    if (result == true) carregarProdutos();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Produtos')),
      drawer: const DrawerCustom(),
      body:
          produtos.isEmpty
              ? const Center(child: Text('Nenhum produto cadastrado.'))
              : ListView.builder(
                itemCount: produtos.length,
                itemBuilder: (context, index) {
                  final p = produtos[index];
                  return ListTile(
                    title: Text(p.nome),
                    subtitle: Text(
                      'Estoque: ${p.qtdEstoque}, Preço: R\$${p.precoVenda.toStringAsFixed(2)}',
                    ),
                    trailing: IconButton(
                      icon: const Icon(Icons.delete, color: Colors.red),
                      onPressed: () => excluirProduto(p.id!),
                    ),
                    onTap: () => editarProduto(p),
                  );
                },
              ),
      floatingActionButton: FloatingActionButton(
        onPressed: novoProduto,
        child: const Icon(Icons.add),
      ),
    );
  }
}
