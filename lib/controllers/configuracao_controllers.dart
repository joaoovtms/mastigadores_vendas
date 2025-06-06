import '../services/database_helper.dart';
import '../models/configuracao.dart';

class ConfiguracaoDao {
  final BancoHelper _bancoHelper = BancoHelper();

  Future<void> salvarConfiguracao(Configuracao config) async {
    final db = await _bancoHelper.db;
    final existing = await db.query(
      'Configuracao',
      where: 'id = ?',
      whereArgs: [config.id],
    );

    if (existing.isEmpty) {
      await db.insert('Configuracao', config.toMap());
    } else {
      await db.update(
        'Configuracao',
        config.toMap(),
        where: 'id = ?',
        whereArgs: [config.id],
      );
    }
  }

  Future<Configuracao?> obterConfiguracao() async {
    final db = await _bancoHelper.db;
    final result = await db.query('Configuracao', limit: 1);

    if (result.isEmpty) return null;

    return Configuracao.fromMap(result.first);
  }
}
