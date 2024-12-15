import 'package:cloud_firestore/cloud_firestore.dart';

class ToDo {
  final String id;
  final String title;
  final String description;
  final String finish;
  final bool completed;
  final Timestamp timestamp;

  ToDo(
      {required this.id,
      required this.title,
      required this.description,
      required this.finish,
      required this.completed,
      required this.timestamp});
}
