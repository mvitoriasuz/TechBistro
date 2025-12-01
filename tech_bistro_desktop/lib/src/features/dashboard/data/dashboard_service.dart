import '../models/historico_mesa.dart';

class DashboardService {

  Map<String, dynamic> calcularResumo(List<HistoricoMesa> mesas) {
    double faturamentoTotal = 0;
    
    final mesasValidas = mesas.where((m) => m.valorTotal > 0 && m.dataFechamento != null).toList();

    for (var mesa in mesasValidas) {
      faturamentoTotal += mesa.valorTotal;
    }

    double ticketMedio = mesasValidas.isNotEmpty ? faturamentoTotal / mesasValidas.length : 0;

    return {
      'faturamento': faturamentoTotal,
      'atendimentos': mesasValidas.length,
      'ticket_medio': ticketMedio,
    };
  }

  List<Map<String, dynamic>> obterFaturamentoSemanal(List<HistoricoMesa> mesas) {
    Map<int, double> dias = {1: 0, 2: 0, 3: 0, 4: 0, 5: 0, 6: 0, 7: 0};
    
    final mesasRecentes = mesas.where((m) {
      if (m.dataFechamento == null) return false;
      final diff = DateTime.now().difference(m.dataFechamento!);
      return diff.inDays <= 7;
    }).toList();

    for (var mesa in mesasRecentes) {
      dias[mesa.dataFechamento!.weekday] = (dias[mesa.dataFechamento!.weekday] ?? 0) + mesa.valorTotal;
    }

    List<String> labels = ['Seg', 'Ter', 'Qua', 'Qui', 'Sex', 'Sáb', 'Dom'];
    List<Map<String, dynamic>> resultado = [];
    
    for (int i = 1; i <= 7; i++) {
      resultado.add({
        'dia': labels[i - 1],
        'valor': dias[i],
        'index': i - 1,
      });
    }
    return resultado;
  }

  Map<String, double> obterDistribuicaoPagamentos(List<HistoricoMesa> mesas) {
    Map<String, double> distribuicao = {};
    
    for (var mesa in mesas) {
      if (mesa.pagamentos.isNotEmpty) {
        for (var pg in mesa.pagamentos) {
          String metodo = pg['metodo'] ?? pg['forma_pagamento'] ?? 'Outros';
          double valor = double.tryParse((pg['valor'] ?? 0).toString()) ?? 0.0;
          
          distribuicao[metodo] = (distribuicao[metodo] ?? 0) + valor;
        }
      } 
      else if (mesa.valorTotal > 0) {
        distribuicao['Outros'] = (distribuicao['Outros'] ?? 0) + mesa.valorTotal;
      }
    }
    
    return distribuicao;
  }

  List<Map<String, dynamic>> obterPratosMaisVendidos(List<HistoricoMesa> mesas) {
    Map<String, int> contagemPratos = {};

    for (var mesa in mesas) {
      for (var item in mesa.itensPedido) {
        String nome = item['nome'] ?? item['produto'] ?? 'Item desconhecido';
        int qtd = int.tryParse((item['quantidade'] ?? item['qtd'] ?? 1).toString()) ?? 1;
        
        contagemPratos[nome] = (contagemPratos[nome] ?? 0) + qtd;
      }
    }

    var listaOrdenada = contagemPratos.entries.toList()
      ..sort((a, b) => b.value.compareTo(a.value));

    return listaOrdenada.take(5).map((e) => {'prato': e.key, 'qtd': e.value}).toList();
  }

  List<double> obterHorariosPico(List<HistoricoMesa> mesas) {
    List<double> horas = List.filled(24, 0.0);
    for (var mesa in mesas) {
      if (mesa.dataFechamento != null) {
        horas[mesa.dataFechamento!.hour] += 1;
      }
    }
    return horas;
  }
}