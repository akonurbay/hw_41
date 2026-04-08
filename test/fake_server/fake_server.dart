import 'dart:convert';
import 'dart:io';

/// Minimal fake server used by integration test. Returns fixed JSON.
/// Endpoints:
/// POST /login -> { "token": "token123" }
/// GET  /items -> { "items": [ ... ] } requires Authorization: Bearer token123
/// POST /items -> returns created item (id assigned)
class FakeServer {
  HttpServer? _server;
  final List<Map<String, dynamic>> _items = [
    {'id': 1, 'name': 'Item 1'},
    {'id': 2, 'name': 'Item 2'}
  ];
  int _nextId = 3;

  Future<int> start() async {
    _server = await HttpServer.bind(InternetAddress.loopbackIPv4, 0);
    _server!.listen(_handleRequest);
    return _server!.port;
  }

  Future<void> stop() async {
    await _server?.close(force: true);
    _server = null;
  }

  void _handleRequest(HttpRequest request) async {
    final path = request.uri.path;
    final method = request.method;
    request.response.headers.contentType = ContentType.json;

    try {
      if (path == '/login' && method == 'POST') {
        final body = await utf8.decoder.bind(request).join();
        final _ = jsonDecode(body);
        request.response.write(jsonEncode({'token': 'token123'}));
      } else if (path == '/items' && method == 'GET') {
        final auth = request.headers.value(HttpHeaders.authorizationHeader);
        if (auth != 'Bearer token123') {
          request.response.statusCode = HttpStatus.unauthorized;
          request.response.write(jsonEncode({'error': 'unauthorized'}));
        } else {
          request.response.write(jsonEncode({'items': _items}));
        }
      } else if (path == '/items' && method == 'POST') {
        final auth = request.headers.value(HttpHeaders.authorizationHeader);
        if (auth != 'Bearer token123') {
          request.response.statusCode = HttpStatus.unauthorized;
          request.response.write(jsonEncode({'error': 'unauthorized'}));
        } else {
          final body = await utf8.decoder.bind(request).join();
          final Map<String, dynamic> data = jsonDecode(body);
          final created = {'id': _nextId++, 'name': data['name']};
          _items.add(created);
          request.response.write(jsonEncode(created));
        }
      } else {
        request.response.statusCode = HttpStatus.notFound;
        request.response.write(jsonEncode({'error': 'not found'}));
      }
    } catch (e) {
      request.response.statusCode = HttpStatus.internalServerError;
      request.response.write(jsonEncode({'error': e.toString()}));
    } finally {
      await request.response.close();
    }
  }
}