class EmailValidator {
  static bool validate(String email) {
    bool isNotEmpty = email.isNotEmpty;
    bool containesNoSpaces = !email.trim().contains(" ");
    bool containsSymbols = email.contains("@") && email.contains(".");
    bool hasCorrectBeginning = !email.startsWith("@") && !email.startsWith(".");
    bool hasCorrectEnding = !email.endsWith("@") && !email.endsWith(".");
    return isNotEmpty && containesNoSpaces && containsSymbols && hasCorrectBeginning && hasCorrectEnding;
  }
}
