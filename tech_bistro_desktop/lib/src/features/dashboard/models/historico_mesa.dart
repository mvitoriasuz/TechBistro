class HistoricoMesa {
  final int id;
  final DateTime dataFechamento;
  final int numeroMesa;
  final double valorTotal;
  final List<Map<String, dynamic>> itensPedido;
  final Map<String, dynamic> pagamentos;

  HistoricoMesa({
    required this.id,
    required this.dataFechamento,
    required this.numeroMesa,
    required this.valorTotal,
    required this.itensPedido,
    required this.pagamentos,
  });

  factory HistoricoMesa.fromMap(Map<String, dynamic> map) {
    return HistoricoMesa(
      id: map['id'],
      dataFechamento: DateTime.parse(map['data_fechamento']),
      numeroMesa: map['numero_mesa'] ?? 0,
      valorTotal: (map['valor_total'] ?? 0).toDouble(),
      itensPedido: List<Map<String, dynamic>>.from(map['itens_pedido'] ?? []),
      pagamentos: Map<String, dynamic>.from(map['pagamentos'] ?? {}),
    );
  }
}
