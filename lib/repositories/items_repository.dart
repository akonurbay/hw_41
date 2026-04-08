import '../api/api_client.dart';
import '../db/local_db.dart';

class ItemsRepository {
  final ApiClient apiClient;
  final LocalDb db;

  ItemsRepository({required this.apiClient, required this.db});

  Future<List<Map<String, dynamic>>> listItems() async {
    final token = await db.getToken();
    if (token == null) throw StateError('Not authenticated');
    final res = await apiClient.get('/items');
    final items = (res['items'] as List).cast<Map<String, dynamic>>();
    await db.saveItems(items);
    return items;
  }

  Future<Map<String, dynamic>> addItem(Map<String, dynamic> item) async {
    final token = await db.getToken();
    if (token == null) throw StateError('Not authenticated');
    final res = await apiClient.post('/items', item);
    // refresh local cache
    final items = await db.getItems();
    final updated = List<Map<String, dynamic>>.from(items)..add(res);
    await db.saveItems(updated);
    return res;
  }
}