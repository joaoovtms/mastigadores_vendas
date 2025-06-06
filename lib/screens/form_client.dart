import 'package:flutter/material.dart';
import '../controllers/cliente_controller.dart';
import '../models/cliente.dart';

class CadastroClienteScreen extends StatefulWidget {
  final Cliente? cliente;

  const CadastroClienteScreen({super.key, this.cliente});

  @override
  State<CadastroClienteScreen> createState() => _CadastroClienteScreenState();
}

class _CadastroClienteScreenState extends State<CadastroClienteScreen> {
  final controller = ClienteController();

  final nomeController = TextEditingController();
  final tipoController = TextEditingController();
  final documentoController = TextEditingController();
  final emailController = TextEditingController();
  final telefoneController = TextEditingController();
  final cepController = TextEditingController();
  final enderecoController = TextEditingController();
  final bairroController = TextEditingController();
  final cidadeController = TextEditingController();
  final ultAtualizacao = TextEditingController();
  final ufController = TextEditingController();

  @override
  void initState() {
    super.initState();
    if (widget.cliente != null) {
      nomeController.text = widget.cliente!.nome;
      tipoController.text = widget.cliente!.tipo;
      documentoController.text = widget.cliente!.cpfCnpj;
      emailController.text = widget.cliente!.email ?? '';
      telefoneController.text = widget.cliente!.telefone ?? '';
      cepController.text = widget.cliente!.cep ?? '';
      enderecoController.text = widget.cliente!.endereco ?? '';
      bairroController.text = widget.cliente!.bairro ?? '';
      cidadeController.text = widget.cliente!.cidade ?? '';
      ufController.text = widget.cliente!.uf ?? '';
      ultAtualizacao.text = widget.cliente!.ultimaAlteracao ?? '';
    }
  }

  void salvar() async {
    final cliente = Cliente(
      id: widget.cliente?.id,
      nome: nomeController.text,
      tipo: tipoController.text,
      cpfCnpj: documentoController.text,
      email: emailController.text,
      telefone: telefoneController.text,
      cep: cepController.text,
      endereco: enderecoController.text,
      bairro: bairroController.text,
      cidade: cidadeController.text,
      uf: ufController.text,
      ultimaAlteracao: ultAtualizacao.text,
      isDeleted: false,
    );

    await controller.salvarCliente(cliente);

    if (context.mounted) Navigator.pop(context, true);
  }

  @override
  Widget build(BuildContext context) {
    final isEdit = widget.cliente != null;

    return Scaffold(
      appBar: AppBar(
        title: Text(isEdit ? 'Editar Cliente' : 'Cadastrar Cliente'),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16),
        child: SingleChildScrollView(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              TextField(
                controller: nomeController,
                decoration: const InputDecoration(labelText: 'Nome'),
              ),
              const SizedBox(height: 12),

              TextField(
                controller: tipoController,
                decoration: const InputDecoration(labelText: 'Tipo (F ou J)'),
              ),
              const SizedBox(height: 12),

              TextField(
                controller: documentoController,
                decoration: const InputDecoration(labelText: 'Documento'),
              ),
              const SizedBox(height: 12),

              TextField(
                controller: emailController,
                decoration: const InputDecoration(labelText: 'Email'),
              ),
              const SizedBox(height: 12),

              TextField(
                controller: telefoneController,
                decoration: const InputDecoration(labelText: 'Telefone'),
              ),
              const SizedBox(height: 12),

              Row(
                children: [
                  Expanded(
                    child: TextField(
                      controller: cepController,
                      decoration: const InputDecoration(labelText: 'CEP'),
                    ),
                  ),
                  IconButton(
                    icon: const Icon(Icons.search),
                    onPressed: () async {
                      final cep = cepController.text.trim();
                      if (cep.isNotEmpty) {
                        final endereco = await controller.buscarEnderecoPorCEP(
                          cep,
                        );
                        if (endereco != null) {
                          setState(() {
                            enderecoController.text = endereco['endereco']!;
                            bairroController.text = endereco['bairro']!;
                            cidadeController.text = endereco['cidade']!;
                            ufController.text = endereco['uf']!;
                          });
                          ScaffoldMessenger.of(context).showSnackBar(
                            const SnackBar(
                              content: Text('Endereço carregado com sucesso!'),
                            ),
                          );
                        } else {
                          ScaffoldMessenger.of(context).showSnackBar(
                            const SnackBar(
                              content: Text('CEP não encontrado!'),
                            ),
                          );
                        }
                      }
                    },
                  ),
                ],
              ),
              const SizedBox(height: 12),

              TextField(
                controller: enderecoController,
                decoration: const InputDecoration(labelText: 'Endereço'),
              ),
              const SizedBox(height: 12),

              TextField(
                controller: bairroController,
                decoration: const InputDecoration(labelText: 'Bairro'),
              ),
              const SizedBox(height: 12),

              TextField(
                controller: cidadeController,
                decoration: const InputDecoration(labelText: 'Cidade'),
              ),
              const SizedBox(height: 12),

              TextField(
                controller: ufController,
                decoration: const InputDecoration(labelText: 'UF'),
              ),
              const SizedBox(height: 24),

              ElevatedButton(
                onPressed: salvar,
                style: ElevatedButton.styleFrom(
                  backgroundColor: const Color(0xFFDC3002),
                  foregroundColor: Colors.white,
                  padding: const EdgeInsets.symmetric(vertical: 14),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                ),
                child: Text(isEdit ? 'Atualizar Cliente' : 'Salvar Cliente'),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
