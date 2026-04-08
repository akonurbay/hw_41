import 'package:hw_41/test/fake_server/fake_server.dart';

Future<void> main() async {
  final server = FakeServer();
  final port = await server.start();
  print('Fake server running on http://localhost:$port');
}