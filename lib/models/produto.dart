class Produto {
  int? id;
  String nome;
  String unidade;
  double qtdEstoque;
  double precoVenda;
  int Status; // 0 - Ativo, 1 - Inativo
  double? custo;
  String codigoBarra;
  String ultimaAlteracao;
  bool isDeleted;

  Produto({
    this.id,
    required this.nome,
    required this.unidade,
    required this.qtdEstoque,
    required this.precoVenda,
    required this.Status,
    this.custo,
    required this.codigoBarra,
    required this.ultimaAlteracao,
    this.isDeleted = false,
  });

  factory Produto.fromJson(Map<String, dynamic> json) {
    return Produto(
      id: json['id'],
      nome: json['nome'],
      unidade: json['unidade'],
      qtdEstoque: (json['qtdEstoque'] as num).toDouble(),
      precoVenda: (json['precoVenda'] as num).toDouble(),
      Status: json['Status'],
      custo: json['custo'] != null ? (json['custo'] as num).toDouble() : null,
      codigoBarra: json['codigoBarra'],
      ultimaAlteracao: json['ultimaAlteracao'],
      isDeleted: (json['isDeleted'] ?? 0) == 1,
    );
  }

  Map<String, dynamic> toJsonServidor() => {
    'id': id,
    'nome': nome,
    'unidade': unidade,
    'qtdEstoque': qtdEstoque,
    'precoVenda': precoVenda,
    'Status': Status,
    'custo': custo,
    'codigoBarra': codigoBarra,
    'ultimaAlteracao': ultimaAlteracao,
    'isDeleted': isDeleted ? 1 : 0,
  };

  Map<String, dynamic> toSQL() {
    return {
      'id': id,
      'nome': nome,
      'unidade': unidade,
      'qtdEstoque': qtdEstoque,
      'precoVenda': precoVenda,
      'Status': Status,
      'custo': custo,
      'codigoBarra': codigoBarra,
      'ultimaAlteracao': ultimaAlteracao,
      'isDeleted': isDeleted ? 1 : 0,
    };
  }
}
