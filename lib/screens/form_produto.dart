import 'package:flutter/material.dart';
import '../controllers/produto_controller.dart';
import '../models/produto.dart';

class FormProduto extends StatefulWidget {
  final Produto? produto;

  const FormProduto({super.key, this.produto});

  @override
  State<FormProduto> createState() => _FormProdutoState();
}

class _FormProdutoState extends State<FormProduto> {
  final _formKey = GlobalKey<FormState>();
  final ProdutoController controller = ProdutoController();

  final nomeController = TextEditingController();
  final unidadeController = TextEditingController();
  final qtdEstoqueController = TextEditingController();
  final precoVendaController = TextEditingController();
  final custoController = TextEditingController();
  final ultAtualizacaoController = TextEditingController();
  final codigoBarraController = TextEditingController();

  int status = 0;

  @override
  void initState() {
    super.initState();
    if (widget.produto != null) {
      final p = widget.produto!;
      nomeController.text = p.nome;
      unidadeController.text = p.unidade;
      qtdEstoqueController.text = p.qtdEstoque.toString();
      precoVendaController.text = p.precoVenda.toString();
      custoController.text = p.custo.toString();
      precoVendaController.text = p.precoVenda.toString();
      ultAtualizacaoController.text = p.ultimaAlteracao;
      codigoBarraController.text = p.codigoBarra;
      status = p.Status;
    }
  }

  void salvar() async {
    if (_formKey.currentState!.validate()) {
      final produto = Produto(
        id: widget.produto?.id,
        nome: nomeController.text,
        unidade: unidadeController.text,
        qtdEstoque: double.parse(qtdEstoqueController.text),
        precoVenda: double.parse(precoVendaController.text),
        Status: status,
        custo: double.parse(custoController.text),
        codigoBarra: codigoBarraController.text,
        ultimaAlteracao: ultAtualizacaoController.text,
      );

      await controller.salvarProduto(produto);
      if (context.mounted) Navigator.pop(context, true);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Produto')),
      body: Padding(
        padding: const EdgeInsets.all(16),
        child: Form(
          key: _formKey,
          child: ListView(
            children: [
              TextFormField(
                controller: nomeController,
                decoration: const InputDecoration(labelText: 'Nome'),
                validator:
                    (value) => value!.isEmpty ? 'Campo obrigatório' : null,
              ),
              TextFormField(
                controller: unidadeController,
                decoration: const InputDecoration(labelText: 'Unidade'),
              ),
              TextFormField(
                controller: qtdEstoqueController,
                decoration: const InputDecoration(
                  labelText: 'Quantidade em Estoque',
                ),
                keyboardType: TextInputType.number,
              ),
              TextFormField(
                controller: precoVendaController,
                decoration: const InputDecoration(labelText: 'Preço de Venda'),
                keyboardType: TextInputType.number,
              ),
              TextFormField(
                controller: custoController,
                decoration: const InputDecoration(labelText: 'Custo'),
                keyboardType: TextInputType.number,
              ),
              TextFormField(
                controller: codigoBarraController,
                decoration: const InputDecoration(
                  labelText: 'Código de Barras',
                ),
              ),
              DropdownButtonFormField<int>(
                value: status,
                decoration: const InputDecoration(labelText: 'Status'),
                items: const [
                  DropdownMenuItem(value: 0, child: Text('Ativo')),
                  DropdownMenuItem(value: 1, child: Text('Inativo')),
                ],
                onChanged: (value) => setState(() => status = value!),
              ),
              const SizedBox(height: 20),
              ElevatedButton(onPressed: salvar, child: const Text('Salvar')),
            ],
          ),
        ),
      ),
    );
  }
}