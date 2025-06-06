import 'dart:async';
import 'package:sqflite/sqflite.dart';
import 'package:path/path.dart';

class BancoHelper {
  static Database? _database;
  Future<Database> get db async {
    if (_database == null) _database = await initDB();
    return _database!;
  }

  Future<Database> initDB() async {
    String path = await getDatabasesPath();
    path = join(path, 'banco_vendas.db');
    return await openDatabase(
      path,
      version: 2,
      onCreate: _onCreateBD,
      onUpgrade: _onUpgradeDB,
    );
  }

  Future _onCreateBD(Database db, int version) async {
    await db.execute('''
      CREATE TABLE Cliente(
        id INTEGER PRIMARY KEY AUTOINCREMENT,
        nome TEXT NOT NULL,
        tipo TEXT NOT NULL,
        cpfCnpj TEXT NOT NULL,
        email TEXT,
        telefone TEXT,
        cep TEXT,
        endereco TEXT,
        bairro TEXT,
        cidade TEXT,
        uf TEXT,
        ultimaAlteracao TEXT,
        isDeleted BOOL
      )
    ''');

    await db.execute('''
      CREATE TABLE Produto (
        id INTEGER PRIMARY KEY AUTOINCREMENT,
        nome TEXT NOT NULL,
        unidade TEXT NOT NULL,
        qtdEstoque REAL NOT NULL,
        precoVenda REAL NOT NULL,
        Status INTEGER NOT NULL,
        custo REAL,
        codigoBarra TEXT,
        ultimaAlteracao TEXT,
        isDeleted BOOL
      );
    ''');

    await db.execute('''
      CREATE TABLE Usuario(
        id INTEGER PRIMARY KEY AUTOINCREMENT,
        nome TEXT NOT NULL,
        senha TEXT NOT NULL,
        ultimaAlteracao TEXT,
        isDeleted BOOL
      )
    ''');

    await db.execute('''
      CREATE TABLE Pedido(
        id INTEGER PRIMARY KEY AUTOINCREMENT,
        idCliente INTEGER NOT NULL,
        idUsuario TEXT NOT NULL,
        totalPedido REAL,
        ultimaAlteracao TEXT,
        isDeleted BOOL
      )
    ''');

    await db.execute('''
      CREATE TABLE PedidoItem(
        id INTEGER PRIMARY KEY AUTOINCREMENT,
        idPedido INTEGER NOT NULL,
        idProduto TEXT NOT NULL,
        quantidade INTEGER NOT NULL,
        totalItem REAL NOT NULL
      )
    ''');

    await db.execute('''
      CREATE TABLE PedidoPagamento(
        id INTEGER PRIMARY KEY AUTOINCREMENT,
        idPedido INTEGER NOT NULL,
        valorPagamento REAL NOT NULL
      )
    ''');

    await db.execute('''
      CREATE TABLE Configuracao(
        id INTEGER PRIMARY KEY AUTOINCREMENT,
        servidor TEXT NOT NULL
      )
    ''');
  }

  Future _onUpgradeDB(Database db, int oldVersion, int newVersion) async {
    if (newVersion > oldVersion) {
      await db.execute('ALTER TABLE Cliente ADD COLUMN dataAlteracao TEXT');
      await db.execute('ALTER TABLE Produto ADD COLUMN dataAlteracao TEXT');
      await db.execute('ALTER TABLE Usuario ADD COLUMN dataAlteracao TEXT');
      await db.execute('ALTER TABLE Pedido ADD COLUMN dataAlteracao TEXT');
    }
  }
}
