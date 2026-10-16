// Using null safety:
class Box<T> {
  final T object;
  Box(this.object);
}

void main() {
  Box<String>('a string');
  Box<int?>(null);
}
