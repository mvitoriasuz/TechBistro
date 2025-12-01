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
      id: _toInt(json["id"]),
      dataFechamento: json["data_fechamento"] != null
          ? DateTime.tryParse(json["data_fechamento"].toString())
          : null,
      numeroMesa: _toInt(json["numero_mesa"]),
      valorTotal: _toDouble(json["valor_total"]),
      itensPedido: _toList(json["itens_pedido"]),
      pagamentos: _toList(json["pagamentos"]),
    );
  }

  /// ---------- Helpers seguros ---------- ///

  static int _toInt(dynamic v) {
    if (v is int) return v;
    if (v is double) return v.toInt();
    if (v is String) return int.tryParse(v) ?? 0;
    return 0;
  }

  static double _toDouble(dynamic v) {
    if (v is num) return v.toDouble();
    if (v is String) return double.tryParse(v.replaceAll(",", ".")) ?? 0.0;
    return 0.0;
  }

  static List<dynamic> _toList(dynamic v) {
    if (v is List) return v;
    return [];
  }
}


class MovimentoDia {
  final String dia;
  final int total;

  MovimentoDia({required this.dia, required this.total});
}

class MovimentoHora {
  final int hora;
  final int total;

  MovimentoHora({required this.hora, required this.total});
}

class PagamentoResumo {
  final String metodo;
  final double totalValor;

  PagamentoResumo({
    required this.metodo,
    required this.totalValor,
  });

  factory PagamentoResumo.fromJson(Map<String, dynamic> json) {
    return PagamentoResumo(
      metodo: json['metodo'] ?? 'Desconhecido',
      totalValor: _toDouble(json['total']),
    );
  }

  static double _toDouble(dynamic v) {
    if (v is num) return v.toDouble();
    if (v is String) return double.tryParse(v.replaceAll(',', '.')) ?? 0.0;
    return 0.0;
  }
}

class FaturamentoPeriod {
  final int semana;      // exemplo: 1 = semana atual, 2 = semana passada
  final double total;

  FaturamentoPeriod({
    required this.semana,
    required this.total,
  });

  factory FaturamentoPeriod.fromJson(Map<String, dynamic> json) {
    return FaturamentoPeriod(
      semana: json['semana'] ?? 0,
      total: _toDouble(json['total']),
    );
  }

  static double _toDouble(dynamic v) {
    if (v is num) return v.toDouble();
    if (v is String) return double.tryParse(v.replaceAll(',', '.')) ?? 0.0;
    return 0.0;
  }
}