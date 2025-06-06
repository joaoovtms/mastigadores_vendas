import '../services/database_helper.dart';
import '../models/pedido_pagamento.dart';

class PedidoPagamentoController {
  final BancoHelper _bancoHelper = BancoHelper();

  Future<void> salvarPagamento(PedidoPagamento pagamento, int idPedido) async {
    final db = await _bancoHelper.db;
    await db.insert('PedidoPagamento', {
      'idPedido': idPedido,
      'valorPagamento': pagamento.valorPagamento,
    });
  }

  Future<void> salvarPagamentos(
    List<PedidoPagamento> pagamentos,
    int idPedido,
  ) async {
    for (var pag in pagamentos) {
      await salvarPagamento(pag, idPedido);
    }
  }

  Future<List<PedidoPagamento>> listarPorPedido(int idPedido) async {
    final db = await _bancoHelper.db;
    final result = await db.query(
      'PedidoPagamento',
      where: 'idPedido = ?',
      whereArgs: [idPedido],
    );

    return result
        .map(
          (map) => PedidoPagamento.fromJson({
            'id': map['id'],
            'idPedido': map['idPedido'],
            'valorPagamento': map['valorPagamento'],
          }),
        )
        .toList();
  }

  Future<void> excluirPorPedido(int idPedido) async {
    final db = await _bancoHelper.db;
    await db.delete(
      'PedidoPagamento',
      where: 'idPedido = ?',
      whereArgs: [idPedido],
    );
  }
}
