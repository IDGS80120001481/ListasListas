import 'package:flutter/material.dart';
import 'dart:convert';
import 'package:shared_preferences/shared_preferences.dart';

class SublistPage extends StatefulWidget {
  final String listName;

  SublistPage({required this.listName});

  @override
  _SublistPageState createState() => _SublistPageState();
}

class _SublistPageState extends State<SublistPage> {
  List<String> sublist = [];

  @override
  void initState() {
    super.initState();
    _loadSublist();
  }

  _loadSublist() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    String? storedSublist = prefs.getString(widget.listName);
    if (storedSublist != null) {
      setState(() {
        sublist = List<String>.from(json.decode(storedSublist));
      });
    }
  }

  _saveSublist() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    prefs.setString(widget.listName, json.encode(sublist));
  }

  _addSublistItem() {
    TextEditingController controller = TextEditingController();
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: Text('Agregar Elemento'),
          content: TextField(
            controller: controller,
            decoration: InputDecoration(hintText: 'Nombre del Elemento'),
          ),
          actions: <Widget>[
            TextButton(
              child: Text('Cancelar'),
              onPressed: () {
                Navigator.of(context).pop();
              },
            ),
            TextButton(
              child: Text('Agregar'),
              onPressed: () {
                setState(() {
                  sublist.add(controller.text);
                  _saveSublist();
                });
                Navigator.of(context).pop();
              },
            ),
          ],
        );
      },
    );
  }

  _deleteSublistItem(int index) {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: Text('Confirmar Eliminación'),
          content: Text('¿Estás seguro de que quieres eliminar este elemento?'),
          actions: <Widget>[
            TextButton(
              child: Text('Cancelar'),
              onPressed: () {
                Navigator.of(context).pop();
              },
            ),
            TextButton(
              child: Text('Eliminar'),
              onPressed: () {
                setState(() {
                  sublist.removeAt(index);
                  _saveSublist();
                });
                Navigator.of(context).pop();
              },
            ),
          ],
        );
      },
    );
  }

  _editSublistItem(int index) {
    TextEditingController controller = TextEditingController();
    controller.text = sublist[index];
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: Text('Editar Elemento'),
          content: TextField(
            controller: controller,
            decoration: InputDecoration(hintText: 'Nombre del Elemento'),
          ),
          actions: <Widget>[
            TextButton(
              child: Text('Cancelar'),
              onPressed: () {
                Navigator.of(context).pop();
              },
            ),
            TextButton(
              child: Text('Guardar'),
              onPressed: () {
                setState(() {
                  sublist[index] = controller.text;
                  _saveSublist();
                });
                Navigator.of(context).pop();
              },
            ),
          ],
        );
      },
    );
  }

  void _reorderSublist(int oldIndex, int newIndex) {
    setState(() {
      if (newIndex > oldIndex) {
        newIndex -= 1;
      }
      final String item = sublist.removeAt(oldIndex);
      sublist.insert(newIndex, item);
      _saveSublist();
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(widget.listName),
      ),
      body: ReorderableListView(
        onReorder: _reorderSublist,
        children: [
          for (int i = 0; i < sublist.length; i++)
            Dismissible(
              key: Key(sublist[i]),
              onDismissed: (direction) {
                _deleteSublistItem(i); // Llamar al método _deleteSublistItem para mostrar el diálogo
              },
              confirmDismiss: (direction) async {
                return await showDialog(
                  context: context,
                  builder: (BuildContext context) {
                    return AlertDialog(
                      title: Text('Confirmar Eliminación'),
                      content: Text('¿Estás seguro de que quieres eliminar este elemento?'),
                      actions: <Widget>[
                        TextButton(
                          child: Text('Cancelar'),
                          onPressed: () {
                            Navigator.of(context).pop(false);
                          },
                        ),
                        TextButton(
                          child: Text('Eliminar'),
                          onPressed: () {
                            Navigator.of(context).pop(true);
                          },
                        ),
                      ],
                    );
                  },
                );
              },
              background: Container(color: Colors.red),
              child: ListTile(
                title: Text(sublist[i]),
                trailing: IconButton(
                  icon: Icon(Icons.edit),
                  onPressed: () {
                    _editSublistItem(i);
                  },
                ),
              ),
            ),
        ],
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: _addSublistItem,
        tooltip: 'Agregar Elemento',
        child: Icon(Icons.add),
      ),
    );
  }
}