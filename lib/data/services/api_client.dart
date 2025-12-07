import 'dart:convert';

import 'package:http/http.dart' as http;

class ApiClient {
  final http.Client _client;

  ApiClient({http.Client? client}) : _client = client ?? http.Client();

  Future<List<dynamic>> getList(String url) async {
    final uri = Uri.parse(url);
    final response = await _client.get(uri);

    if (response.statusCode >= 200 && response.statusCode < 300) {
      final body = json.decode(response.body);
      if (body is List) {
        return body;
      }
      throw const FormatException('Expected a JSON list from API.');
    }

    throw http.ClientException(
      'GET $url failed with status ${response.statusCode}',
      uri,
    );
  }

  Future<void> patch(String url, Map<String, dynamic> body) async {
    final uri = Uri.parse(url);
    final response = await _client.patch(
      uri,
      headers: <String, String>{
        'Content-Type': 'application/json; charset=utf-8',
      },
      body: json.encode(body),
    );

    if (response.statusCode < 200 || response.statusCode >= 300) {
      throw http.ClientException(
        'PATCH $url failed with status ${response.statusCode}',
        uri,
      );
    }
  }
}

