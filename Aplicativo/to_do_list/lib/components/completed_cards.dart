import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter_slidable/flutter_slidable.dart';
import 'package:to_do_list/model/todo_model.dart';
import 'package:to_do_list/services/database.services.dart';
import 'package:to_do_list/utils/orderUtils.dart';
import 'package:to_do_list/utils/snackBarUtils.dart';

class CompletedCards extends StatefulWidget {
  const CompletedCards({super.key});

  @override
  State<CompletedCards> createState() => _CompletedCardsState();
}

class _CompletedCardsState extends State<CompletedCards> {
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
      stream: _dbService.completedTodos,
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
                  color: Colors.white38,
                  borderRadius: BorderRadius.circular(10),
                ),
                child: Slidable(
                  endActionPane: ActionPane(motion: DrawerMotion(), children: [
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
                  ),
                ),
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
}
