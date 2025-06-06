import 'package:flutter/material.dart';
import '../controllers/cliente_controller.dart';
import '../models/cliente.dart';

class ClienteScreen extends StatefulWidget {
  const ClienteScreen({super.key});

  @override
  State<ClienteScreen> createState() => _ClienteScreenState();
}

class _ClienteScreenState extends State<ClienteScreen> {
  final _formKey = GlobalKey<FormState>();
  final ClienteController _controller = ClienteController();

  final _nomeController = TextEditingController();
  final _documentoController = TextEditingController();
  final _emailController = TextEditingController();
  final _telefoneController = TextEditingController();
  final _cepController = TextEditingController();
  final _enderecoController = TextEditingController();
  final _bairroController = TextEditingController();
  final _cidadeController = TextEditingController();
  final _ufController = TextEditingController();

  String _tipo = 'F';
  Cliente? _editingCliente;

  List<Cliente> clientes = [];

  @override
  void initState() {
    super.initState();
    _carregarClientes();
  }

  Future<void> _carregarClientes() async {
    clientes = await _controller.loadClientes();
    setState(() {});
  }

  Future<void> _salvar() async {
    if (_formKey.currentState!.validate()) {
      final cliente = Cliente(
        id: _editingCliente?.id,
        nome: _nomeController.text,
        tipo: _tipo,
        cpfCnpj: _documentoController.text,
        email: _emailController.text,
        telefone: _telefoneController.text,
        cep: _cepController.text,
        endereco: _enderecoController.text,
        bairro: _bairroController.text,
        cidade: _cidadeController.text,
        uf: _ufController.text,
        ultimaAlteracao: DateTime.now().toIso8601String(),
      );

      await _controller.salvarCliente(cliente);
      _limpar();
      await _carregarClientes();
    }
  }

  void _editar(Cliente cliente) {
    _nomeController.text = cliente.nome;
    _documentoController.text = cliente.cpfCnpj;
    _emailController.text = cliente.email ?? '';
    _telefoneController.text = cliente.telefone ?? '';
    _cepController.text = cliente.cep ?? '';
    _enderecoController.text = cliente.endereco ?? '';
    _bairroController.text = cliente.bairro ?? '';
    _cidadeController.text = cliente.cidade ?? '';
    _ufController.text = cliente.uf ?? '';
    _tipo = cliente.tipo;

    setState(() {
      _editingCliente = cliente;
    });
  }

  Future<void> _remover(int id) async {
    await _controller.inativarCliente(id);
    _limpar();
    await _carregarClientes();
  }

  void _limpar() {
    _formKey.currentState?.reset();
    _nomeController.clear();
    _documentoController.clear();
    _emailController.clear();
    _telefoneController.clear();
    _cepController.clear();
    _enderecoController.clear();
    _bairroController.clear();
    _cidadeController.clear();
    _ufController.clear();
    _tipo = 'F';
    _editingCliente = null;
  }

  Widget _buildInput(
    String label,
    TextEditingController controller, {
    bool obrigatorio = false,
  }) {
    return TextFormField(
      controller: controller,
      decoration: InputDecoration(labelText: label),
      validator:
          obrigatorio
              ? (value) =>
                  (value == null || value.trim().isEmpty)
                      ? '$label é obrigatório'
                      : null
              : null,
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Cadastro de Clientes')),
      body: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          children: [
            Form(
              key: _formKey,
              child: Column(
                children: [
                  _buildInput('Nome', _nomeController, obrigatorio: true),
                  DropdownButtonFormField<String>(
                    value: _tipo,
                    items: const [
                      DropdownMenuItem(value: 'F', child: Text('Física')),
                      DropdownMenuItem(value: 'J', child: Text('Jurídica')),
                    ],
                    onChanged: (value) => setState(() => _tipo = value!),
                    decoration: const InputDecoration(labelText: 'Tipo *'),
                  ),
                  _buildInput(
                    'CPF/CNPJ',
                    _documentoController,
                    obrigatorio: true,
                  ),
                  _buildInput('E-mail', _emailController),
                  _buildInput('Telefone', _telefoneController),
                  _buildInput('CEP', _cepController),
                  _buildInput('Endereço', _enderecoController),
                  _buildInput('Bairro', _bairroController),
                  _buildInput('Cidade', _cidadeController),
                  _buildInput('UF', _ufController),
                  const SizedBox(height: 10),
                  Row(
                    children: [
                      ElevatedButton(
                        onPressed: _salvar,
                        child: Text(
                          _editingCliente == null ? 'Adicionar' : 'Atualizar',
                        ),
                      ),
                      const SizedBox(width: 10),
                      if (_editingCliente != null)
                        ElevatedButton(
                          onPressed: _limpar,
                          child: const Text('Cancelar'),
                        ),
                    ],
                  ),
                ],
              ),
            ),
            const SizedBox(height: 20),
            const Text(
              'Lista de Clientes',
              style: TextStyle(fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 10),
            Expanded(
              child: ListView.builder(
                itemCount: clientes.length,
                itemBuilder: (context, index) {
                  final cliente = clientes[index];
                  return ListTile(
                    title: Text(cliente.nome),
                    subtitle: Text(
                      '${cliente.tipo == 'F' ? 'CPF' : 'CNPJ'}: ${cliente.cpfCnpj}',
                    ),
                    trailing: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        IconButton(
                          icon: const Icon(Icons.edit),
                          onPressed: () => _editar(cliente),
                        ),
                        IconButton(
                          icon: const Icon(Icons.delete),
                          onPressed: () => _remover(cliente.id!),
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
