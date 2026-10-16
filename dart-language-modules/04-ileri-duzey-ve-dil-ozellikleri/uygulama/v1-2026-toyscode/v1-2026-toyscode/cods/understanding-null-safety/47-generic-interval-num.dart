// Using null safety:
class Interval<T extends num> {
  T min, max;

  Interval(this.min, this.max);

  bool get isEmpty => max <= min;
}
