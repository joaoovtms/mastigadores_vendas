class Usuario {
  int? id;
  String nome;
  String senha;
  String ultimaAlteracao;
  bool isDeleted;

  Usuario({
    this.id,
    required this.nome,
    required this.senha,
    required this.ultimaAlteracao,
    this.isDeleted = false,
  });

  factory Usuario.fromJson(Map<String, dynamic> json) {
    return Usuario(
      id: json['id'],
      nome: json['nome'],
      senha: json['senha'],
      ultimaAlteracao: json['ultimaAlteracao'],
      isDeleted: (json['isDeleted'] ?? 0) == 1,
    );
  }

  Map<String, dynamic> toSQL() {
    return {
      'id': id,
      'nome': nome,
      'senha': senha,
      'ultimaAlteracao': ultimaAlteracao,
      'isDeleted': isDeleted ? 1 : 0,
    };
  }

  Map<String, dynamic> toJsonServidor() => {
    'id': id,
    'nome': nome,
    'senha': senha,
    'ultimaAlteracao': ultimaAlteracao,
    'isDeleted': isDeleted ? 1 : 0,
  };
}
