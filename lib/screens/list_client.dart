import 'package:flutter/material.dart';
import '../controllers/cliente_controller.dart';
import '../models/cliente.dart';
import 'form_client.dart';
import '../components/drawer_menu.dart';

class ListarClientesScreen extends StatefulWidget {
  const ListarClientesScreen({super.key});

  @override
  State<ListarClientesScreen> createState() => _ListarClientesScreenState();
}

class _ListarClientesScreenState extends State<ListarClientesScreen> {
  final ClienteController controller = ClienteController();
  List<Cliente> clientes = [];

  @override
  void initState() {
    super.initState();
    carregar();
  }

  Future<void> carregar() async {
    clientes = await controller.loadClientes();
    for (final cliente in clientes) {
      print(cliente.toSQL());
    }
    setState(() {});
  }

  void remover(int id) async {
    final confirm = await showDialog<bool>(
      context: context,
      builder:
          (_) => AlertDialog(
            title: const Text('Excluir cliente'),
            content: const Text('Tem certeza que deseja excluir este cliente?'),
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
      await controller.inativarCliente(id);
      await carregar();
    }
  }

  void editar(Cliente cliente) async {
    final result = await Navigator.push(
      context,
      MaterialPageRoute(
        builder: (_) => CadastroClienteScreen(cliente: cliente),
      ),
    );

    if (result == true) {
      await carregar();
    }
  }

  void novoCliente() async {
    final result = await Navigator.push(
      context,
      MaterialPageRoute(builder: (_) => const CadastroClienteScreen()),
    );

    if (result == true) {
      await carregar();
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Clientes')),
      drawer: const DrawerCustom(),
      body:
          clientes.isEmpty
              ? const Center(child: Text('Nenhum cliente cadastrado.'))
              : ListView.builder(
                padding: const EdgeInsets.all(16),
                itemCount: clientes.length,
                itemBuilder: (context, index) {
                  final c = clientes[index];
                  return Container(
                    margin: const EdgeInsets.only(bottom: 12),
                    decoration: BoxDecoration(
                      color: const Color(0xFFF0F1F3),
                      borderRadius: BorderRadius.circular(12),
                      boxShadow: [
                        BoxShadow(
                          color: Colors.black.withOpacity(0.05),
                          blurRadius: 6,
                          offset: const Offset(0, 3),
                        ),
                      ],
                    ),
                    child: ListTile(
                      contentPadding: const EdgeInsets.symmetric(
                        horizontal: 16,
                        vertical: 10,
                      ),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                      title: Text(
                        c.nome,
                        style: const TextStyle(
                          fontWeight: FontWeight.w600,
                          color: Color(0xFF00123C),
                        ),
                      ),
                      subtitle: Text(
                        '${c.tipo == 'F' ? 'CPF' : 'CNPJ'}: ${c.cpfCnpj}',
                        style: const TextStyle(color: Colors.black54),
                      ),
                      trailing: IconButton(
                        icon: const Icon(
                          Icons.delete,
                          color: Color(0xFFDC3002),
                        ),
                        onPressed: () => remover(c.id!),
                        tooltip: 'Excluir',
                      ),
                      onTap: () => editar(c),
                    ),
                  );
                },
              ),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: novoCliente,
        icon: const Icon(Icons.person_add),
        label: const Text('Novo Cliente'),
      ),
    );
  }
}
