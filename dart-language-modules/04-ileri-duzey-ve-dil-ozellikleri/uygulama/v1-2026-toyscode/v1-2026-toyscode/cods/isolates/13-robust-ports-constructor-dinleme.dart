class Worker {
  final SendPort _commands;
  final ReceivePort _responses;

  Worker._(this._responses, this._commands) {
    _responses.listen(_handleResponsesFromIsolate);
  }
}
