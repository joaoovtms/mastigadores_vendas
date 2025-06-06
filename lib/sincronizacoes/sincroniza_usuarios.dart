import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:intl/intl.dart';

import '../controllers/configuracao_controllers.dart';
import 'package:app_vendas/controllers/usuario_controller.dart';
import '../models/usuario.dart';

class SincronizacaoUsuario {
  final UsuarioController usuarioController = UsuarioController();
  final ConfiguracaoDao configuracaoController = ConfiguracaoDao();

  /// Pega URL do servidor a partir da tabela de Configuração.
  Future<String> _obterUrlServidor() async {
    final config = await configuracaoController.obterConfiguracao();
    if (config == null)
      throw Exception('Configuração de servidor não encontrada!');
    return config.servidor;
  }

  /// SINCRONIZAÇÃO DE USUARIOS

  /// 1. Buscar do servidor e atualizar local
  Future<void> sincronizarUsuarios() async {
    final url = await _obterUrlServidor();
    final response = await http.get(Uri.parse('$url/usuarios'));

    if (response.statusCode == 200) {
      final Map<String, dynamic> serverResponse = jsonDecode(response.body);
      final List<dynamic> serverData = serverResponse['dados'] ?? [];

      for (final item in serverData) {
        final usuarioServidor = Usuario.fromJson(item);
        final usuarioLocal = await usuarioController.buscarPorId(
          usuarioServidor.id!,
        );

        if (usuarioLocal == null) {
          await usuarioController.salvarUsuario(usuarioServidor);
        } else if (usuarioServidor.ultimaAlteracao != null &&
            usuarioLocal.ultimaAlteracao != null &&
            DateTime.parse(
              usuarioServidor.ultimaAlteracao!,
            ).isAfter(DateTime.parse(usuarioLocal.ultimaAlteracao!))) {
          await usuarioController.salvarUsuario(usuarioServidor);
        }
      }
    } else {
      throw Exception('Erro ao buscar usuarios do servidor');
    }
  }

  /// 2. Enviar usuarios locais para o servidor
  Future<void> enviarUsuariosParaServidor() async {
    final url = await _obterUrlServidor();
    final usuarios = await usuarioController.listarUsuarios();

    for (final usuario in usuarios) {
      final now = DateTime.now().toUtc().subtract(const Duration(hours: 3));
      usuario.ultimaAlteracao = DateFormat('yyyy-MM-dd HH:mm:ss').format(now);

      final response = await http.post(
        Uri.parse('$url/usuarios'),
        headers: {'Content-Type': 'application/json'},
        body: jsonEncode(usuario.toJsonServidor()),
      );
      usuarioController.acrescentarUltAlteracao(usuario);

      if (response.statusCode >= 200 && response.statusCode < 300) {
        print(
          '✅ Usuario ID: ${usuario.id} enviado para o servidor com sucesso.',
        );
      } else {
        print('❌ Erro ao enviar usuario ID: ${usuario.id}');
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

  /// 3. Excluir usuarios excluídos localmente no servidor
  Future<void> excluirUsuariosNoServidor() async {
    final url = await _obterUrlServidor();
    final usuarios = await usuarioController.listarAllUsuarios();

    for (final usuario in usuarios) {
      if (usuario.isDeleted) {
        final response = await http.delete(
          Uri.parse('$url/usuarios/${usuario.id}'),
        );

        usuarioController.excluirUsuario(usuario.id!);

        if (response.statusCode == 200) {
          print('Usuario ${usuario.id} excluído no servidor.');
        } else {
          print('Erro ao excluir usuario ${usuario.id} no servidor.');
        }
      }
    }
  }

  /// 4. Exclui usuarios locais
  Future<void> excluiUsuariosLocal() async {
    final url = await _obterUrlServidor();
    final usuarios = await usuarioController.listarAllUsuarios();

    for (final usuario in usuarios) {
      if (usuario.ultimaAlteracao != '') {
        final response = await http.get(
          Uri.parse('$url/usuarios/${usuario.id}'),
          headers: {'Content-Type': 'application/json'},
        );

        if (response.body.trim() == '{}') {
          usuarioController.excluirUsuario(usuario.id!);
          print('✅ Usuario ${usuario.id} excluido localmente.');
        }

        if (response.statusCode <= 200 && response.statusCode > 300) {
          print('❌ Erro ao usuario ID: ${usuario.id}');
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
