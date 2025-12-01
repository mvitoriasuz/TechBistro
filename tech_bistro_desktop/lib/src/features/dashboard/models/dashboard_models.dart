class DashboardStats {
  final double faturamentoTotal;
  final int totalPedidos;
  final double ticketMedio;
  final Map<String, double> pagamentosPorMetodo;
  final List<VendaDiaria> vendasUltimos7Dias;
  final List<ItemVendido> topItens;

  DashboardStats({
    required this.faturamentoTotal,
    required this.totalPedidos,
    required this.ticketMedio,
    required this.pagamentosPorMetodo,
    required this.vendasUltimos7Dias,
    required this.topItens,
  });

  factory DashboardStats.empty() {
    return DashboardStats(
      faturamentoTotal: 0,
      totalPedidos: 0,
      ticketMedio: 0,
      pagamentosPorMetodo: {},
      vendasUltimos7Dias: [],
      topItens: [],
    );
  }
}

class VendaDiaria {
  final DateTime data;
  final double valor;

  VendaDiaria(this.data, this.valor);
}

class ItemVendido {
  final String nome;
  final int quantidade;
  final double total;

  ItemVendido(this.nome, this.quantidade, this.total);
}