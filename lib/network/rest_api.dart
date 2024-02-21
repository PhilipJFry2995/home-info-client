import 'dart:convert';
import 'dart:io';

import 'package:http/http.dart' as http;

class RestApi {
  static const Duration TIMEOUT = Duration(seconds: 5);

  static Future<HttpClientResponse> post(String endpoint,
      {Map<String, dynamic> body = const {},
      Map<String, String>? additionalHeaders}) async {
    return rest(endpoint, (client, uri) => client.postUrl(uri),
        additionalHeaders: additionalHeaders, body: json.encode(body));
  }

  static Future<http.Response> postString(
      String endpoint, String body) async {
    var response = await http.post(
      Uri.parse(endpoint),
      headers: {
        "Content-Type": "application/x-www-form-urlencoded",
      },
      body: body,
    );

    return response;
  }

  static Future<HttpClientResponse> put(
      String endpoint, Map<String, dynamic> body,
      {Map<String, String>? additionalHeaders}) async {
    return rest(endpoint, (client, uri) => client.putUrl(uri),
        additionalHeaders: additionalHeaders, body: json.encode(body));
  }

  static Future<HttpClientResponse> get(String endpoint,
      {Map<String, String>? additionalHeaders}) async {
    return rest(endpoint, (client, uri) => client.getUrl(uri),
        additionalHeaders: additionalHeaders);
  }

  static Future<HttpClientResponse> delete(String endpoint,
      {Map<String, String>? additionalHeaders}) async {
    return rest(endpoint, (client, uri) => client.deleteUrl(uri),
        additionalHeaders: additionalHeaders);
  }

  static Future<HttpClientResponse> rest(
      String endpoint, Function(HttpClient, Uri) restMethod,
      {Map<String, String>? additionalHeaders, String? body}) async {
    HttpClient httpClient = HttpClient();
    httpClient.connectionTimeout = TIMEOUT;
    HttpClientRequest request =
        await restMethod(httpClient, Uri.parse(endpoint));

    request.headers.set('content-type', 'application/json');

    additionalHeaders
        ?.forEach((key, value) => {request.headers.set(key, value)});

    if (body != null) {
      request.add(utf8.encode(body));
    }

    HttpClientResponse response = await request.close();
    httpClient.close();
    return response;
  }
}
