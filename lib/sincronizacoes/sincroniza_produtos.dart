import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:intl/intl.dart';

import '../models/produto.dart';
import '../controllers/produto_controller.dart';
import '../controllers/configuracao_controllers.dart';

class SincronizacaoProduto {
  final ProdutoController produtoController = ProdutoController();
  final ConfiguracaoDao configuracaoController = ConfiguracaoDao();

  /// Pega URL do servidor a partir da tabela de Configuração.
  Future<String> _obterUrlServidor() async {
    final config = await configuracaoController.obterConfiguracao();
    if (config == null)
      throw Exception('Configuração de servidor não encontrada!');
    return config.servidor;
  }

  /// SINCRONIZAÇÃO DE PRODUTOS

  /// 1. Buscar do servidor e atualizar local
  Future<void> sincronizarProdutos() async {
    final url = await _obterUrlServidor();
    final response = await http.get(Uri.parse('$url/produtos'));

    if (response.statusCode == 200) {
      final Map<String, dynamic> serverResponse = jsonDecode(response.body);
      final List<dynamic> serverData = serverResponse['dados'] ?? [];

      for (final item in serverData) {
        final produtoServidor = Produto.fromJson(item);
        final produtoLocal = await produtoController.buscarPorId(
          produtoServidor.id!,
        );

        if (produtoLocal == null) {
          await produtoController.salvarProduto(produtoServidor);
        } else if (DateTime.parse(
          produtoServidor.ultimaAlteracao!,
        ).isAfter(DateTime.parse(produtoLocal.ultimaAlteracao!))) {
          await produtoController.salvarProduto(produtoServidor);
        }
      }
    } else {
      throw Exception('Erro ao buscar produtos do servidor');
    }
  }

  /// 2. Enviar produtos locais para o servidor
  Future<void> enviarProdutosParaServidor() async {
    final url = await _obterUrlServidor();
    final produtos = await produtoController.listarProdutos();

    for (final produto in produtos) {
      final now = DateTime.now().toUtc().subtract(const Duration(hours: 3));
      produto.ultimaAlteracao = DateFormat('yyyy-MM-dd HH:mm:ss').format(now);
      final response = await http.post(
        Uri.parse('$url/produtos'),
        headers: {'Content-Type': 'application/json'},
        body: jsonEncode(produto.toJsonServidor()),
      );
      await produtoController.acrescentarUltAlteracao(produto);

      if (response.statusCode >= 200 && response.statusCode < 300) {
        print(
          '✅ produto ID: ${produto.id} enviado para o servidor com sucesso.',
        );
      } else {
        print('❌ Erro ao enviar produto ID: ${produto.id}');
        print('🔴 Status Code: ${response.statusCode}');

        if (response.headers['content-type']?.contains('application/json') ??
            false) {
          try {
            final jsonBody = jsonDecode(response.body);
            print('🔴 Mensagem do servidor: $jsonBody');
          } catch (e) {
            print('🔴 Não foi possível decodificar a resposta JSON.');
            print('🔴 Body: ${response.body}');
          }
        } else {
          print('🔴 Body: ${response.body}');
        }
      }
    }
  }

  /// 3. Excluir produtos excluídos localmente no servidor
  Future<void> excluirProdutosNoServidor() async {
    final url = await _obterUrlServidor();
    final produtos = await produtoController.listarAllProdutos();

    for (final produto in produtos) {
      if (produto.isDeleted) {
        final response = await http.delete(
          Uri.parse('$url/produtos/${produto.id}'),
        );

        produtoController.removerProduto(produto.id!);

        if (response.statusCode == 200) {
          print('produto ${produto.id} excluído no servidor.');
        } else {
          print('Erro ao excluir produto ${produto.id} no servidor.');
        }
      }
    }
  }

  /// 4. Exclui produtos locais
  Future<void> excluiProdutosLocal() async {
    final url = await _obterUrlServidor();
    final produtos = await produtoController.listarAllProdutos();

    for (final produto in produtos) {
      if (produto.ultimaAlteracao! != '') {
        final response = await http.get(
          Uri.parse('$url/produtos/${produto.id}'),
          headers: {'Content-Type': 'application/json'},
        );

        if (response.body.trim() == '{}') {
          produtoController.removerProduto(produto.id!);
          print('✅ produto ${produto.id} excluido localmente.');
        }

        if (response.statusCode <= 200 && response.statusCode > 300) {
          print('❌ Erro ao enviar produto ID: ${produto.id}');
          print('🔴 Status Code: ${response.statusCode}');

          if (response.headers['content-type']?.contains('application/json') ??
              false) {
            try {
              final jsonBody = jsonDecode(response.body);
              print('🔴 Mensagem do servidor: $jsonBody');
            } catch (e) {
              print('🔴 Não foi possível decodificar a resposta JSON.');
              print('🔴 Body: ${response.body}');
            }
          } else {
            print('🔴 Body: ${response.body}');
          }
        }
      }
    }
  }
}
