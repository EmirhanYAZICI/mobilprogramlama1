// Without null safety:
void requireStringNotObject(String definitelyString) {
  print(definitelyString.length);
}

void main() {
  Object maybeString = 'it is';
  requireStringNotObject(maybeString);
}
