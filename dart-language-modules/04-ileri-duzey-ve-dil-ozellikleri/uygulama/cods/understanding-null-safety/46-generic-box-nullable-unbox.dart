// Using null safety:
void main() {
  var box = Box<int?>.full(null);
  print(box.unbox());
}
