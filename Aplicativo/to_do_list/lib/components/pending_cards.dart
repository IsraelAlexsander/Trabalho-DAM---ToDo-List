import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter_slidable/flutter_slidable.dart';
import 'package:to_do_list/model/todo_model.dart';
import 'package:to_do_list/services/database.services.dart';
import 'package:to_do_list/utils/dateUtils.dart';
import 'package:to_do_list/utils/orderUtils.dart';
import 'package:to_do_list/utils/snackBarUtils.dart';

class PendingCards extends StatefulWidget {
  const PendingCards({super.key});

  @override
  State<PendingCards> createState() => _PendingCardsState();
}

class _PendingCardsState extends State<PendingCards> {
  User? user = FirebaseAuth.instance.currentUser;
  late String uid;

  final DatabaseService _dbService = DatabaseService();

  @override
  void initState() {
    // TODO: implement initState
    super.initState();
    uid = FirebaseAuth.instance.currentUser!.uid;
  }

  @override
  Widget build(BuildContext context) {
    return StreamBuilder<List<ToDo>>(
      stream: _dbService.todos,
      builder: (context, snapshot) {
        if (snapshot.hasData) {
          List<ToDo> todos = snapshot.data!;
          OrderUtils.orderTodos(todos);
          return ListView.builder(
            shrinkWrap: true,
            physics: NeverScrollableScrollPhysics(),
            itemCount: todos.length,
            itemBuilder: (context, index) {
              ToDo todo = todos[index];
              return Container(
                margin: EdgeInsets.all(10),
                decoration: BoxDecoration(
                  color: UtilsDate.isLate(todo.finish)
                      ? Colors.orangeAccent
                      : Colors.white,
                  borderRadius: BorderRadius.circular(10),
                ),
                child: Slidable(
                    endActionPane:
                        ActionPane(motion: DrawerMotion(), children: [
                      SlidableAction(
                        backgroundColor: Colors.green,
                        foregroundColor: Colors.white,
                        label: "Completar",
                        icon: Icons.done,
                        onPressed: (context) {
                          _dbService.completeTodoItem(todo.id, true);
                          SnackBarUtils.show(
                              context, "Tarefa Completada", Colors.green);
                        },
                      )
                    ]),
                    startActionPane:
                        ActionPane(motion: DrawerMotion(), children: [
                      SlidableAction(
                        backgroundColor: Colors.amber,
                        foregroundColor: Colors.white,
                        label: "Editar",
                        icon: Icons.edit,
                        onPressed: (context) async {
                          _showTaskDialog(context, todo: todo);
                        },
                      ),
                      SlidableAction(
                        backgroundColor: Colors.red,
                        foregroundColor: Colors.white,
                        label: "Apagar",
                        icon: Icons.delete,
                        onPressed: (context) async {
                          SnackBarUtils.show(
                              context, "Tarefa excluida", Colors.red);
                          await _dbService.deleteTodoItem(todo.id);
                        },
                      )
                    ]),
                    key: ValueKey(todo.id),
                    child: ListTile(
                      title: Text(
                        todo.title,
                        style: TextStyle(
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                      subtitle: Text(
                        todo.description,
                      ),
                      trailing: Text(
                        todo.finish,
                        style: TextStyle(
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    )),
              );
            },
          );
        } else {
          return Center(
            child: CircularProgressIndicator(
              color: Colors.white,
            ),
          );
        }
      },
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

    Future<void> _selectDate(BuildContext dialogContext) async {
      DateTime? _data = await showDatePicker(
        context: dialogContext,
        firstDate: DateTime.now(),
        lastDate: DateTime(2100),
      );

      if (_data != null) {
        _finishInController.text = UtilsDate.formatDate(_data);
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
                        _selectDate(context);
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
