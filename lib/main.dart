import 'package:flutter/material.dart';
import 'dart:convert';
import 'package:shared_preferences/shared_preferences.dart';
import 'SublistPage.dart';

void main() {
  runApp(MyApp());
}

class MyApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Listas de Listas',
      theme: ThemeData(
        primarySwatch: Colors.red,
      ),
      home: HomePage(),
    );
  }
}

class HomePage extends StatefulWidget {
  @override
  _HomePageState createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  List<String> lists = [];

  @override
  void initState() {
    super.initState();
    _loadLists();
  }

  _loadLists() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    String? storedLists = prefs.getString('lists');
    if (storedLists != null) {
      setState(() {
        lists = List<String>.from(json.decode(storedLists));
      });
    }
  }

  _saveLists() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    prefs.setString('lists', json.encode(lists));
  }

  _addList() {
    TextEditingController controller = TextEditingController();
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: Text('Agregar tu lista'),
          content: TextField(
            controller: controller,
            decoration: InputDecoration(hintText: 'Nombre de la Lista'),
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
                  lists.add(controller.text);
                  _saveLists();
                });
                Navigator.of(context).pop();
              },
            ),
          ],
        );
      },
    );
  }

  _deleteList(int index) {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: Text('Confirmar Eliminación'),
          content: Text('¿Estás seguro de que quieres eliminar esta lista?'),
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
                  lists.removeAt(index);
                  _saveLists();
                });
                Navigator.of(context).pop();
              },
            ),
          ],
        );
      },
    );
  }

  _editList(int index) {
    TextEditingController controller = TextEditingController();
    controller.text = lists[index];
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: Text('Editar Lista'),
          content: TextField(
            controller: controller,
            decoration: InputDecoration(hintText: 'Nombre de la Lista'),
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
                  lists[index] = controller.text;
                  _saveLists();
                });
                Navigator.of(context).pop();
              },
            ),
          ],
        );
      },
    );
  }

  void _reorderList(int oldIndex, int newIndex) {
    setState(() {
      if (newIndex > oldIndex) {
        newIndex -= 1;
      }
      final String item = lists.removeAt(oldIndex);
      lists.insert(newIndex, item);
      _saveLists();
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Listas'),
      ),
      body: ReorderableListView(
        onReorder: _reorderList,
        children: [
          for (int i = 0; i < lists.length; i++)
            Dismissible(
              key: Key(lists[i]),
              onDismissed: (direction) {
                _deleteList(i); 
              },
              confirmDismiss: (direction) async {
                return await showDialog(
                  context: context,
                  builder: (BuildContext context) {
                    return AlertDialog(
                      title: Text('Confirmar Eliminación'),
                      content: Text('¿Estás seguro de que quieres eliminar esta lista?'),
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
              background: Container(color: Colors.blueGrey),
              child: ListTile(
                title: Text(lists[i]),
                trailing: IconButton(
                  icon: Icon(Icons.edit),
                  onPressed: () {
                    _editList(i);
                  },
                ),
                onTap: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (context) => SublistPage(listName: lists[i]),
                    ),
                  );
                },
              ),
            ),
        ],
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: _addList,
        tooltip: 'Agregar Lista',
        child: Icon(Icons.add),
      ),
    );
  }
}
