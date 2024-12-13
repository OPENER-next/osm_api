import 'package:osm_api/osm_api.dart';
import 'package:test/test.dart';

void main() async {
  late final OSMAPI osmapiWithAuth;
  late final OSMAPI osmapiNoAuth;
  late final OSMAPI osmapi;

  setUpAll(() async {
    osmapi = osmapiWithAuth = OSMAPI(
      baseUrl: 'http://127.0.0.1:3000/api/0.6',
      authentication: OAuth2(
        accessToken: 'DummyTestToken',
      ),
    );

    osmapiNoAuth = OSMAPI(
      baseUrl: 'http://127.0.0.1:3000/api/0.6',
    );
  });

  // permissions tests

  test('check for correct permissions for authenticated user', () async {
    final permWithAuth = await osmapiWithAuth.getPermissions();

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
    final permNoAuth = await osmapiNoAuth.getPermissions();

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

  // user details tests

  test('check for correct user details (private) of current user', () async {
    final userDetails = await osmapi.getCurrentUserDetails();

    expect(userDetails.homeLat, isNull);
    expect(userDetails.homeLon, isNull);
    expect(userDetails.homeZoom, isNull);
    expect(userDetails.contributionsArePublicDomain, isFalse);
    expect(userDetails.preferredLanguages, contains('en-US'));
    expect(userDetails.receivedMessageCount, isZero);
    expect(userDetails.sentMessagesCount, isZero);
    expect(userDetails.unreadMessagesCount, isZero);
    expect(userDetails.changesetsCount, greaterThanOrEqualTo(0));
    expect(userDetails.gpsTracesCount, greaterThanOrEqualTo(0));
    expect(userDetails.profileDescription, isEmpty);
    expect(userDetails.hasAgreedToContributorTerms, isTrue);
    expect(userDetails.profileImageUrl, isNull);
    expect(userDetails.name, 'testuser');
    expect(userDetails.activeBlocksCount, isZero);
    expect(userDetails.receivedBlocksCount, isZero);
    expect(userDetails.roles, isEmpty);
    expect(userDetails.id, isPositive);
    expect(userDetails.createdAt.isBefore(DateTime.now()), isTrue);
  });

  test('check for correct user details of specific user', () async {
    final currentUserDetails = await osmapi.getCurrentUserDetails();

    final userDetails = await osmapi.getUserDetails(currentUserDetails.id);

    expect(userDetails.changesetsCount, greaterThanOrEqualTo(0));
    expect(userDetails.gpsTracesCount, greaterThanOrEqualTo(0));
    expect(userDetails.profileDescription, isEmpty);
    expect(userDetails.hasAgreedToContributorTerms, isTrue);
    expect(userDetails.profileImageUrl, isNull);
    expect(userDetails.name, 'testuser');
    expect(userDetails.activeBlocksCount, isZero);
    expect(userDetails.receivedBlocksCount, isZero);
    expect(userDetails.roles, isEmpty);
    expect(userDetails.id, isPositive);
    expect(userDetails.createdAt.isBefore(DateTime.now()), isTrue);
  });

  test('check for correct user details of multiple specific users', () async {
    final currentUserDetails = await osmapi.getCurrentUserDetails();

    final usersDetails = await osmapi.getMultipleUsersDetails([currentUserDetails.id]);
    expect(usersDetails.length, equals(1));

    final userDetails = usersDetails.first;
    expect(userDetails.changesetsCount, greaterThanOrEqualTo(0));
    expect(userDetails.gpsTracesCount, greaterThanOrEqualTo(0));
    expect(userDetails.profileDescription, isEmpty);
    expect(userDetails.hasAgreedToContributorTerms, isTrue);
    expect(userDetails.profileImageUrl, isNull);
    expect(userDetails.name, 'testuser');
    expect(userDetails.activeBlocksCount, isZero);
    expect(userDetails.receivedBlocksCount, isZero);
    expect(userDetails.roles, isEmpty);
    expect(userDetails.id, isPositive);
    expect(userDetails.createdAt.isBefore(DateTime.now()), isTrue);
  });



  test('check for correct return of user preference methods', () async {
    // clear existing preferences
    await osmapi.setAllPreferences({});

    var allPreferences = await osmapi.getAllPreferences();
    expect(allPreferences, isEmpty);

    final preferences = {
      'CustomPref1': 2332,
      '?§%&7>89<!2=': true
    };
    await osmapi.setAllPreferences(preferences);

    allPreferences = await osmapi.getAllPreferences();
    // preference values re returned as strings thus convert the current preference map to string
    final preferencesAsStrings = preferences.map((key, value) => MapEntry(key, value.toString()));
    expect(allPreferences, equals(preferencesAsStrings));

    await osmapi.setPreference('CustomPref1', 'test');
    var preference01Value = await osmapi.getPreference('CustomPref1');
    expect(preference01Value, equals('test'));

    await osmapi.deletePreference('CustomPref1');
    preference01Value = await osmapi.getPreference('CustomPref1');
    expect(preference01Value, isNull);

    // check if deleting a non existent pref does not throw an error
    await osmapi.deletePreference('non-existent-pref');
  });
}
