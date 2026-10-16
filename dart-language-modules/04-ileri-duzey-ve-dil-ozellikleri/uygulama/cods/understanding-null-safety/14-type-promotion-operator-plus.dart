// Using null safety:
class Point {
  final int x, y;

  Point(this.x, this.y);

  Point operator +(Object other) {
    if (other is int) return Point(x + other, y + other);
    if (other is! Point) wrongType('int | Point', other);

    print('Adding two Point instances together: $this + $other');
    return Point(x + other.x, y + other.y);
  }

  // toString, hashCode, and other implementations...
}
