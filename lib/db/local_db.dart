/// Simple DB abstraction for storing token and items.
abstract class LocalDb {
  Future<void> saveToken(String token);
  Future<String?> getToken();
  Future<void> clearToken();

  Future<void> saveItems(List<Map<String, dynamic>> items);
  Future<List<Map<String, dynamic>>> getItems();
}