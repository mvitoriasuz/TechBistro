import 'package:flutter/material.dart';
import 'usuario_list_view.dart';
import 'usuario_create_form.dart';
import 'usuario_edit_form.dart';

class UsuarioPage extends StatefulWidget {
  const UsuarioPage({super.key});

  @override
  State<UsuarioPage> createState() => _UsuarioPageState();
}

class _UsuarioPageState extends State<UsuarioPage> {
  String screen = "list"; // list | create | edit
  Map<String, dynamic>? usuarioSelecionado;

  void refreshList() {
    // Apenas recarrega a tela voltando para a listagem
    setState(() {
      screen = "list";
    });
  }

  void goToCreate() {
    setState(() {
      usuarioSelecionado = null;
      screen = "create";
    });
  }

  void goToList() {
    setState(() {
      usuarioSelecionado = null;
      screen = "list";
    });
  }

  void goToEdit(Map<String, dynamic> usuario) {
    setState(() {
      usuarioSelecionado = usuario;
      screen = "edit";
    });
  }

  @override
  Widget build(BuildContext context) {
    switch (screen) {
      case "create":
        return UsuarioCreateForm(
          onCancel: goToList,
          onSaved: refreshList,
        );

      case "edit":
        if (usuarioSelecionado == null) {
          return const Center(
            child: Text("Nenhum usuário selecionado."),
          );
        }

        return UsuarioEditForm(
          usuario: usuarioSelecionado!,
          onCancel: goToList,
          onSaved: refreshList,
        );

      default:
        return UsuarioListView(
          onCreate: goToCreate,
          onEdit: goToEdit,
        );
    }
  }
}
