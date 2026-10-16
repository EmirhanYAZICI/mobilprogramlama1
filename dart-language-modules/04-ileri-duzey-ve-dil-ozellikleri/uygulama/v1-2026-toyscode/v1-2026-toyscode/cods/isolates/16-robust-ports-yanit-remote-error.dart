void _handleResponsesFromIsolate(dynamic message) {
  if (message is RemoteError) {
    throw message;
  } else {
    print(message);
  }
}
