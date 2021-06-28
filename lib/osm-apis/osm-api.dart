import 'package:osmapi/authentication/auth.dart';
import 'osm-permission-api-calls.dart';
import 'osm-changeset-api-calls.dart';
import 'osm-element-api-calls.dart';
import 'osm-api-base.dart';
export 'package:osmapi/elements.dart';

/**
 * A super class that contains all API calls for sending requests to an OSM API server.
 */
class OSMAPI extends OSMAPIBase with OSMPermissionAPICalls, OSMElementAPICalls, OSMChangesetAPICalls {
  OSMAPI({
    String? baseUrl,
    int? connectTimeout,
    int? receiveTimeout,
    Auth? authentication,
  }) : super(
    baseUrl: baseUrl,
    connectTimeout: connectTimeout,
    receiveTimeout: receiveTimeout,
    authentication: authentication
  );
}
