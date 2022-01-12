import '/src/authentication/auth.dart';
import '/src/osm_apis/osm_user_api_calls.dart';
import '/src/osm_apis/osm_changeset_api_calls.dart';
import '/src/osm_apis/osm_element_api_calls.dart';
import '/src/osm_apis/osm_api_base.dart';

export '/src/authentication/auth.dart';
export '/src/authentication/basic_auth.dart';
export '/src/authentication/oauth_auth.dart';
export '/src/authentication/oauth2_auth.dart';

export '/src/commons/bounding_box.dart';
export '/src/commons/osm_exceptions.dart';

export '/src/osm_elements/osm_elements.dart';

export '/src/osm_user/osm_user.dart';
export '/src/osm_user/osm_user_details.dart';
export '/src/osm_user/osm_user_private_details.dart';
export '/src/osm_user/osm_permissions.dart';

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
