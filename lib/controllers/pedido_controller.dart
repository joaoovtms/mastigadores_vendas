import 'package:intl/intl.dart';

import '../services/database_helper.dart';
import '../models/pedido.dart';
import '../models/pedido_item.dart';
import '../models/pedido_pagamento.dart';
import 'pedido_item_controller.dart';
import 'pedido_pagamento_controller.dart';

class PedidoController {
  final BancoHelper _bancoHelper = BancoHelper();
  final PedidoItemController itemController = PedidoItemController();
  final PedidoPagamentoController pagamentoController =
      PedidoPagamentoController();

  // ========= Funções básicas (Pedido isolado) =========

  Future<void> salvarPedido(Pedido pedido) async {
    final db = await _bancoHelper.db;
    final maps = await db.query(
      'Pedido',
      where: 'id = ?',
      whereArgs: [pedido.id],
    );

    if (maps.isEmpty) {
      pedido.id = await db.insert('Pedido', pedido.toSQL());
    } else {
      _atualizarData(pedido);
      await db.update(
        'Pedido',
        pedido.toSQL(),
        where: 'id = ?',
        whereArgs: [pedido.id],
      );
    }
  }

  Future<void> acrescentarUltAlteracao(Pedido pedido) async {
    _atualizarData(pedido);
    final db = await _bancoHelper.db;
    await db.update(
      'Pedido',
      pedido.toSQL(),
      where: 'id = ?',
      whereArgs: [pedido.id],
    );
  }

  void _atualizarData(Pedido pedido) {
    final now = DateTime.now().toUtc().subtract(const Duration(hours: 3));
    pedido.ultimaAlteracao = DateFormat('yyyy-MM-dd HH:mm:ss').format(now);
  }

  Future<void> inativarPedido(int id) async {
    final db = await _bancoHelper.db;
    await db.update(
      'Pedido',
      {'isDeleted': 1},
      where: 'id = ?',
      whereArgs: [id],
    );
  }

  Future<void> excluirPedido(int id) async {
    final db = await _bancoHelper.db;
    await db.delete('Pedido', where: 'id = ?', whereArgs: [id]);
  }

  Future<Pedido?> buscarPorId(int id) async {
    final db = await _bancoHelper.db;
    final maps = await db.query('Pedido', where: 'id = ?', whereArgs: [id]);

    if (maps.isNotEmpty) {
      return Pedido.fromJson(maps.first);
    } else {
      return null;
    }
  }

  Future<List<Pedido>> listarPedidos() async {
    final db = await _bancoHelper.db;
    final result = await db.query('Pedido', where: 'isDeleted = 0');
    return result.map((e) => Pedido.fromJson(e)).toList();
  }

  Future<List<Pedido>> listarTodos() async {
    final db = await _bancoHelper.db;
    final result = await db.query('Pedido');
    return result.map((e) => Pedido.fromJson(e)).toList();
  }

  // ========= Funções completas (Pedido + Itens + Pagamentos) =========

  Future<void> salvarPedidoCompleto(
    Pedido pedido,
    List<PedidoItem> itens,
    List<PedidoPagamento> pagamentos,
  ) async {
    final db = await _bancoHelper.db;

    await db.transaction((txn) async {
      final maps = await txn.query(
        'Pedido',
        where: 'id = ?',
        whereArgs: [pedido.id],
      );
      final isNovo = maps.isEmpty;

      if (isNovo) {
        pedido.id = await txn.insert('Pedido', pedido.toSQL());
      } else {
        _atualizarData(pedido);
        await txn.update(
          'Pedido',
          pedido.toSQL(),
          where: 'id = ?',
          whereArgs: [pedido.id],
        );
        await txn.delete(
          'PedidoItem',
          where: 'idPedido = ?',
          whereArgs: [pedido.id],
        );
        await txn.delete(
          'PedidoPagamento',
          where: 'idPedido = ?',
          whereArgs: [pedido.id],
        );
      }

      for (var item in itens) {
        await txn.insert('PedidoItem', {
          'idPedido': pedido.id,
          'idProduto': item.idProduto,
          'quantidade': item.quantidade,
          'totalItem': item.totalItem,
        });
      }

      for (var pagamento in pagamentos) {
        await txn.insert('PedidoPagamento', {
          'idPedido': pedido.id,
          'valorPagamento': pagamento.valorPagamento,
        });
      }
    });
  }

  Future<Map<String, dynamic>> buscarPedidoCompleto(int idPedido) async {
    final pedido = await buscarPorId(idPedido);
    if (pedido == null) throw Exception('Pedido não encontrado');

    final itens = await itemController.listarPorPedido(idPedido);
    final pagamentos = await pagamentoController.listarPorPedido(idPedido);

    return {'pedido': pedido, 'itens': itens, 'pagamentos': pagamentos};
  }

  Future<void> excluirPedidoCompleto(int idPedido) async {
    final db = await _bancoHelper.db;
    await db.transaction((txn) async {
      await txn.delete(
        'PedidoItem',
        where: 'idPedido = ?',
        whereArgs: [idPedido],
      );
      await txn.delete(
        'PedidoPagamento',
        where: 'idPedido = ?',
        whereArgs: [idPedido],
      );
      await txn.delete('Pedido', where: 'id = ?', whereArgs: [idPedido]);
    });
  }
}
