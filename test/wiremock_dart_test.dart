import 'dart:io';

import 'package:test/test.dart';

import 'package:wiremock_dart/wiremock_dart.dart';
import 'package:http/http.dart' as http;

void main() {
  WiremockDart cut;

  setUpAll(() {
    cut = WiremockDart(Directory.current.path + '/test/_responses');
  });

  setUp(() async {
    await cut.start();
  });

  tearDownAll(() {
    cut.shutdown();
  });

  group("WiremockDart", () {
    test('Answer with default response (404)', () async {
      var response = await http.get("${cut.url}/whatever");
      expect(response.statusCode, 404);
    });

    test('Answers with a simple request', () async {
      var response = await http.get("${cut.url}another/thing");
      expect(response.statusCode, 200);
      expect(response.body, 'Hello world!');
      expect(response.headers['content-type'], 'text/plain');
    });
  });
}
