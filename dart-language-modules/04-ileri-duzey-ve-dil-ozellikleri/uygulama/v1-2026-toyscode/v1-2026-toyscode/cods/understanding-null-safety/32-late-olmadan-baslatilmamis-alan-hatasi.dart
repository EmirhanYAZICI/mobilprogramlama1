// Using null safety, incorrectly:
class Coffee {
  String _temperature;

  void heat() { _temperature = 'hot'; }
  void chill() { _temperature = 'iced'; }

  String serve() => _temperature + ' coffee';
}

void main() {
  var coffee = Coffee();
  coffee.heat();
  coffee.serve();
}
