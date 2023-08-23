import 'dart:math';

class StringParser {
  static String truncate(String string, int maxLength) {
    String result;
    if (string.length < maxLength) return string;
    result = string.substring(0, min(maxLength, string.length));
    result += "...";
    return result;
  }
}
