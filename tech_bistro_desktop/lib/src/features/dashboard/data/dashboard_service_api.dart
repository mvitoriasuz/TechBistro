import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:tech_bistro_desktop/src/features/dashboard/models/dashboard_models.dart';
import 'dart:convert';

class DashboardServiceApi {
  final SupabaseClient supabase = Supabase.instance.client;

  // ===================== 1) HISTÓRICO =========================

  Future<List<HistoricoMesa>> fetchHistorico() async {
    final res = await supabase
        .from('historico_mesas')
        .select('*')
        .order('data_fechamento', ascending: false);

    return (res as List)
        .map((r) => HistoricoMesa.fromJson(r))
        .toList();
  }

  // ===================== 2) PAGAMENTOS RESUMO ==================

  Future<Map<String, int>> fetchPagamentosResumo() async {
    final res = await supabase
        .from('historico_mesas')
        .select('pagamentos');

    final rows = res as List;
    final Map<String, int> counts = {};

    for (final row in rows) {
      final pagamentosRaw = row['pagamentos'];
      if (pagamentosRaw == null) continue;

      final pagamentosList = _normalizeToListOfMap(pagamentosRaw);

      for (final pg in pagamentosList) {
        final metodo = (pg['metodo'] ??
                pg['Metodo'] ??
                pg['type'] ??
                pg['tipo'] ??
                'Desconhecido')
            .toString();

        counts[metodo] = (counts[metodo] ?? 0) + 1;
      }
    }

    return counts;
  }

  // ===================== 3) TICKET MÉDIO =======================

  Future<double> fetchTicketMedio() async {
    final res = await supabase
        .from('historico_mesas')
        .select('valor_total');

    final rows = res as List;

    double sum = 0;
    int count = 0;

    for (final r in rows) {
      final val = _toDoubleSafe(r['valor_total']);
      if (val != null) {
        sum += val;
        count++;
      }
    }

    return count == 0 ? 0.0 : sum / count;
  }

  // ===================== 4) FATURAMENTO =========================

  Future<Map<String, double>> fetchFaturamento() async {
    final now = DateTime.now();

    final res = await supabase
        .from('historico_mesas')
        .select('valor_total, data_fechamento');

    final rows = res as List;

    double semanal = 0, mensal = 0, trimestral = 0;

    for (final r in rows) {
      final v = _toDoubleSafe(r['valor_total']) ?? 0.0;
      final dt = _parseDateSafe(r['data_fechamento']);
      if (dt == null) continue;

      if (dt.isAfter(now.subtract(const Duration(days: 7)))) semanal += v;
      if (dt.month == now.month && dt.year == now.year) mensal += v;

      final monthsDiff = (now.year - dt.year) * 12 + (now.month - dt.month);
      if (monthsDiff >= 0 && monthsDiff < 3) trimestral += v;
    }

    return {
      'semanal': semanal,
      'mensal': mensal,
      'trimestral': trimestral,
    };
  }

  // ===================== 5) MOVIMENTO POR DIA ===================

  Future<List<MovimentoDia>> fetchMovimentoDia() async {
    final res = await supabase
        .from('historico_mesas')
        .select('data_fechamento');

    final rows = res as List;
    final Map<int, int> counts = {};

    for (final r in rows) {
      final dt = _parseDateSafe(r['data_fechamento']);
      if (dt == null) continue;

      counts[dt.weekday] = (counts[dt.weekday] ?? 0) + 1;
    }

    final List<MovimentoDia> out = counts.entries
        .map((e) => MovimentoDia(
              dia: _diaSemana(e.key),
              total: e.value,
            ))
        .toList();

    out.sort((a, b) => _orderDia(a.dia).compareTo(_orderDia(b.dia)));

    return out;
  }

  // ===================== 6) MOVIMENTO POR HORA ==================

  Future<List<MovimentoHora>> fetchMovimentoHora() async {
    final res = await supabase
        .from('historico_mesas')
        .select('data_fechamento');

    final rows = res as List;
    final Map<int, int> counts = {};

    for (final r in rows) {
      final dt = _parseDateSafe(r['data_fechamento']);
      if (dt == null) continue;

      counts[dt.hour] = (counts[dt.hour] ?? 0) + 1;
    }

    final out = counts.entries
        .map((e) => MovimentoHora(hora: e.key, total: e.value))
        .toList();

    out.sort((a, b) => a.hora.compareTo(b.hora));

    return out;
  }

  // ===============================================================
  // =========================  HELPERS  ===========================
  // ===============================================================

  List<Map<String, dynamic>> _normalizeToListOfMap(dynamic raw) {
    if (raw is List) {
      return raw
          .whereType<Map<String, dynamic>>()
          .toList();
    } else if (raw is String) {
      try {
        final decoded = json.decode(raw);
        if (decoded is List) {
          return decoded
              .whereType<Map<String, dynamic>>()
              .toList();
        }
      } catch (_) {
        return [];
      }
    }
    return [];
  }

  double? _toDoubleSafe(dynamic v) {
    if (v == null) return null;
    if (v is num) return v.toDouble();
    if (v is String) {
      try {
        return double.parse(v.replaceAll(',', '.'));
      } catch (_) {
        return null;
      }
    }
    return null;
  }

  DateTime? _parseDateSafe(dynamic v) {
    if (v == null) return null;
    if (v is DateTime) return v;

    if (v is String) {
      try {
        return DateTime.parse(v);
      } catch (_) {
        try {
          return DateTime.parse(v.replaceAll(' ', 'T'));
        } catch (_) {
          return null;
        }
      }
    }

    return null;
  }

  String _diaSemana(int w) {
    return {
      1: 'Seg',
      2: 'Ter',
      3: 'Qua',
      4: 'Qui',
      5: 'Sex',
      6: 'Sab',
      7: 'Dom'
    }[w]!;
  }

  int _orderDia(String d) {
    const order = ['Seg', 'Ter', 'Qua', 'Qui', 'Sex', 'Sab', 'Dom'];
    return order.indexOf(d);
  }
}
