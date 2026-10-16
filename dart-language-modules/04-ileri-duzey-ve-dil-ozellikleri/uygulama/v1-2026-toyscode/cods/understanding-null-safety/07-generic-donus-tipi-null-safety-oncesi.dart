// Without null safety:
List<int> filterEvens(List<int> ints) {
  return ints.where((n) => n.isEven);
}
