import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:intl/intl.dart';

import '../models/pedido.dart';
import '../models/pedido_item.dart';
import '../models/pedido_pagamento.dart';
import '../controllers/pedido_controller.dart';
import '../controllers/pedido_item_controller.dart';
import '../controllers/pedido_pagamento_controller.dart';
import '../controllers/configuracao_controllers.dart';

class SincronizacaoPedido {
  final PedidoController pedidoController = PedidoController();
  final PedidoItemController itemController = PedidoItemController();
  final PedidoPagamentoController pagamentoController =
      PedidoPagamentoController();
  final ConfiguracaoDao configuracaoController = ConfiguracaoDao();

  Future<String> _obterUrlServidor() async {
    final config = await configuracaoController.obterConfiguracao();
    if (config == null)
      throw Exception('Configuração de servidor não encontrada!');
    return config.servidor;
  }

  /// 1. Buscar pedidos do servidor e atualizar localmente
  Future<void> sincronizarPedidos() async {
    final url = await _obterUrlServidor();
    final response = await http.get(Uri.parse('$url/pedidos'));

    if (response.statusCode == 200) {
      final Map<String, dynamic> serverResponse = jsonDecode(response.body);
      final List<dynamic> serverData = serverResponse['dados'] ?? [];

      for (final item in serverData) {
        final pedido = Pedido.fromJson(item);
        final List<PedidoItem> itens =
            (item['itens'] as List<dynamic>)
                .map((e) => PedidoItem.fromJson(e))
                .toList();
        final List<PedidoPagamento> pagamentos =
            (item['pagamentos'] as List<dynamic>)
                .map(
                  (e) => PedidoPagamento.fromJson({
                    ...e,
                    'idPedido': item['id'],
                    'valorPagamento': e['valor'],
                  }),
                )
                .toList();

        final pedidoLocal = await pedidoController.buscarPorId(pedido.id!);

        if (pedidoLocal == null) {
          await pedidoController.salvarPedidoCompleto(
            pedido,
            itens,
            pagamentos,
          );
        } else if (DateTime.parse(
          pedido.ultimaAlteracao!,
        ).isAfter(DateTime.parse(pedidoLocal.ultimaAlteracao!))) {
          await pedidoController.salvarPedidoCompleto(
            pedido,
            itens,
            pagamentos,
          );
        }
      }
    } else {
      throw Exception('Erro ao buscar pedidos do servidor');
    }
  }

  /// 2. Enviar pedidos locais para o servidor
  Future<void> enviarPedidosParaServidor() async {
    final url = await _obterUrlServidor();
    final pedidos = await pedidoController.listarPedidos();

    for (final pedido in pedidos) {
      final itens = await itemController.listarPorPedido(pedido.id!);
      final pagamentos = await pagamentoController.listarPorPedido(pedido.id!);

      final now = DateTime.now().toUtc().subtract(const Duration(hours: 3));
      pedido.ultimaAlteracao = DateFormat('yyyy-MM-dd HH:mm:ss').format(now);

      final body = {
        'id': pedido.id,
        'idCliente': pedido.idCliente,
        'idUsuario': pedido.idUsuario,
        'totalPedido': pedido.totalPedido,
        'ultimaAlteracao': pedido.ultimaAlteracao,
        'itens': itens.map((i) => i.toSQL()).toList(),
        'pagamentos':
            pagamentos
                .map(
                  (p) => {
                    'id': p.id,
                    'idPedido': p.idPedido,
                    'valor': p.valorPagamento,
                  },
                )
                .toList(),
      };

      final response = await http.post(
        Uri.parse('$url/pedidos'),
        headers: {'Content-Type': 'application/json'},
        body: jsonEncode(body),
      );

      await pedidoController.acrescentarUltAlteracao(pedido);

      if (response.statusCode < 200 || response.statusCode >= 300) {
        print(
          'Erro ao enviar pedido ${pedido.id} - Status: ${response.statusCode}',
        );
        print(response.body);
      } else {
        print('Pedido ${pedido.id} sincronizado com sucesso.');
      }
    }
  }

  /// 3. Excluir pedidos marcados como deletados localmente também no servidor
  Future<void> excluirPedidosNoServidor() async {
    final url = await _obterUrlServidor();
    final pedidos = await pedidoController.listarTodos();

    for (final pedido in pedidos) {
      if (pedido.isDeleted) {
        final response = await http.delete(
          Uri.parse('$url/pedidos/${pedido.id}'),
        );

        await pedidoController.excluirPedido(pedido.id!);

        if (response.statusCode == 200) {
          print('Pedido ${pedido.id} excluído no servidor.');
        } else {
          print('Erro ao excluir pedido ${pedido.id} no servidor.');
        }
      }
    }
  }

  /// 4. Excluir localmente os pedidos que não existem mais no servidor
  Future<void> excluirPedidosLocalmenteSeRemovidosNoServidor() async {
    final url = await _obterUrlServidor();
    final pedidos = await pedidoController.listarTodos();

    for (final pedido in pedidos) {
      if (pedido.ultimaAlteracao != '') {
        final response = await http.get(
          Uri.parse('$url/pedidos/${pedido.id}'),
          headers: {'Content-Type': 'application/json'},
        );

        if (response.body.trim() == '{}' || response.statusCode == 404) {
          await pedidoController.excluirPedido(pedido.id!);
          print('Pedido ${pedido.id} excluído localmente.');
        }
      }
    }
  }
}
