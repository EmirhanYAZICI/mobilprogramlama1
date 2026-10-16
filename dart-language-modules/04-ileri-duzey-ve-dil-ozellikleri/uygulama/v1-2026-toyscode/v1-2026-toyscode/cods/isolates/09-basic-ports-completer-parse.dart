Future<void> parseJson(String message) async {
  await _isolateReady.future;
  _sendPort.send(message);
}
