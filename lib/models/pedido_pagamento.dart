class PedidoPagamento {
  int id;
  int? idPedido;
  double valorPagamento;

  PedidoPagamento({
    required this.id,
    this.idPedido,
    required this.valorPagamento,
  });

  Map<String, dynamic> toSQL() => {
    'id': id,
    'idPedido': idPedido,
    'valorPagamento': valorPagamento,
  };

  factory PedidoPagamento.fromJson(Map<String, dynamic> json) =>
      PedidoPagamento(
        id: json['id'],
        idPedido: json['idPedido'],
        valorPagamento: json['valorPagamento'].toDouble(),
      );
}
