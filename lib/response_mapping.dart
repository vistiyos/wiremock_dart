import 'dart:io';

class ResponseMapping {
  _Request _request;
  _Response _response;

  get uri => _request._url;

  get statusCode => _response._statusCode;

  get body => _response._body;

  get headers => _response.headers;

  ResponseMapping.fromJson(Map<String, dynamic> json) {
    _request = _Request(json['request']['method'], json['request']['url']);
    _response = _Response(
      json['response']['status'],
      json['response']['body'],
      headers: _sanitizeHeaders(json['response']['headers']),
    );
  }

  bool match(HttpRequest request) {
    return request.method == _request._method;
  }

  Map<String, String> _sanitizeHeaders(Map headers) => headers == null ? {} : headers.cast<String, String>();
}

class _Request {
  final String _method;
  final String _url;

  _Request(this._method, this._url);
}

class _Response {
  int _statusCode;
  String _body;
  Map<String, String> headers;

  _Response(this._statusCode, this._body, {this.headers});
}
