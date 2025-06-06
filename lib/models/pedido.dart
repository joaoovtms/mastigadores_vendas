class Pedido {
  int? id;
  int idCliente;
  int idUsuario;
  double? totalPedido;
  String ultimaAlteracao;
  bool isDeleted;

  Pedido({
    this.id,
    required this.idCliente,
    required this.idUsuario,
    this.totalPedido,
    required this.ultimaAlteracao,
    this.isDeleted = false,
  });

  factory Pedido.fromJson(Map<String, dynamic> json) {
    return Pedido(
      id: json['id'],
      idCliente: int.parse(json['idCliente'].toString()),
      idUsuario: int.parse(json['idUsuario'].toString()),
      totalPedido: json['totalPedido'],
      ultimaAlteracao: json['ultimaAlteracao'] ?? '',
      isDeleted: (json['isDeleted'] ?? 0).toString() == '1',
    );
  }

  Map<String, dynamic> toSQL() {
    return {
      'id': id,
      'idCliente': idCliente,
      'idUsuario': idUsuario,
      'totalPedido': totalPedido,
      'ultimaAlteracao': ultimaAlteracao,
      'isDeleted': isDeleted ? 1 : 0,
    };
  }

  Map<String, dynamic> toJsonServidor() => {
    'id': id,
    'idCliente': idCliente,
    'idUsuario': idUsuario,
    'totalPedido': totalPedido,
    'ultimaAlteracao': ultimaAlteracao,
    'isDeleted': isDeleted ? 1 : 0,
  };
}
