import 'package:supabase_flutter/supabase_flutter.dart';

class PratoService {
  final SupabaseClient supabase;

  PratoService({SupabaseClient? client})
      : supabase = client ?? Supabase.instance.client;

  // Listar pratos de um estabelecimento
  Future<List<Map<String, dynamic>>> listarPratos(String idEstabelecimento) async {
    final response = await supabase
        .from('pratos')
        .select()
        .eq('id_estabelecimento', idEstabelecimento);

    return List<Map<String, dynamic>>.from(response ?? []);
  }

  // Criar prato
  Future<void> criarPrato({
    required String nome,
    required double valor,
    required String categoria,
    required String idEstabelecimento,
    String? descricao,
  }) async {
    await supabase.from('pratos').insert({
      'nome_prato': nome,
      'valor_prato': valor,
      'categoria_prato': categoria,
      'id_estabelecimento': idEstabelecimento,
      'descricao_prato': descricao,
    });
  }

  // Editar prato
  Future<void> editarPrato({
    required int id,
    required String nome,
    required double valor,
    required String categoria,
    String? descricao,
  }) async {
    await supabase.from('pratos').update({
      'nome_prato': nome,
      'valor_prato': valor,
      'categoria_prato': categoria,
      'descricao_prato': descricao,
    }).eq('id', id);
  }

  // Deletar prato
  Future<void> deletarPrato(int id) async {
    await supabase.from('pratos').delete().eq('id', id);
  }
}
