// Using null safety, incorrectly:
class HttpResponse {
  final int code;
  final String? error;

  HttpResponse.ok()
      : code = 200,
        error = null;
  HttpResponse.notFound()
      : code = 404,
        error = 'Not found';

  @override
  String toString() {
    if (code == 200) return 'OK';
    return 'ERROR $code ${error.toUpperCase()}';
  }
}
