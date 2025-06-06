class Configuracao {
  int id;
  String servidor;

  Configuracao({required this.id, required this.servidor});

  Map<String, dynamic> toMap() => {'id': id, 'servidor': servidor};

  factory Configuracao.fromMap(Map<String, dynamic> map) =>
      Configuracao(id: map['id'], servidor: map['servidor']);
}
