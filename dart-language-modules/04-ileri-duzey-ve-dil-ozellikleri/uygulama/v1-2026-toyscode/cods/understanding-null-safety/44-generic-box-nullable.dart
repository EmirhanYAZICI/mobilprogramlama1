// Using null safety:
class Box<T> {
  T? object;
  Box.empty();
  Box.full(this.object);
}
