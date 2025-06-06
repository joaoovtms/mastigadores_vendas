import 'package:flutter/material.dart';
import '../models/pedido_pagamento.dart';

class FormPedidoPagamento extends StatefulWidget {
  final PedidoPagamento? pagamento;

  const FormPedidoPagamento({super.key, this.pagamento});

  @override
  State<FormPedidoPagamento> createState() => _FormPedidoPagamentoState();
}

class _FormPedidoPagamentoState extends State<FormPedidoPagamento> {
  final valorController = TextEditingController();

  @override
  void initState() {
    super.initState();
    if (widget.pagamento != null) {
      valorController.text = widget.pagamento!.valorPagamento.toString();
    }
  }

  void salvar() {
    final valor = double.tryParse(valorController.text);

    if (valor == null) {
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(const SnackBar(content: Text('Valor inválido!')));
      return;
    }

    final pagamento = PedidoPagamento(
      id: widget.pagamento?.id ?? DateTime.now().millisecondsSinceEpoch,
      valorPagamento: valor,
    );

    Navigator.pop(context, pagamento);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Adicionar Pagamento')),
      body: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          children: [
            TextField(
              controller: valorController,
              decoration: const InputDecoration(labelText: 'Valor'),
              keyboardType: TextInputType.number,
            ),
            const SizedBox(height: 24),
            ElevatedButton(
              onPressed: salvar,
              style: ElevatedButton.styleFrom(
                backgroundColor: const Color(0xFFDC3002),
                foregroundColor: Colors.white,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
              ),
              child: const Text('Salvar Pagamento'),
            ),
          ],
        ),
      ),
    );
  }
}
