import 'package:flutter/material.dart';
import '../controllers/cliente_controller.dart';
import '../controllers/pedido_controller.dart';
import '../controllers/usuario_controller.dart';
import '../models/usuario.dart';
import '../models/cliente.dart';
import '../models/pedido.dart';
import '../models/pedido_item.dart';
import '../models/pedido_pagamento.dart';
import 'form_pedido_item.dart';
import 'form_pedido_pagamento.dart';

class FormPedido extends StatefulWidget {
  final Pedido? pedido;

  const FormPedido({super.key, this.pedido});

  @override
  State<FormPedido> createState() => _FormPedidoState();
}

class _FormPedidoState extends State<FormPedido> {
  final PedidoController pedidoController = PedidoController();
  final ClienteController clienteController = ClienteController();
  final UsuarioController usuarioController = UsuarioController();

  List<Usuario> usuarios = [];
  Usuario? usuarioSelecionado;

  List<Cliente> clientes = [];
  Cliente? clienteSelecionado;

  List<PedidoItem> itens = [];
  List<PedidoPagamento> pagamentos = [];

  double totalItens = 0.0;
  double totalPagamentos = 0.0;

  @override
  void initState() {
    super.initState();
    carregarDados();
  }

  void carregarDados() async {
    usuarios = await usuarioController.listarUsuarios();
    clientes = await clienteController.loadClientes();

    if (widget.pedido != null) {
      final pedidoCompleto = await pedidoController.buscarPedidoCompleto(
        widget.pedido!.id!,
      );
      final pedido = pedidoCompleto['pedido'] as Pedido;

      setState(() {
        clienteSelecionado = clientes.firstWhere(
          (c) => c.id == pedido.idCliente,
          orElse: () => clientes.first,
        );
        usuarioSelecionado = usuarios.firstWhere(
          (u) => u.id == pedido.idUsuario,
          orElse: () => usuarios.first,
        );

        itens = List<PedidoItem>.from(pedidoCompleto['itens']);
        pagamentos = List<PedidoPagamento>.from(pedidoCompleto['pagamentos']);
        recalcularTotais();
      });
    } else {
      setState(() {});
    }
  }

  void adicionarItem() async {
    final resultado = await Navigator.push(
      context,
      MaterialPageRoute(builder: (_) => const FormPedidoItem()),
    );

    if (resultado != null && resultado is PedidoItem) {
      setState(() {
        itens.add(resultado);
        recalcularTotais();
      });
    }
  }

  void adicionarPagamento() async {
    final resultado = await Navigator.push(
      context,
      MaterialPageRoute(builder: (_) => const FormPedidoPagamento()),
    );

    if (resultado != null && resultado is PedidoPagamento) {
      setState(() {
        pagamentos.add(resultado);
        recalcularTotais();
      });
    }
  }

  void removerItem(int index) {
    setState(() {
      itens.removeAt(index);
      recalcularTotais();
    });
  }

  void removerPagamento(int index) {
    setState(() {
      pagamentos.removeAt(index);
      recalcularTotais();
    });
  }

  void recalcularTotais() {
    totalItens = itens.fold(0.0, (sum, item) => sum + item.totalItem);
    totalPagamentos = pagamentos.fold(
      0.0,
      (sum, pag) => sum + pag.valorPagamento,
    );
  }

  void mostrarErro(String mensagem) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text(mensagem), backgroundColor: Colors.red),
    );
  }

  void salvarPedido() async {
    if (clienteSelecionado == null) {
      mostrarErro('Selecione um cliente.');
      return;
    }

    if (usuarioSelecionado == null) {
      mostrarErro('Selecione um usuário.');
      return;
    }

    if (itens.isEmpty) {
      mostrarErro('Adicione pelo menos 1 item.');
      return;
    }

    if (pagamentos.isEmpty) {
      mostrarErro('Adicione pelo menos 1 pagamento.');
      return;
    }

    if (totalItens != totalPagamentos) {
      mostrarErro('Total de pagamentos deve ser igual ao total dos itens.');
      return;
    }

    final pedido = Pedido(
      id: widget.pedido?.id,
      idCliente: clienteSelecionado!.id!,
      idUsuario: usuarioSelecionado!.id!,
      totalPedido: totalItens,
      ultimaAlteracao: '',
    );

    await pedidoController.salvarPedidoCompleto(pedido, itens, pagamentos);

    if (context.mounted) {
      Navigator.pop(context, true);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Pedido')),
      body: Padding(
        padding: const EdgeInsets.all(16),
        child: SingleChildScrollView(
          child: Column(
            children: [
              clientes.isEmpty
                  ? const CircularProgressIndicator()
                  : DropdownButtonFormField<Cliente>(
                    value: clienteSelecionado,
                    items:
                        clientes
                            .map(
                              (c) => DropdownMenuItem(
                                value: c,
                                child: Text(c.nome),
                              ),
                            )
                            .toList(),
                    onChanged:
                        (value) => setState(() => clienteSelecionado = value),
                    decoration: const InputDecoration(labelText: 'Cliente'),
                  ),
              const SizedBox(height: 12),
              usuarios.isEmpty
                  ? const CircularProgressIndicator()
                  : DropdownButtonFormField<Usuario>(
                    value: usuarioSelecionado,
                    items:
                        usuarios
                            .map(
                              (u) => DropdownMenuItem(
                                value: u,
                                child: Text(u.nome),
                              ),
                            )
                            .toList(),
                    onChanged:
                        (value) => setState(() => usuarioSelecionado = value),
                    decoration: const InputDecoration(labelText: 'Usuário'),
                  ),
              const SizedBox(height: 12),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  const Text(
                    'Itens',
                    style: TextStyle(fontWeight: FontWeight.bold),
                  ),
                  ElevatedButton(
                    onPressed: adicionarItem,
                    child: const Text('Adicionar'),
                  ),
                ],
              ),
              ListView.builder(
                shrinkWrap: true,
                physics: const NeverScrollableScrollPhysics(),
                itemCount: itens.length,
                itemBuilder: (context, index) {
                  final item = itens[index];
                  return Card(
                    margin: const EdgeInsets.symmetric(vertical: 4),
                    child: ListTile(
                      title: Text(
                        'Produto: ${item.idProduto}, Qtd: ${item.quantidade}, Total: R\$ ${item.totalItem.toStringAsFixed(2)}',
                      ),
                      trailing: IconButton(
                        icon: const Icon(Icons.delete, color: Colors.red),
                        onPressed: () => removerItem(index),
                      ),
                    ),
                  );
                },
              ),
              const SizedBox(height: 12),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  const Text(
                    'Pagamentos',
                    style: TextStyle(fontWeight: FontWeight.bold),
                  ),
                  ElevatedButton(
                    onPressed: adicionarPagamento,
                    child: const Text('Adicionar'),
                  ),
                ],
              ),
              ListView.builder(
                shrinkWrap: true,
                physics: const NeverScrollableScrollPhysics(),
                itemCount: pagamentos.length,
                itemBuilder: (context, index) {
                  final pag = pagamentos[index];
                  return Card(
                    margin: const EdgeInsets.symmetric(vertical: 4),
                    child: ListTile(
                      title: Text(
                        'Valor: R\$ ${pag.valorPagamento.toStringAsFixed(2)}',
                      ),
                      trailing: IconButton(
                        icon: const Icon(Icons.delete, color: Colors.red),
                        onPressed: () => removerPagamento(index),
                      ),
                    ),
                  );
                },
              ),
              const SizedBox(height: 12),
              Text('Total Itens: R\$ ${totalItens.toStringAsFixed(2)}'),
              Text(
                'Total Pagamentos: R\$ ${totalPagamentos.toStringAsFixed(2)}',
              ),
              Text(
                'Total Diferença: R\$ ${(totalItens - totalPagamentos).toStringAsFixed(2)}',
              ),
              const SizedBox(height: 24),
              ElevatedButton(
                onPressed: salvarPedido,
                style: ElevatedButton.styleFrom(
                  backgroundColor: const Color(0xFFDC3002),
                  foregroundColor: Colors.white,
                  padding: const EdgeInsets.symmetric(
                    vertical: 14,
                    horizontal: 25,
                  ),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                ),
                child: const Text('Salvar Pedido'),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
