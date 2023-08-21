class DateParser {
  static String dateToString(DateTime date) {
    return "${date.hour.toString().padLeft(2, "0")}:"
        "${date.minute.toString().padLeft(2, "0")} Uhr, "
        "${date.day.toString().padLeft(2, "0")}."
        "${date.month.toString().padLeft(2, "0")}."
        "${date.year}";
  }
}
