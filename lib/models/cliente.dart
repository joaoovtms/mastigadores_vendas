class Cliente {
  int? id;
  String nome;
  String tipo;
  String cpfCnpj;
  String? email;
  String? telefone;
  String? cep;
  String? endereco;
  String? bairro;
  String? cidade;
  String? uf;
  String? ultimaAlteracao;
  bool isDeleted;

  Cliente({
    this.id,
    required this.nome,
    required this.tipo,
    required this.cpfCnpj,
    this.email,
    this.telefone,
    this.cep,
    this.endereco,
    this.bairro,
    this.cidade,
    this.uf,
    this.ultimaAlteracao,
    this.isDeleted = false,
  });

  Map<String, dynamic> toSQL() => {
    'id': id,
    'nome': nome,
    'tipo': tipo,
    'cpfCnpj': cpfCnpj.toString(),
    'email': email,
    'telefone': telefone,
    'cep': cep,
    'endereco': endereco,
    'bairro': bairro,
    'cidade': cidade,
    'uf': uf,
    'ultimaAlteracao': ultimaAlteracao,
    'isDeleted': isDeleted ? 1 : 0,
  };

  Map<String, dynamic> toJsonServidor() => {
    'id': id,
    'nome': nome,
    'tipo': tipo,
    'cpfCnpj': cpfCnpj.toString(),
    'email': email ?? "",
    'telefone': telefone ?? "",
    'cep': cep ?? "",
    'endereco': endereco ?? "",
    'bairro': bairro ?? "",
    'cidade': cidade ?? "",
    'uf': uf ?? "",
    'dataAlteracao': ultimaAlteracao,
    'isDeleted': isDeleted ? 1 : 0,
  };

  factory Cliente.fromJson(Map<String, dynamic> json) => Cliente(
    id: json['id'],
    nome: json['nome'],
    tipo: json['tipo'],
    cpfCnpj: json['cpfCnpj'],
    email: json['email'],
    telefone: json['telefone'],
    cep: json['cep'],
    endereco: json['endereco'],
    bairro: json['bairro'],
    cidade: json['cidade'],
    uf: json['uf'],
    ultimaAlteracao: json['ultimaAlteracao'],
    isDeleted: (json['isDeleted'] ?? 0) == 1,
  );
}
