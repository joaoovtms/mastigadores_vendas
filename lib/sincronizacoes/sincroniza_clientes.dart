import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:intl/intl.dart';

import '../models/cliente.dart';
import '../controllers/cliente_controller.dart';
import '../controllers/configuracao_controllers.dart';

class SincronizacaoCliente {
  final ClienteController clienteController = ClienteController();
  final ConfiguracaoDao configuracaoController = ConfiguracaoDao();

  /// Pega URL do servidor a partir da tabela de Configuração.
  Future<String> _obterUrlServidor() async {
    final config = await configuracaoController.obterConfiguracao();
    if (config == null)
      throw Exception('Configuração de servidor não encontrada!');
    return config.servidor;
  }

  /// SINCRONIZAÇÃO DE CLIENTES

  /// 1. Buscar do servidor e atualizar local
  Future<void> sincronizarClientes() async {
    final url = await _obterUrlServidor();
    final response = await http.get(Uri.parse('$url/clientes'));

    if (response.statusCode == 200) {
      final Map<String, dynamic> serverResponse = jsonDecode(response.body);
      final List<dynamic> serverData = serverResponse['dados'] ?? [];

      for (final item in serverData) {
        final clienteServidor = Cliente.fromJson(item);
        final clienteLocal = await clienteController.buscarPorId(
          clienteServidor.id!,
        );
        if (clienteLocal == null) {
          await clienteController.salvarCliente(clienteServidor);
        } else if (DateTime.parse(
          clienteServidor.ultimaAlteracao!,
        ).isAfter(DateTime.parse(clienteLocal.ultimaAlteracao!))) {
          await clienteController.salvarCliente(clienteServidor);
        }
      }
    } else {
      throw Exception('Erro ao buscar clientes do servidor');
    }
  }

  /// 2. Enviar clientes locais para o servidor
  Future<void> enviarClientesParaServidor() async {
    final url = await _obterUrlServidor();
    final clientes = await clienteController.loadClientes();

    for (final cliente in clientes) {
      final now = DateTime.now().toUtc().subtract(const Duration(hours: 3));
      cliente.ultimaAlteracao = DateFormat('yyyy-MM-dd HH:mm:ss').format(now);
      final response = await http.post(
        Uri.parse('$url/clientes'),
        headers: {'Content-Type': 'application/json'},
        body: jsonEncode(cliente.toJsonServidor()),
      );
      await clienteController.acrescentarUltAlteracao(cliente);

      if (response.statusCode >= 200 && response.statusCode < 300) {
        print(
          '✅ Cliente ID: ${cliente.id} enviado para o servidor com sucesso.',
        );
      } else {
        print('❌ Erro ao enviar cliente ID: ${cliente.id}');
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

  /// 3. Excluir clientes excluídos localmente no servidor
  Future<void> excluirClientesNoServidor() async {
    final url = await _obterUrlServidor();
    final clientes = await clienteController.loadAllClientes();

    for (final cliente in clientes) {
      if (cliente.isDeleted) {
        final response = await http.delete(
          Uri.parse('$url/clientes/${cliente.id}'),
        );

        clienteController.excluirCliente(cliente.id!);

        if (response.statusCode == 200) {
          print('Cliente ${cliente.id} excluído no servidor.');
        } else {
          print('Erro ao excluir cliente ${cliente.id} no servidor.');
        }
      }
    }
  }

  /// 4. Exclui clientes locais
  Future<void> excluiClientesLocal() async {
    final url = await _obterUrlServidor();
    final clientes = await clienteController.loadAllClientes();

    for (final cliente in clientes) {
      if (cliente.ultimaAlteracao! != '') {
        final response = await http.get(
          Uri.parse('$url/clientes/${cliente.id}'),
          headers: {'Content-Type': 'application/json'},
        );

        if (response.body.trim() == '{}') {
          clienteController.excluirCliente(cliente.id!);
          print('✅ Cliente ${cliente.id} excluido localmente.');
        }

        if (response.statusCode <= 200 && response.statusCode > 300) {
          print('❌ Erro ao enviar cliente ID: ${cliente.id}');
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
