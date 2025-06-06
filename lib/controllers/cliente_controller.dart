import '../models/cliente.dart';
import '../services/database_helper.dart';
import 'dart:convert';
import 'package:intl/intl.dart';
import 'package:http/http.dart' as http;

class ClienteController {
  Future<void> salvarCliente(Cliente cliente) async {
    final db = await BancoHelper().db;
    final maps = await db.query(
      'Cliente',
      where: 'id = ?',
      whereArgs: [cliente.id],
    );

    if (maps.isEmpty) {
      cliente.id = await db.insert('Cliente', cliente.toSQL());
    } else {
      if (cliente.ultimaAlteracao != '') {
        final now = DateTime.now().toUtc().subtract(const Duration(hours: 3));
        cliente.ultimaAlteracao = DateFormat('yyyy-MM-dd HH:mm:ss').format(now);
      }

      await db.update(
        'Cliente',
        cliente.toSQL(),
        where: 'id = ?',
        whereArgs: [cliente.id],
      );
    }
  }

  Future<void> acrescentarUltAlteracao(Cliente cliente) async {
    final db = await BancoHelper().db;

    final now = DateTime.now().toUtc().subtract(const Duration(hours: 3));
    cliente.ultimaAlteracao = DateFormat('yyyy-MM-dd HH:mm:ss').format(now);

    await db.update(
      'Cliente',
      cliente.toSQL(),
      where: 'id = ?',
      whereArgs: [cliente.id],
    );
  }

  Future<void> inativarCliente(int id) async {
    final db = await BancoHelper().db;
    await db.rawUpdate('UPDATE Cliente set isDeleted = 1 where id = ?', [id]);
  }

  Future<void> excluirCliente(int id) async {
    final db = await BancoHelper().db;
    await db.delete('Cliente', where: 'id = ?', whereArgs: [id]);
  }

  Future<List<Cliente>> loadClientes() async {
    final db = await BancoHelper().db;
    final maps = await db.query('Cliente', where: 'isDeleted = 0');
    return List.generate(maps.length, (i) => Cliente.fromJson(maps[i]));
  }

  Future<List<Cliente>> loadAllClientes() async {
    final db = await BancoHelper().db;
    final maps = await db.query('Cliente');
    return List.generate(maps.length, (i) => Cliente.fromJson(maps[i]));
  }

  Future<Cliente?> buscarPorId(int id) async {
    final db = await BancoHelper().db;
    final maps = await db.query('Cliente', where: 'id = ?', whereArgs: [id]);

    if (maps.isNotEmpty) {
      return Cliente.fromJson(maps.first);
    } else {
      return null;
    }
  }

  Future<Map<String, dynamic>?> buscarEnderecoPorCEP(String cep) async {
    try {
      final response = await http.get(
        Uri.parse('https://viacep.com.br/ws/$cep/json/'),
      );

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        if (data['erro'] == true) {
          return null;
        }
        return {
          'endereco': data['logradouro'] ?? '',
          'bairro': data['bairro'] ?? '',
          'cidade': data['localidade'] ?? '',
          'uf': data['uf'] ?? '',
        };
      } else {
        return null;
      }
    } catch (e) {
      print('Erro ao buscar CEP: $e');
      return null;
    }
  }
}
