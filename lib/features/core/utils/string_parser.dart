import 'dart:math';

class StringParser {
  static String truncate(String string, int maxLength) {
    String result;
    if (string.length < maxLength) return string;
    result = string.substring(0, min(maxLength, string.length));
    result += "...";
    return result;
  }

  static String dateToString(DateTime date) {
    return "${date.hour.toString().padLeft(2, "0")}:"
        "${date.minute.toString().padLeft(2, "0")} Uhr, "
        "${date.day.toString().padLeft(2, "0")}."
        "${date.month.toString().padLeft(2, "0")}."
        "${date.year}";
  }
}
