import 'dart:convert';
import '/src/osm_user/osm_user_private_details.dart';
import '/src/osm_user/osm_user_details.dart';
import '/src/osm_user/osm_permissions.dart';
import '/src/osm_apis/osm_api_base.dart';

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


  /**
   * A function for getting details of the active user from the server.
   *
   * This returns an [OSMUserPrivateDetails] object wrapped in a [Future] which resolves when the operation has been completed.
   */
  Future<OSMUserPrivateDetails> getCurrentUserDetails() async {
    final response = await sendRequest('/user/details', headers: const { 'Accept': 'application/json' });
    // parse json
    final jsonData = json.decode(response.data);
    // get single user object
    final jsonObject = jsonData['user'].cast<String, dynamic>();

    return OSMUserPrivateDetails.fromJSONObject(jsonObject);
  }


  /**
   * A function for getting details of a single user from the server by [id].
   *
   * This returns an [OSMUserDetails] object wrapped in a [Future] which resolves when the operation has been completed.
   */
  Future<OSMUserDetails> getUserDetails(int id) async {
    final response = await sendRequest('/user/$id', headers: const { 'Accept': 'application/json' });
    // parse json
    final jsonData = json.decode(response.data);
    // get single user object
    final jsonObject = jsonData['user'].cast<String, dynamic>();

    return OSMUserDetails.fromJSONObject(jsonObject);
  }


  /**
   * A function for getting details of multiple users from the server by their [ids].
   *
   * This returns a lazy [Iterable] of [OSMUserDetails] wrapped in a [Future] which resolves when the operation has been completed.
   */
  Future<Iterable<OSMUserDetails>> getMultipleUsersDetails(Iterable<int> ids) async {
    final response = await sendRequest(
      '/users?users=${ids.join(',')}',
      headers: const { 'Accept': 'application/json' }
    );
    // parse json
    final jsonData = json.decode(response.data);
    // get users array
    final jsonObject = jsonData['users'].cast<Map<String, dynamic>>();

    return _lazyJSONtoOSMUserDetails(jsonObject);
  }


  /**
   * A generator/lazy iterable for converting JSON Objects to multiple [OSMUserDetails].
   */
  Iterable<OSMUserDetails> _lazyJSONtoOSMUserDetails(Iterable<Map<String, dynamic>> objects) sync* {
    for (final jsonObj in objects) {
      // get single user object
      final userObj = jsonObj['user'].cast<String, dynamic>();
      yield OSMUserDetails.fromJSONObject(userObj);
    }
  }


  /**
   * A function for getting all existing preferences from the server.
   *
   * Note that all preference values are returned as a [String].
   * This returns a [Map] with all preferences and values as [String]s wrapped in a [Future] which resolves when the operation has been completed.
   */
  Future<Map<String, String>> getAllPreferences() async {
    final response = await sendRequest('/user/preferences', headers: const { 'Accept': 'application/json' });
    // parse json
    final jsonData = json.decode(response.data);

    // get all preferences
    return jsonData['preferences'].cast<String, String>();
  }


  /**
   * A function for setting multiple preferences on the server.
   *
   * Values will be converted to their [String] representation.
   * All existing preferences on the server will be removed or replaced.
   * This returns an empty [Future] which resolves when the operation has been completed.
   */
  Future<void> setAllPreferences(Map<String, dynamic> preferences) async {
    final sanitizer = const HtmlEscape(HtmlEscapeMode.attribute);
    var xmlPreferencesString = '';
    preferences.forEach((key, value) {
      key = sanitizer.convert(key);
      value = sanitizer.convert(value.toString());
      xmlPreferencesString += '<preference k="$key" v="$value" />';
    });

    await sendRequest(
      '/user/preferences',
      type: 'PUT',
      body:
        '<osm>'
          '<preferences>'
            '$xmlPreferencesString'
          '</preferences>'
        '</osm>'
    );
  }


  /**
   * A function for getting a specific preference from the server.
   *
   * If the preference does not exist the return value is [null].
   * This returns a [String] wrapped in a [Future] which resolves when the operation has been completed.
   */
  Future<String?> getPreference(String preference) async {
    final response = await sendRequest(
      '/user/preferences/${Uri.encodeComponent(preference)}',
      // ignore Not Found error which is thrown if the preference does not exist
      ignoreStatusCodes: [404]
    );
    return response.statusCode == 404 ? null : response.data;
  }


  /**
   * A function for setting a specific preference on the server.
   *
   * Values will be converted to their [String] representation.
   * This returns an empty [Future] which resolves when the operation has been completed.
   */
  Future<void> setPreference(String preference, dynamic value) async {
    await sendRequest(
      '/user/preferences/${Uri.encodeComponent(preference)}',
      type: 'PUT',
      body: value.toString()
    );
  }


  /**
   * A function for deleting a specific preference on the server.
   *
   * This returns an empty [Future] which resolves when the operation has been completed.
   */
  Future<void> deletePreference(String preference) async {
    await sendRequest(
      '/user/preferences/${Uri.encodeComponent(preference)}',
      type: 'DELETE',
      // ignore Not Found error which is thrown if the preference does not exist
      ignoreStatusCodes: [404]
    );
  }
}