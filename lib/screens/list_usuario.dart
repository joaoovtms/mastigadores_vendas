import 'package:flutter/material.dart';
import '../controllers/usuario_controller.dart';
import '../models/usuario.dart';
import 'form_usuario.dart';
import 'home_screen.dart';
import '../components/drawer_menu.dart';

class ListarUsuariosScreen extends StatefulWidget {
  const ListarUsuariosScreen({super.key});

  @override
  State<ListarUsuariosScreen> createState() => _ListarUsuariosScreenState();
}

class _ListarUsuariosScreenState extends State<ListarUsuariosScreen> {
  final controller = UsuarioController();

  List<Usuario> usuarios = [];

  @override
  void initState() {
    super.initState();
    carregar();
  }

  Future<void> carregar() async {
    usuarios = await controller.listarUsuarios();
    for (final usuario in usuarios) {
      print(usuario.toJsonServidor());
    }
    setState(() {});
  }

  Future<void> remover(int id) async {
    final confirm = await showDialog<bool>(
      context: context,
      builder:
          (_) => AlertDialog(
            title: const Text('Confirmar exclusão'),
            content: const Text('Deseja excluir este usuário?'),
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
      await controller.inativarUsuario(id);
      await carregar();
    }
  }

  void editar(Usuario usuario) async {
    final result = await Navigator.push(
      context,
      MaterialPageRoute(builder: (_) => FormUsuario(usuario: usuario)),
    );

    if (result == true) {
      carregar();
    }
  }

  void novoUsuario() async {
    final result = await Navigator.push(
      context,
      MaterialPageRoute(builder: (_) => const FormUsuario()),
    );

    if (result == true) {
      carregar();
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Usuários')),
      drawer: DrawerCustom(),
      body:
          usuarios.isEmpty
              ? const Center(child: Text('Nenhum usuário cadastrado.'))
              : ListView.builder(
                padding: const EdgeInsets.all(16),
                itemCount: usuarios.length,
                itemBuilder: (context, index) {
                  final u = usuarios[index];
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
                        u.nome,
                        style: const TextStyle(
                          fontWeight: FontWeight.w600,
                          color: Color(0xFF00123C),
                        ),
                      ),
                      subtitle: Text(
                        'ID: ${u.id}',
                        style: const TextStyle(color: Colors.black54),
                      ),
                      trailing: IconButton(
                        icon: const Icon(
                          Icons.delete,
                          color: Color(0xFFDC3002),
                        ),
                        onPressed: () => remover(u.id!),
                        tooltip: 'Excluir',
                      ),
                      onTap: () => editar(u),
                    ),
                  );
                },
              ),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: novoUsuario,
        icon: const Icon(Icons.person_add),
        label: const Text('Novo Usuário'),
      ),
    );
  }
}
