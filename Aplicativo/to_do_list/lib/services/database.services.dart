import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:to_do_list/model/todo_model.dart';
import 'package:to_do_list/utils/dateUtils.dart';

class DatabaseService {
  final CollectionReference todoCollection =
      FirebaseFirestore.instance.collection("todo");

  User? user = FirebaseAuth.instance.currentUser;

  Future<DocumentReference> addTodoItem(
      String title, String description, String finishIn) async {
    return await todoCollection.add({
      'uid': user!.uid,
      'title': title,
      'description': description,
      'completed': false,
      'finishIn': finishIn,
      'createdAt': FieldValue.serverTimestamp()
    });
  }

  Future<void> updateTodoItem(
      String id, String title, String description, String finishIn) async {
    final updateTodoCollection =
        FirebaseFirestore.instance.collection("todo").doc(id);
    return await updateTodoCollection.update({
      'title': title,
      'description': description,
      'finishIn': finishIn,
    });
  }

  Future<void> completeTodoItem(String id, bool completed) async {
    return await todoCollection.doc(id).update({'completed': completed});
  }

  Future<void> deleteTodoItem(String id) async {
    return await todoCollection.doc(id).delete();
  }

  Stream<List<ToDo>> get todos {
    return todoCollection
        .where('uid', isEqualTo: user!.uid)
        .where('completed', isEqualTo: false)
        .snapshots()
        .map((snapshot) {
      List<ToDo> todos = _todoListFromSnapshot(snapshot);
      todos
          .sort((a, b) => a.finish.compareTo(b.finish)); // Ordenando localmente
      return todos;
    });
  }

  Stream<List<ToDo>> get completedTodos {
    return todoCollection
        .where('uid', isEqualTo: user!.uid)
        .where('completed', isEqualTo: true)
        .snapshots()
        .map(_todoListFromSnapshot);
  }

  List<ToDo> _todoListFromSnapshot(QuerySnapshot snapshot) {
    return snapshot.docs.map((doc) {
      return ToDo(
          id: doc.id,
          title: doc['title'] ?? '',
          description: doc['description'] ?? '',
          finish: doc['finishIn'] ?? '',
          completed: doc['completed'] ?? false,
          timestamp: doc['createdAt'] ?? '');
    }).toList();
  }
}
