import 'package:test/test.dart';
import 'package:mocktail/mocktail.dart';
import 'package:hw_41/lib/repositories/items_repository.dart';
import '../mocks/mock_api_client.dart';
import '../mocks/mock_db.dart';

void main() {
  late MockApiClient api;
  late MockLocalDb db;
  late ItemsRepository repo;

  setUp(() {
    api = MockApiClient();
    db = MockLocalDb();
    repo = ItemsRepository(apiClient: api, db: db);
  });

  test('listItems returns items', () async {
    when(() => db.getToken()).thenAnswer((_) async => 'token123');
    when(() => api.get('/items')).thenAnswer((_) async => {
          'items': [
            {'id': 1, 'name': 'Item 1'}
          ]
        });
    when(() => db.saveItems(any())).thenAnswer((_) async {});
    final items = await repo.listItems();
    expect(items.length, 1);
    expect(items.first['name'], 'Item 1');
  });

  test('addItem posts and updates cache', () async {
    when(() => db.getToken()).thenAnswer((_) async => 'token123');
    when(() => api.post('/items', any())).thenAnswer((_) async => {'id': 2, 'name': 'New'});
    when(() => db.getItems()).thenAnswer((_) async => [
          {'id': 1, 'name': 'Item 1'}
        ]);
    when(() => db.saveItems(any())).thenAnswer((_) async {});
    final added = await repo.addItem({'name': 'New'});
    expect(added['id'], 2);
    verify(() => db.saveItems(any())).called(1);
  });
}