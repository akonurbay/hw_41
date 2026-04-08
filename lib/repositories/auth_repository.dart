import '../api/api_client.dart';
import '../db/local_db.dart';

class AuthRepository {
  final ApiClient apiClient;
  final LocalDb db;

  AuthRepository({required this.apiClient, required this.db});

  Future<String> login(String username, String password) async {
    final res = await apiClient.post('/login', {'username': username, 'password': password});
    final token = res['token'] as String;
    await db.saveToken(token);
    return token;
  }

  Future<void> logout() async {
    await db.clearToken();
  }
}