import 'dart:convert';
import 'package:http/http.dart' as http;

/// Simple ApiClient interface and an HTTP implementation.
abstract class ApiClient {
  Future<Map<String, dynamic>> post(String path, Map<String, dynamic> body);
  Future<Map<String, dynamic>> get(String path);
}

class HttpApiClient implements ApiClient {
  final String baseUrl;
  final http.Client _client;

  HttpApiClient({required this.baseUrl, http.Client? client})
      : _client = client ?? http.Client();

  Uri _uri(String path) => Uri.parse('$baseUrl$path');

  @override
  Future<Map<String, dynamic>> post(String path, Map<String, dynamic> body) async {
    final res = await _client.post(_uri(path), body: jsonEncode(body), headers: {
      'content-type': 'application/json',
    });
    return jsonDecode(res.body) as Map<String, dynamic>;
  }

  @override
  Future<Map<String, dynamic>> get(String path) async {
    final res = await _client.get(_uri(path));
    return jsonDecode(res.body) as Map<String, dynamic>;
  }
}