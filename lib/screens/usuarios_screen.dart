import 'package:flutter/material.dart';
import '../controllers/usuario_controller.dart';
import '../models/usuario.dart';

class UsuarioScreen extends StatefulWidget {
  const UsuarioScreen({Key? key}) : super(key: key);

  @override
  State<UsuarioScreen> createState() => _UsuarioScreenState();
}

class _UsuarioScreenState extends State<UsuarioScreen> {
  final _controller = UsuarioController();
  final _formKey = GlobalKey<FormState>();
  final _nomeController = TextEditingController();
  final _senhaController = TextEditingController();
  List<Usuario> usuarios = [];

  int? _idEdicao;

  @override
  void initState() {
    super.initState();
    _carregar();
  }

  Future<void> _carregar() async {
    usuarios = await _controller.listarUsuarios();
    setState(() {});
  }

  Future<void> _salvar() async {
    if (_formKey.currentState!.validate()) {
      final usuario = Usuario(
        id: _idEdicao!,
        nome: _nomeController.text,
        senha: _senhaController.text,
        ultimaAlteracao: '',
      );
      await _controller.salvarUsuario(usuario);

      _limparFormulario();
      await _carregar();
    }
  }

  void _limparFormulario() {
    _formKey.currentState?.reset();
    _nomeController.clear();
    _senhaController.clear();
    _idEdicao = null;
  }

  void _editar(Usuario usuario) {
    setState(() {
      _idEdicao = usuario.id;
      _nomeController.text = usuario.nome;
      _senhaController.text = usuario.senha;
    });
  }

  Future<void> _remover(int id) async {
    await _controller.inativarUsuario(id);
    await _carregar();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text('Cadastro de Usuários')),
      body: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          children: [
            Form(
              key: _formKey,
              child: Column(
                children: [
                  TextFormField(
                    controller: _nomeController,
                    decoration: InputDecoration(labelText: 'Nome *'),
                    validator:
                        (value) =>
                            value == null || value.isEmpty
                                ? 'Informe o nome'
                                : null,
                  ),
                  TextFormField(
                    controller: _senhaController,
                    decoration: InputDecoration(labelText: 'Senha *'),
                    obscureText: true,
                    validator:
                        (value) =>
                            value == null || value.isEmpty
                                ? 'Informe a senha'
                                : null,
                  ),
                  SizedBox(height: 16),
                  ElevatedButton(
                    onPressed: _salvar,
                    child: Text(_idEdicao == null ? 'Cadastrar' : 'Atualizar'),
                  ),
                ],
              ),
            ),
            Divider(),
            Expanded(
              child: ListView.builder(
                itemCount: usuarios.length,
                itemBuilder: (context, index) {
                  final usuario = usuarios[index];
                  return ListTile(
                    title: Text(usuario.nome),
                    subtitle: Text('ID: ${usuario.id}'),
                    trailing: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        IconButton(
                          icon: Icon(Icons.edit),
                          onPressed: () => _editar(usuario),
                        ),
                        IconButton(
                          icon: Icon(Icons.delete),
                          onPressed: () => _remover(usuario.id!),
                        ),
                      ],
                    ),
                  );
                },
              ),
            ),
          ],
        ),
      ),
    );
  }
}
