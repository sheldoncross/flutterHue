import 'package:test/test.dart';
import 'package:http/testing.dart';
import 'package:http/http.dart';
import 'package:flutter_test/flutter_test.dart' as bindings;
import 'package:flutterHue/provider/light_api.dart';

Future<void> main() async {
  bindings.TestWidgetsFlutterBinding.ensureInitialized();

  //Tests do not work plugins, must decouple the API calls from database calls
  test('Test API call to recieve key from bridge', () async {
    Client client = MockClient((request) async {
      switch (request.url.toString()) {
        case 'https://testing.hue.error/api/':
          return Response(
              '[{"error: {"type": 101, "address": "", "description": "link button not pressed"}}]',
              101);
        case 'https://testing.hue/api/':
          return Response(
              '[{"success": { "username": "12345678901234"}}}]', 200);
      }
      return Response(
          '[{"error: {"type": 1, "address": "/", "description": "unauthorized user"}}]',
          1);
    });

    final LightApi hueApi =
        LightApi(address: 'testing.hue.error', client: client);

    final testCase = await hueApi.fetchKey(printMessages: true);

    expect(hueApi.profileKey, '12345678901234');
  });
}
