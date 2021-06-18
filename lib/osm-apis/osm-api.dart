import 'dart:convert';
import 'package:dio/dio.dart';

/**
 * A base class to setup a connection and send request to an OSM API server.
 */
class OSMAPI {

  String username = 'hrc40979';
  String password = 'hrc40979@cuoly.com';

  final _dio = Dio();

  OSMAPI({
    String? baseUrl,
    int? connectTimeout,
    int? receiveTimeout,
  }) {
    this.baseUrl = baseUrl ?? 'http://127.0.0.1:3000/api/0.6';
    this.connectTimeout = connectTimeout ?? 5000;
    this.receiveTimeout = receiveTimeout ?? 3000;

    _dio.options.responseType = ResponseType.plain;
    _dio.options.headers = {
      'content-Type': 'text/xml',
      'authorization': 'Basic ' + base64Encode(utf8.encode('$username:$password'))
    };
  }


  /**
   * The base url that API requests will be send to.
   *
   * Defaults to `http://127.0.0.1:3000/api/0.6` which points to the localhost.
   *
   * Use `10.0.2.2` as the domain if you want to connect from an Android emulator to your localhost outside the emulator.
   * For testing purposes without a local server use `master.apis.dev.openstreetmap.org/api/0.6`
   */
  String get baseUrl {
    return _dio.options.baseUrl;
  }
  set baseUrl (String value) {
    _dio.options.baseUrl = value;
  }


  /**
   * Connection timeout in milliseconds.
   *
   * Defaults to 5000
   */
  int get connectTimeout {
    return _dio.options.connectTimeout;
  }
  set connectTimeout (int value) {
    _dio.options.connectTimeout = value;
  }


  /**
   * Receiving timeout in milliseconds.
   *
   * Defaults to 3000
   */
  int get receiveTimeout {
    return _dio.options.receiveTimeout;
  }
  set receiveTimeout (int value) {
    _dio.options.receiveTimeout = value;
  }


  /**
   * Sends a request to the given path and returns a [Response]
   *
   * The response type will always be `plain`.
   *
   * A HTTP request method can be specified via [type] which defaults to `GET`.
   * An optional message body can be specified via [body]. The content type of the body needs to be `text/xml`.
   */
  Future<Response> sendRequest (String path, { String type = 'GET', String? body }) {
    return _dio.request(
      path,
      data: body,
      options: Options(
        method: type
      ),
    );
  }
}