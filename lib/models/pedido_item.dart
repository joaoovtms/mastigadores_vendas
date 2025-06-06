class PedidoItem {
  int id;
  int? idPedido;
  int? idProduto;
  double quantidade;
  double totalItem;
  bool isDeleted;

  PedidoItem({
    required this.id,
    this.idPedido,
    required this.idProduto,
    required this.quantidade,
    required this.totalItem,
    this.isDeleted = false,
  });

  Map<String, dynamic> toSQL() => {
    'id': id,
    'idPedido': idPedido,
    'idProduto': idProduto,
    'quantidade': quantidade,
    'totalItem': totalItem,
    'isDeleted': isDeleted ? 1 : 0,
  };

  factory PedidoItem.fromJson(Map<String, dynamic> json) => PedidoItem(
    id: json['id'],
    idPedido: int.parse(json['idPedido'].toString()),
    idProduto: int.parse(json['idProduto'].toString()),
    quantidade: json['quantidade'].toDouble(),
    totalItem: json['totalItem'].toDouble(),
    isDeleted: json['isDeleted'] == 1,
  );
}
