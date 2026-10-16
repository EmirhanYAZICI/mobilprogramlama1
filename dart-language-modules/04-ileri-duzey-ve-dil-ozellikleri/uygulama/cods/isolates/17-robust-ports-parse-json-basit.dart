Future<Object?> parseJson(String message) async {
  _commands.send(message);
}
