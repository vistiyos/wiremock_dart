library wiremock_dart;

import 'dart:convert';
import 'dart:io';

import 'package:mock_web_server/mock_web_server.dart';
import 'package:wiremock_dart/response_mapping.dart';

/// Wiremock for Dart
class WiremockDart {
  MockWebServer _mockWebServer = MockWebServer();
  final String _responsesPath;
  final Map<String, List<ResponseMapping>> _responses = {};

  WiremockDart(this._responsesPath);

  _getAllResponseFiles() => Directory(_responsesPath)
      .listSync(recursive: true)
      .where((element) => element is File)
      .forEach(_parseResponseFile);

  _parseResponseFile(FileSystemEntity responseFile) {
    var responseMapping = ResponseMapping.fromJson(jsonDecode(File(responseFile.absolute.path).readAsStringSync()));
    if (!_responses.containsKey(responseMapping.uri)) _responses[responseMapping.uri] = [];
    _responses[responseMapping.uri].add(responseMapping);
  }

  start() async {
    _getAllResponseFiles();
    await _mockWebServer.start();
    _mockWebServer.dispatcher = _dispatcher;
  }

  shutdown() => _mockWebServer.shutdown();

  Future<MockResponse> _dispatcher(HttpRequest request) async {
    if (_responses.containsKey(request.uri.path)) {
      var mapping = _responses[request.uri.path].firstWhere((requestMapping) => requestMapping.match(request));
      return MockResponse()
        ..httpCode = mapping.statusCode
        ..headers = mapping.headers
        ..body = mapping.body;
    }
    return _defaultAnswer;
  }

  get _defaultAnswer => MockResponse()..httpCode = 404;

  get url => _mockWebServer.url;
}
