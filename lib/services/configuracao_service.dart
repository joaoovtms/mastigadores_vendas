import '../models/configuracao.dart';
import '../controllers/configuracao_controllers.dart';

class ConfiguracaoService {
  static final ConfiguracaoDao _dao = ConfiguracaoDao();

  static Future<String> getConfiguracao(String chave) async {
    final config = await _dao.obterConfiguracao();

    if (config == null) {
      throw Exception('Configuração não encontrada.');
    }

    if (chave == 'url_servidor') {
      return config.servidor;
    }

    throw Exception('Chave de configuração inválida.');
  }

  static Future<void> setConfiguracao(Configuracao config) async {
    await _dao.salvarConfiguracao(config);
  }
}
