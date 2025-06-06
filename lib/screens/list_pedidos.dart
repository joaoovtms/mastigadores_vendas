import 'package:app_vendas/components/drawer_menu.dart';
import 'package:flutter/material.dart';
import '../controllers/pedido_controller.dart';
import '../models/pedido.dart';
import 'form_pedido.dart';

class ListarPedidosScreen extends StatefulWidget {
  const ListarPedidosScreen({super.key});

  @override
  State<ListarPedidosScreen> createState() => _ListarPedidosScreenState();
}

class _ListarPedidosScreenState extends State<ListarPedidosScreen> {
  final PedidoController controller = PedidoController();
  List<Pedido> pedidos = [];

  @override
  void initState() {
    super.initState();
    carregar();
  }

  Future<void> carregar() async {
    pedidos = await controller.listarPedidos();
    for (final ped in pedidos) {
      print(ped.toJsonServidor());
    }
    setState(() {});
  }

  Future<void> removerPedido(int id) async {
    final confirm = await showDialog<bool>(
      context: context,
      builder:
          (_) => AlertDialog(
            title: const Text('Excluir Pedido'),
            content: const Text('Tem certeza que deseja excluir este pedido?'),
            actions: [
              TextButton(
                onPressed: () => Navigator.pop(context, false),
                child: const Text('Cancelar'),
              ),
              ElevatedButton(
                onPressed: () => Navigator.pop(context, true),
                child: const Text('Excluir'),
              ),
            ],
          ),
    );

    if (confirm == true) {
      await controller.inativarPedido(id);
      await carregar();
    }
  }

  void editarPedido(Pedido pedido) async {
    final result = await Navigator.push(
      context,
      MaterialPageRoute(builder: (_) => FormPedido(pedido: pedido)),
    );

    if (result == true) {
      await carregar();
    }
  }

  void novoPedido() async {
    final result = await Navigator.push(
      context,
      MaterialPageRoute(builder: (_) => const FormPedido()),
    );

    if (result == true) {
      await carregar();
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Pedidos')),
      drawer: DrawerCustom(),
      body:
          pedidos.isEmpty
              ? const Center(child: Text('Nenhum pedido cadastrado.'))
              : ListView.separated(
                itemCount: pedidos.length,
                separatorBuilder: (_, __) => const Divider(),
                itemBuilder: (context, index) {
                  final p = pedidos[index];
                  return Card(
                    elevation: 2,
                    margin: const EdgeInsets.symmetric(
                      horizontal: 12,
                      vertical: 6,
                    ),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: ListTile(
                      title: Text('Pedido #${p.id} - Cliente: ${p.idCliente}'),
                      subtitle: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text('Usuário: ${p.idUsuario}'),
                          Text('Data: ${p.ultimaAlteracao}'),
                          Text('Total: R\$ ${p.totalPedido}'),
                        ],
                      ),
                      trailing: IconButton(
                        icon: const Icon(Icons.delete, color: Colors.red),
                        onPressed: () => removerPedido(p.id!),
                      ),
                      onTap: () => editarPedido(p),
                    ),
                  );
                },
              ),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: novoPedido,
        icon: const Icon(Icons.add),
        label: const Text('Novo Pedido'),
      ),
    );
  }
}
