import 'dart:convert';
import 'package:test/test.dart';
import 'package:mocktail/mocktail.dart';
import 'package:hw_41/lib/repositories/auth_repository.dart';
import '../mocks/mock_api_client.dart';
import '../mocks/mock_db.dart';

void main() {
  late MockApiClient api;
  late MockLocalDb db;
  late AuthRepository repo;

  setUp(() {
    api = MockApiClient();
    db = MockLocalDb();
    repo = AuthRepository(apiClient: api, db: db);
  });

  test('login saves token to db', () async {
    when(() => api.post('/login', any())).thenAnswer((_) async => {'token': 'token123'});
    when(() => db.saveToken(any())).thenAnswer((_) async {});
    final token = await repo.login('u', 'p');
    expect(token, 'token123');
    verify(() => db.saveToken('token123')).called(1);
  });

  test('logout clears token', () async {
    when(() => db.clearToken()).thenAnswer((_) async {});
    await repo.logout();
    verify(() => db.clearToken()).called(1);
  });
}