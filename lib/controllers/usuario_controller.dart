import '../models/usuario.dart';
import '../services/database_helper.dart';
import 'package:intl/intl.dart';

class UsuarioController {
  Future<void> salvarUsuario(Usuario usuario) async {
    final db = await BancoHelper().db;
    final existe = await db.query(
      'Usuario',
      where: 'id = ?',
      whereArgs: [usuario.id],
    );

    if (existe.isEmpty) {
      await db.insert('Usuario', usuario.toSQL());
    } else {
      if (usuario.ultimaAlteracao != '') {
        final now = DateTime.now().toUtc().subtract(const Duration(hours: 3));
        usuario.ultimaAlteracao = DateFormat('yyyy-MM-dd HH:mm:ss').format(now);
      }

      await db.update(
        'Usuario',
        usuario.toSQL(),
        where: 'id = ?',
        whereArgs: [usuario.id],
      );
    }
  }

  Future<void> acrescentarUltAlteracao(Usuario usuario) async {
    final db = await BancoHelper().db;

    final now = DateTime.now().toUtc().subtract(const Duration(hours: 3));
    usuario.ultimaAlteracao = DateFormat('yyyy-MM-dd HH:mm:ss').format(now);

    await db.update(
      'Usuario',
      usuario.toSQL(),
      where: 'id = ?',
      whereArgs: [usuario.id],
    );
  }

  Future<void> excluirUsuario(int id) async {
    final db = await BancoHelper().db;
    await db.delete('Usuario', where: 'id = ?', whereArgs: [id]);
  }

  Future<void> inativarUsuario(int id) async {
    final db = await BancoHelper().db;
    await db.rawUpdate('UPDATE Usuario set isDeleted = 1 where id = ?', [id]);
  }

  Future<List<Usuario>> listarUsuarios() async {
    final db = await BancoHelper().db;
    final maps = await db.query('Usuario', where: 'isDeleted = 0');

    return List.generate(maps.length, (i) => Usuario.fromJson(maps[i]));
  }

  Future<List<Usuario>> listarAllUsuarios() async {
    final db = await BancoHelper().db;
    final maps = await db.query('Usuario');

    return List.generate(maps.length, (i) => Usuario.fromJson(maps[i]));
  }

  Future<Usuario?> buscarPorId(int id) async {
    final db = await BancoHelper().db;
    final maps = await db.query('Usuario', where: 'id = ?', whereArgs: [id]);

    if (maps.isNotEmpty) {
      return Usuario.fromJson(maps.first);
    } else {
      return null;
    }
  }

  Future<Usuario?> validarLogin(String nome, String senha) async {
    final db = await BancoHelper().db;

    final result = await db.query(
      'Usuario',
      where: 'nome = ? AND senha = ?',
      whereArgs: [nome, senha],
    );

    if (result.isNotEmpty) {
      return Usuario.fromJson(result.first);
    } else {
      return null;
    }
  }
}
