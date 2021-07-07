import '/osm-user/osm-permissions.dart';
import 'osm-api-base.dart';

/**
 * A mixin containing methods for handling OSM user and permissions calls.
 */
mixin OSMUserAPICalls on OSMAPIBase {


  /**
   * A function for getting the currently available permissions from the server.
   *
   * This returns an [OSMPermissions] object wrapped in a [Future] which resolves when the operation has been completed.
   */
  Future<OSMPermissions> getPermissions() async {
    final response = await sendRequest('/permissions');
    return OSMPermissions.fromXMLString(response.data);
  }
}