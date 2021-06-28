import '/osm-user/osm-permissions.dart';
import 'osm-api-base.dart';

/**
 * A mixin containing methods for handling OSM permissions.
 */
mixin OSMPermissionAPICalls on OSMAPIBase {


  /**
   * A function for getting the currently available permissions from the server.
   *
   * This returns an [OSMPermissions] object.
   */
  Future<OSMPermissions> getPermissions() async {
    var response = await sendRequest('/permissions');
    return OSMPermissions.fromXMLString(response.data);
  }
}