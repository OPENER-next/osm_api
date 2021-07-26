import '/src/authentication/auth.dart';
import '/src/osm-apis/osm-user-api-calls.dart';
import '/src/osm-apis/osm-changeset-api-calls.dart';
import '/src/osm-apis/osm-element-api-calls.dart';
import '/src/osm-apis/osm-api-base.dart';

export '/src/authentication/basic-auth.dart';
export '/src/authentication/oauth-auth.dart';
export '/src/commons/bounding-box.dart';
export '/src/commons/osm-exceptions.dart';
export '/src/osm-user/osm-permissions.dart';
export '/src/osm-elements/osm-elements.dart';

/**
 * A super class that contains all API calls for sending requests to an OSM API server.
 */
class OSMAPI extends OSMAPIBase with OSMUserAPICalls, OSMElementAPICalls, OSMChangesetAPICalls {
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
