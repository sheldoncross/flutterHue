import 'package:http/http.dart';
import 'package:rxdart/rxdart.dart';
import 'package:flutterHue/model/light.dart';
import 'package:flutterHue/provider/light_api.dart';

class LightBloc {
  LightApi _lightApi = LightApi(address: '192.168.4.48', client: Client());

  final _apiKeyFetcher = PublishSubject<String>();

  final _lightFetcher = PublishSubject<List<Light>>();

  Stream<String> get apiKey => _apiKeyFetcher.stream;

  Stream<List<Light>> get lights => _lightFetcher.stream;

  setKey(String responseKey) {
    String currentKey = _lightApi.setKey(newKey: responseKey);
    _apiKeyFetcher.sink.add(currentKey);
  }

  fetchKey() async {
    String keyResponse = await _lightApi.fetchKey(printMessages: true);
    _apiKeyFetcher.sink.add(keyResponse);
  }

  fetchLightData() async {
    List<Light> lightResponse =
        await _lightApi.fetchAllLights(printMessages: true);
    _lightFetcher.sink.add(lightResponse);
  }

  dispose() {
    _apiKeyFetcher.close();
    _lightFetcher.close();
  }
}

final LightBloc lightBloc = LightBloc();
