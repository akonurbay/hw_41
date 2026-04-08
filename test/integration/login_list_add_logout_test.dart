import 'dart:io';
import 'dart:convert';
import 'package:test/test.dart';
import 'package:http/http.dart' as http;
import 'package:hw_41/lib/api/api_client.dart';
import 'package:hw_41/lib/db/local_db.dart';
import 'package:hw_41/lib/repositories/auth_repository.dart';
import 'package:hw_41/lib/repositories/items_repository.dart';
import '../fake_server/fake_server.dart';

class InMemoryDb implements LocalDb {
  String? _token;
  List<Map<String, dynamic>> _items = [];

  @override
  Future<void> clearToken() async {
    _token = null;
  }

  @override
  Future<String?> getToken() async => _token;

  @override
  Future<void> saveToken(String token) async {
    _token = token;
  }

  @override
  Future<List<Map<String, dynamic>>> getItems() async => _items;

  @override
  Future<void> saveItems(List<Map<String, dynamic>> items) async {
    _items = items;
  }
}

void main() {
  late FakeServer server;
  late int port;
  late ApiClient client;
  late InMemoryDb db;
  late AuthRepository authRepo;
  late ItemsRepository itemsRepo;

  setUpAll(() async {
    server = FakeServer();
    port = await server.start();
    final baseUrl = 'http://localhost:$port';
    client = HttpApiClient(baseUrl: baseUrl, client: http.Client());
  });

  tearDownAll(() async {
    await server.stop();
  });

  setUp(() {
    db = InMemoryDb();
    authRepo = AuthRepository(apiClient: client, db: db);
    itemsRepo = ItemsRepository(apiClient: client, db: db);
  });

  test('login -> list -> add -> logout', () async {
    // login
    final token = await authRepo.login('u', 'p');
    expect(token, 'token123');
    expect(await db.getToken(), 'token123');

    // list
    final items = await itemsRepo.listItems();
    expect(items.length, 2);
    expect(items[0]['name'], 'Item 1');

    // add
    final added = await itemsRepo.addItem({'name': 'New item'});
    expect(added['id'], isNotNull);
    final cached = await db.getItems();
    expect(cached.any((i) => i['name'] == 'New item'), isTrue);

    // logout
    await authRepo.logout();
    expect(await db.getToken(), isNull);
  });
}