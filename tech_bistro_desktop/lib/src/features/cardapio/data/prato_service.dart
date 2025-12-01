import 'dart:io';
import 'package:supabase_flutter/supabase_flutter.dart';

class PratoService {
  final SupabaseClient supabase;

  PratoService({SupabaseClient? client})
      : supabase = client ?? Supabase.instance.client;

  Future<List<Map<String, dynamic>>> listarPratos(String idEstabelecimento) async {
    final response = await supabase
        .from('pratos')
        .select()
        .eq('id_estabelecimento', idEstabelecimento)
        .order('nome_prato', ascending: true);

    return List<Map<String, dynamic>>.from(response);
  }

  Future<String?> uploadImagem(File imagemFile) async {
    try {
      final bytes = await imagemFile.readAsBytes();
      final fileExt = imagemFile.path.split('.').last;
      final fileName = '${DateTime.now().millisecondsSinceEpoch}.$fileExt';
      
      await supabase.storage.from('imagens_pratos').uploadBinary(
            fileName,
            bytes,
            fileOptions: FileOptions(contentType: 'image/$fileExt'),
          );

      final imageUrl = supabase.storage.from('imagens_pratos').getPublicUrl(fileName);
      return imageUrl;
    } catch (e) {
      throw Exception('Falha no upload da imagem: $e');
    }
  }

  Future<void> criarPrato({
    required String nome,
    required double valor,
    required String categoria,
    required String idEstabelecimento,
    String? descricao,
    String? imagemUrl,
  }) async {
    await supabase.from('pratos').insert({
      'nome_prato': nome,
      'valor_prato': valor,
      'categoria_prato': categoria,
      'id_estabelecimento': idEstabelecimento,
      'descricao_prato': descricao,
      'imagem_url': imagemUrl,
    });
  }

  Future<void> editarPrato({
    required int id,
    required String nome,
    required double valor,
    required String categoria,
    String? descricao,
    String? imagemUrl,
  }) async {
    final Map<String, dynamic> updates = {
      'nome_prato': nome,
      'valor_prato': valor,
      'categoria_prato': categoria,
      'descricao_prato': descricao,
    };

    if (imagemUrl != null) {
      updates['imagem_url'] = imagemUrl;
    }

    await supabase.from('pratos').update(updates).eq('id', id);
  }

  Future<void> deletarPrato(int id) async {
    await supabase.from('pratos').delete().eq('id', id);
  }
}