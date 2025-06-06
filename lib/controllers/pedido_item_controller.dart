import '../services/database_helper.dart';
import '../models/pedido_item.dart';

class PedidoItemController {
  final BancoHelper _bancoHelper = BancoHelper();

  Future<void> salvarItem(PedidoItem item, int idPedido) async {
    final db = await _bancoHelper.db;
    await db.insert('PedidoItem', {
      'idPedido': item.idPedido,
      'idProduto': item.idProduto,
      'quantidade': item.quantidade,
      'totalItem': item.totalItem,
    });
  }

  Future<void> salvarItens(List<PedidoItem> itens, int idPedido) async {
    for (var item in itens) {
      await salvarItem(item, idPedido);
    }
  }

  Future<List<PedidoItem>> listarPorPedido(int idPedido) async {
    final db = await _bancoHelper.db;
    final result = await db.query(
      'PedidoItem',
      where: 'idPedido = ?',
      whereArgs: [idPedido],
    );

    return result
        .map(
          (map) => PedidoItem.fromJson({
            'id': map['id'],
            'idPedido': map['idPedido'],
            'idProduto': map['idProduto'],
            'quantidade': map['quantidade'],
            'totalItem': map['totalItem'],
            'isDeleted': map['isDeleted'] ?? 0,
          }),
        )
        .toList();
  }

  Future<void> excluirPorPedido(int idPedido) async {
    final db = await _bancoHelper.db;
    await db.delete('PedidoItem', where: 'idPedido = ?', whereArgs: [idPedido]);
  }
}
