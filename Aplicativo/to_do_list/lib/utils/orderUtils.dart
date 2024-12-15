import 'package:to_do_list/model/todo_model.dart';
import 'package:to_do_list/utils/dateUtils.dart';

class OrderUtils {
  static void orderTodos(List<ToDo> todos) {
    todos.sort((a, b) {
      DateTime dateA = UtilsDate.formatString(a.finish);
      DateTime dateB = UtilsDate.formatString(b.finish);

      return dateA.compareTo(dateB);
    });
  }
}
