// Hypothetical unsound null safety:
void requireStringNotNull(String definitelyString) {
  print(definitelyString.length);
}

void main() {
  String? maybeString = null; // Or not!
  requireStringNotNull(maybeString);
}
