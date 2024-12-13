import 'package:dio/dio.dart';
import '/src/authentication/auth.dart';
import '/src/commons/osm_exceptions.dart';

/**
 * A base class to setup a connection and send request to an OSM API server.
 */
abstract class OSMAPIBase {
  final _dio = Dio();

 /**
   * User authentication via [OAuth2]
   *
   * If no authentication is given certain API calls will fail.
   * For example you won't be able to make any changes to data on the server.
   */
  Auth? authentication;


  OSMAPIBase({
    String baseUrl = 'http://127.0.0.1:3000/api/0.6',
    Duration connectTimeout = const Duration(seconds: 5),
    Duration receiveTimeout = const Duration(seconds: 5),
    this.authentication,
    String? userAgent
  }) {
    this.baseUrl = baseUrl;
    this.connectTimeout = connectTimeout;
    this.receiveTimeout = receiveTimeout;

    _dio.options.responseType = ResponseType.plain;
    _dio.options.headers = {
      'Content-Type': 'text/xml'
    };
    // set user agent after initial headers/map is set
    this.userAgent = userAgent;
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
  set baseUrl(String value) {
    _dio.options.baseUrl = value;
  }


  /**
   * Connection timeout in milliseconds.
   *
   * Defaults to 5 seconds
   */
  Duration get connectTimeout {
    return _dio.options.connectTimeout!;
  }
  set connectTimeout(Duration value) {
    _dio.options.connectTimeout = value;
  }


  /**
   * Receiving timeout in milliseconds.
   *
   * Defaults to 5 seconds
   */
  Duration get receiveTimeout {
    return _dio.options.receiveTimeout!;
  }
  set receiveTimeout(Duration value) {
    _dio.options.receiveTimeout = value;
  }


  /**
   * Custom User-Agent header string.
   *
   * Defaults to no User-Agent header field
   */
  String? get userAgent {
    return _dio.options.headers['User-Agent'];
  }
  set userAgent(String? userAgent) {
    if (userAgent != null) {
      _dio.options.headers['User-Agent'] = userAgent;
    }
    else {
      _dio.options.headers.remove('User-Agent');
    }
  }


  /**
   * Sends a request to the given path and returns a [Response]
   *
   * The response type will always be `plain`.
   *
   * A HTTP request method can be specified via [type] which defaults to `GET`.
   * An optional message body can be specified via [body]. The content type of the body needs to be `text/xml`.
   * Additional headers can be applied via the [headers] parameter.
   * A list of status codes that shall not throw an exception can be provided via [ignoreStatusCodes].
   */
  Future<Response> sendRequest(String path, { String type = 'GET', String? body, Map<String, String> headers = const {}, List<int>? ignoreStatusCodes }) {
    final options = Options(
      method: type,
      headers: <String, String>{
        if (authentication != null) 'Authorization': authentication!.getAuthorizationHeader(),
        ...headers,
      }
    );

    if (ignoreStatusCodes != null) {
      options.validateStatus = (int? status) {
        return status != null && ((status >= 200 && status < 300) || ignoreStatusCodes.contains(status));
      };
    }

    return _dio.request(
      path,
      data: body,
      options: options
    ).onError<DioException>(handleDioException);
  }


  /**
   * A method to shutdown the current api client.
   * This closes any open connections.
   */
  void dispose() {
    _dio.close(force: true);
  }
}