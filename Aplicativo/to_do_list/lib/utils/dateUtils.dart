class UtilsDate {
  static String formatDate(DateTime date) {
    return "${date.day.toString().padLeft(2, '0')}/"
        "${date.month.toString().padLeft(2, '0')}/"
        "${date.year}";
  }

  static DateTime formatString(String date) {
    List<String> parts = date.split('/');
    int day = int.parse(parts[0]) + 1;
    int month = int.parse(parts[1]);
    int year = int.parse(parts[2]);

    return DateTime(year, month, day);
  }

  static bool isLate(String date) {
    DateTime formatedDate = formatString(date);
    return formatedDate.isBefore(DateTime.now());
  }
}
