
import 'package:osmapi/authentication/basic-auth.dart';
import 'package:osmapi/osm-apis/osm-api.dart';
import 'package:osmapi/osm-user/osm-permissions.dart';
import 'package:test/test.dart';

void main() async {
  late OSMAPI osmapiWithAuth;
  late OSMAPI osmapiNoAuth;

  setUpAll(() async {
    osmapiWithAuth = OSMAPI(
      baseUrl: 'http://127.0.0.1:3000/api/0.6',
      authentication: BasicAuth(
        username: 'testuser',
        password: 'testpass'
      )
    );

    osmapiNoAuth = OSMAPI(
      baseUrl: 'http://127.0.0.1:3000/api/0.6',
    );
  });

  test('check for correct permissions for authenticated user', () async {
    var permWithAuth = await osmapiWithAuth.getPermissions();

    expect(permWithAuth.hasAll({
      OSMPermissions.READ_GPS_TRACES,
      OSMPermissions.READ_USER_PREFERENCES,
      OSMPermissions.WRITE_DIARY,
      OSMPermissions.WRITE_GPS_TRACES,
      OSMPermissions.WRITE_MAP,
      OSMPermissions.WRITE_NOTES,
      OSMPermissions.WRITE_USER_PREFERENCES
    }), true);

    expect(permWithAuth, equals(OSMPermissions({
      OSMPermissions.READ_GPS_TRACES,
      OSMPermissions.READ_USER_PREFERENCES,
      OSMPermissions.WRITE_DIARY,
      OSMPermissions.WRITE_GPS_TRACES,
      OSMPermissions.WRITE_MAP,
      OSMPermissions.WRITE_NOTES,
      OSMPermissions.WRITE_USER_PREFERENCES
    })));
  });

  test('check for correct permissions for unauthenticated user', () async {
    var permNoAuth = await osmapiNoAuth.getPermissions();

    expect(permNoAuth, equals(OSMPermissions()));

    expect(permNoAuth.has(
      OSMPermissions.READ_GPS_TRACES,
    ), false);

    expect(permNoAuth.has(
      OSMPermissions.READ_USER_PREFERENCES,
    ), false);

    expect(permNoAuth.has(
      OSMPermissions.WRITE_DIARY,
    ), false);

    expect(permNoAuth.has(
      OSMPermissions.WRITE_GPS_TRACES,
    ), false);

    expect(permNoAuth.has(
      OSMPermissions.WRITE_MAP,
    ), false);

    expect(permNoAuth.has(
      OSMPermissions.WRITE_NOTES,
    ), false);

    expect(permNoAuth.has(
      OSMPermissions.WRITE_USER_PREFERENCES
    ), false);
  });
}