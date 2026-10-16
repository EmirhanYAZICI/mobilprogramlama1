void main() async {
  // ...
  await for (final request in requestServer) {
    handleRequest(request);
  }
  // ...
}
