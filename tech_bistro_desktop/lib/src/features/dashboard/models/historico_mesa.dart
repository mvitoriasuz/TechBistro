class HistoricoMesa {
  final int id;
  final DateTime? dataFechamento;
  final int numeroMesa;
  final double valorTotal;
  final List<dynamic> itensPedido;
  final List<dynamic> pagamentos;

  HistoricoMesa({
    required this.id,
    this.dataFechamento,
    required this.numeroMesa,
    required this.valorTotal,
    required this.itensPedido,
    required this.pagamentos,
  });

  factory HistoricoMesa.fromJson(Map<String, dynamic> json) {
    return HistoricoMesa(
      id: json['id'] ?? 0,
      dataFechamento: json['data_fechamento'] != null 
          ? DateTime.tryParse(json['data_fechamento'].toString()) 
          : null,
      numeroMesa: int.tryParse(json['numero_mesa'].toString()) ?? 0,
      valorTotal: double.tryParse((json['valor_total'] ?? 0).toString()) ?? 0.0,
      itensPedido: json['itens_pedido'] is List ? json['itens_pedido'] : [],
      pagamentos: json['pagamentos'] is List ? json['pagamentos'] : [],
    );
  }
}