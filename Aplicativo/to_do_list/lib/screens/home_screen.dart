import 'dart:ffi';

import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:to_do_list/components/completed_cards.dart';
import 'package:to_do_list/components/pending_cards.dart';
import 'package:to_do_list/model/todo_model.dart';
import 'package:to_do_list/screens/login_screen.dart';
import 'package:to_do_list/services/auth_services.dart';
import 'package:to_do_list/services/database.services.dart';
import 'package:to_do_list/utils/dateUtils.dart';
import 'package:to_do_list/utils/snackBarUtils.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  int _buttonIndex = 0;

  final _widgets = [
    PendingCards(),
    CompletedCards(),
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Color(0xFF1d2630),
      appBar: AppBar(
        automaticallyImplyLeading: false,
        backgroundColor: Color(0xFF1d2630),
        foregroundColor: Colors.white,
        title: Text("ToDo List"),
        actions: [
          IconButton(
              onPressed: () async {
                await AuthServices().signOut();
                Navigator.pushReplacement(context,
                    MaterialPageRoute(builder: (context) => LoginScreen()));
              },
              icon: Icon(Icons.exit_to_app))
        ],
      ),
      body: SingleChildScrollView(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            SizedBox(height: 20),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
              children: [
                InkWell(
                  borderRadius: BorderRadius.circular(10),
                  onTap: () {
                    setState(() {
                      _buttonIndex = 0;
                    });
                  },
                  child: Container(
                    height: 50,
                    width: MediaQuery.of(context).size.width / 2.2,
                    decoration: BoxDecoration(
                      color: _buttonIndex == 0 ? Colors.indigo : Colors.white,
                      borderRadius: BorderRadius.circular(10),
                    ),
                    child: Center(
                      child: Text(
                        "Pendentes",
                        style: TextStyle(
                            fontSize: _buttonIndex == 0 ? 16 : 14,
                            fontWeight: FontWeight.w500,
                            color: _buttonIndex == 0
                                ? Colors.white
                                : Colors.black38),
                      ),
                    ),
                  ),
                ),
                InkWell(
                  borderRadius: BorderRadius.circular(10),
                  onTap: () {
                    setState(() {
                      _buttonIndex = 1;
                    });
                  },
                  child: Container(
                    height: 50,
                    width: MediaQuery.of(context).size.width / 2.2,
                    decoration: BoxDecoration(
                      color: _buttonIndex == 1 ? Colors.indigo : Colors.white,
                      borderRadius: BorderRadius.circular(10),
                    ),
                    child: Center(
                      child: Text(
                        "Completos",
                        style: TextStyle(
                            fontSize: _buttonIndex == 1 ? 16 : 14,
                            fontWeight: FontWeight.w500,
                            color: _buttonIndex == 1
                                ? Colors.white
                                : Colors.black38),
                      ),
                    ),
                  ),
                )
              ],
            ),
            SizedBox(height: 30),
            _widgets[_buttonIndex],
          ],
        ),
      ),
      floatingActionButton: FloatingActionButton(
        backgroundColor: Colors.white,
        child: Icon(Icons.add),
        onPressed: () {
          _showTaskDialog(context);
        },
      ),
    );
  }

  void _showTaskDialog(BuildContext context, {ToDo? todo}) {
    final TextEditingController _titleController =
        TextEditingController(text: todo?.title);
    final TextEditingController _descriptionController =
        TextEditingController(text: todo?.description);
    final TextEditingController _finishInController =
        TextEditingController(text: todo?.finish != null ? todo?.finish : '');
    final DatabaseService _dbService = DatabaseService();

    Future<void> _selectDate() async {
      DateTime? _data = await showDatePicker(
          context: context,
          firstDate: DateTime(1900),
          lastDate: DateTime(2100));

      if (_data != null) {
        setState(() {
          _finishInController.text = UtilsDate.formatDate(_data);
        });
      }
    }

    showDialog(
        context: context,
        builder: (context) {
          return AlertDialog(
            backgroundColor: Colors.white,
            title: Text(
              todo == null ? "Criar Tarefa" : "Editar Tarefa",
              style: TextStyle(
                fontWeight: FontWeight.w500,
              ),
            ),
            content: SingleChildScrollView(
              child: Container(
                width: MediaQuery.of(context).size.width,
                child: Column(
                  children: [
                    TextField(
                      controller: _titleController,
                      decoration: InputDecoration(
                        labelText: "Título",
                        border: OutlineInputBorder(),
                      ),
                    ),
                    SizedBox(height: 20),
                    TextField(
                      controller: _descriptionController,
                      decoration: InputDecoration(
                        labelText: "Descrição",
                        border: OutlineInputBorder(),
                      ),
                    ),
                    SizedBox(height: 20),
                    TextField(
                      controller: _finishInController,
                      decoration: InputDecoration(
                        labelText: "Termina em",
                        border: OutlineInputBorder(),
                        prefixIcon: Icon(Icons.calendar_today),
                      ),
                      readOnly: true,
                      onTap: () {
                        _selectDate();
                      },
                    ),
                  ],
                ),
              ),
            ),
            actions: [
              TextButton(
                onPressed: () {
                  Navigator.pop(context);
                },
                child: Text("Cancelar"),
              ),
              ElevatedButton(
                style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.indigo,
                    foregroundColor: Colors.white),
                onPressed: () async {
                  if (_finishInController.text.isEmpty &&
                      _titleController.text.isEmpty &&
                      _descriptionController.text.isEmpty) {
                    SnackBarUtils.show(
                        context,
                        "Preencha todos os campos antes de continuar!",
                        Colors.red);
                    return;
                  }

                  if (todo == null) {
                    await _dbService.addTodoItem(
                      _titleController.text,
                      _descriptionController.text,
                      _finishInController.text,
                    );

                    SnackBarUtils.show(context, "Tarefa criada!", Colors.green);
                  } else {
                    await _dbService.updateTodoItem(
                      todo.id,
                      _titleController.text,
                      _descriptionController.text,
                      _finishInController.text,
                    );
                    SnackBarUtils.show(
                        context, "Tarefa editada!", Colors.amber);
                  }

                  Navigator.pop(context);
                },
                child: Text(todo == null ? "Criar" : "Editar"),
              ),
            ],
          );
        });
  }
}
