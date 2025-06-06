import '../models/produto.dart';
import '../services/database_helper.dart';
import 'package:intl/intl.dart';

class ProdutoController {
  Future<void> salvarProduto(Produto produto) async {
    final db = await BancoHelper().db;
    final existe = await db.query(
      'Produto',
      where: 'id = ?',
      whereArgs: [produto.id],
    );

    if (existe.isEmpty) {
      await db.insert('Produto', produto.toSQL());
    } else {
      if (produto.ultimaAlteracao != '') {
        final now = DateTime.now().toUtc().subtract(const Duration(hours: 3));
        produto.ultimaAlteracao = DateFormat('yyyy-MM-dd HH:mm:ss').format(now);
      }
      await db.update(
        'Produto',
        produto.toSQL(),
        where: 'id = ?',
        whereArgs: [produto.id],
      );
    }
  }

  Future<void> acrescentarUltAlteracao(Produto produto) async {
    final db = await BancoHelper().db;

    final now = DateTime.now().toUtc().subtract(const Duration(hours: 3));
    produto.ultimaAlteracao = DateFormat('yyyy-MM-dd HH:mm:ss').format(now);

    await db.update(
      'Produto',
      produto.toSQL(),
      where: 'id = ?',
      whereArgs: [produto.id],
    );
  }

  Future<void> removerProduto(int id) async {
    final db = await BancoHelper().db;
    await db.delete('Produto', where: 'id = ?', whereArgs: [id]);
  }

  Future<void> inativarProduto(int id) async {
    final db = await BancoHelper().db;
    await db.rawUpdate('UPDATE Produto set isDeleted = 1 where id = ?', [id]);
  }

  Future<List<Produto>> listarProdutos() async {
    final db = await BancoHelper().db;
    final maps = await db.query('Produto', where: 'isDeleted = 0');
    return List.generate(maps.length, (i) => Produto.fromJson(maps[i]));
  }

  Future<List<Produto>> listarAllProdutos() async {
    final db = await BancoHelper().db;
    final maps = await db.query('Produto');
    return List.generate(maps.length, (i) => Produto.fromJson(maps[i]));
  }

  Future<Produto?> buscarPorId(int id) async {
    final db = await BancoHelper().db;
    final maps = await db.query('Produto', where: 'id = ?', whereArgs: [id]);

    if (maps.isNotEmpty) {
      return Produto.fromJson(maps.first);
    } else {
      return null;
    }
  }
}
