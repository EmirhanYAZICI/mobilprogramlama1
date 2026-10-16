// Hypothetical unsound null safety:
void bad(String? maybeString) {
  print(maybeString.length);
}

void main() {
  bad(null);
}
