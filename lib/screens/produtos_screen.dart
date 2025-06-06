import 'dart:ffi';

import 'package:flutter/material.dart';
import '../controllers/produto_controller.dart';
import '../models/produto.dart';

class ProdutoScreen extends StatefulWidget {
  const ProdutoScreen({super.key});

  @override
  State<ProdutoScreen> createState() => _ProdutoScreenState();
}

class _ProdutoScreenState extends State<ProdutoScreen> {
  final ProdutoController _controller = ProdutoController();
  final _formKey = GlobalKey<FormState>();

  final TextEditingController _nomeController = TextEditingController();
  final TextEditingController _unidadeController = TextEditingController();
  final TextEditingController _qtdEstoqueController = TextEditingController();
  final TextEditingController _precoVendaController = TextEditingController();
  final TextEditingController _custoController = TextEditingController();
  final TextEditingController _codigoBarraController = TextEditingController();

  int _status = 0;
  Produto? _produtoSelecionado;

  List<Produto> produtos = [];

  @override
  void initState() {
    super.initState();
    _carregarProdutos();
  }

  Future<void> _carregarProdutos() async {
    produtos = await _controller.listarProdutos();
    setState(() {});
  }

  void _salvar() async {
    if (_formKey.currentState!.validate()) {
      final produto = Produto(
        id: _produtoSelecionado?.id, // Corrigido aqui
        nome: _nomeController.text,
        unidade: _unidadeController.text,
        qtdEstoque: double.parse(_qtdEstoqueController.text),
        precoVenda: double.parse(_precoVendaController.text),
        Status: _status,
        custo:
            _custoController.text.isNotEmpty
                ? double.parse(_custoController.text)
                : null,
        codigoBarra: _codigoBarraController.text,
        ultimaAlteracao: '',
      );

      if (_produtoSelecionado == null) {
        await _controller.salvarProduto(produto);
      } else {
        await _controller.salvarProduto(produto);
      }

      _limparCampos();
      setState(() {});
    }
  }

  void _editar(Produto produto) {
    _produtoSelecionado = produto;
    _nomeController.text = produto.nome;
    _unidadeController.text = produto.unidade;
    _qtdEstoqueController.text = produto.qtdEstoque.toString();
    _precoVendaController.text = produto.precoVenda.toString();
    _status = produto.Status;
    _custoController.text = produto.custo?.toString() ?? '';
    _codigoBarraController.text = produto.codigoBarra;
    setState(() {});
  }

  void _remover(int? id) async {
    if (id != null) {
      await _controller.inativarProduto(id);
      _limparCampos();
      setState(() {});
    }
  }

  void _limparCampos() {
    _formKey.currentState?.reset();
    _produtoSelecionado = null;
    _nomeController.clear();
    _unidadeController.clear();
    _qtdEstoqueController.clear();
    _precoVendaController.clear();
    _custoController.clear();
    _codigoBarraController.clear();
    _status = 0;
    setState(() {});
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text('Cadastro de Produtos')),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
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
                        (value) => value!.isEmpty ? 'Campo obrigatório' : null,
                  ),
                  TextFormField(
                    controller: _unidadeController,
                    decoration: InputDecoration(labelText: 'Unidade *'),
                    validator:
                        (value) => value!.isEmpty ? 'Campo obrigatório' : null,
                  ),
                  TextFormField(
                    controller: _qtdEstoqueController,
                    decoration: InputDecoration(labelText: 'Qtd. Estoque *'),
                    keyboardType: TextInputType.number,
                    validator:
                        (value) => value!.isEmpty ? 'Campo obrigatório' : null,
                  ),
                  TextFormField(
                    controller: _precoVendaController,
                    decoration: InputDecoration(labelText: 'Preço de Venda *'),
                    keyboardType: TextInputType.number,
                    validator:
                        (value) => value!.isEmpty ? 'Campo obrigatório' : null,
                  ),
                  TextFormField(
                    controller: _custoController,
                    decoration: InputDecoration(labelText: 'Custo'),
                    keyboardType: TextInputType.number,
                  ),
                  TextFormField(
                    controller: _codigoBarraController,
                    decoration: InputDecoration(labelText: 'Código de Barra'),
                  ),
                  DropdownButtonFormField<int>(
                    value: _status,
                    decoration: InputDecoration(labelText: 'Status *'),
                    items: [
                      DropdownMenuItem(value: 0, child: Text('Ativo')),
                      DropdownMenuItem(value: 1, child: Text('Inativo')),
                    ],
                    onChanged:
                        (value) => setState(() {
                          _status = value!;
                        }),
                  ),
                  SizedBox(height: 16),
                  ElevatedButton(
                    onPressed: _salvar,
                    child: Text(
                      _produtoSelecionado == null ? 'Salvar' : 'Atualizar',
                    ),
                  ),
                  if (_produtoSelecionado != null)
                    TextButton(
                      onPressed: _limparCampos,
                      child: Text('Cancelar'),
                    ),
                ],
              ),
            ),
            const Divider(),
            Expanded(
              child: ListView.builder(
                itemCount: produtos.length,
                itemBuilder: (_, index) {
                  final produto = produtos[index];
                  return ListTile(
                    title: Text(produto.nome),
                    subtitle: Text(
                      'Unidade: ${produto.unidade} - Estoque: ${produto.qtdEstoque}',
                    ),
                    trailing: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        IconButton(
                          icon: Icon(Icons.edit, color: Colors.orange),
                          onPressed: () => _editar(produto),
                        ),
                        IconButton(
                          icon: Icon(Icons.delete, color: Colors.red),
                          onPressed: () => _remover(produto.id),
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
