import '/src/osm_user/osm_user.dart';

/**
 * An immutable container class for OSM user details.
 */
class OSMUserDetails extends OSMUser {

  /**
   * The date and time the user account was created.
   */
  final DateTime createdAt;

  /**
   * An optional profile description given by the user.
   */
  final String profileDescription;

  /**
   * Whether the user has agreed to the contributor terms or not.
   */
  final bool hasAgreedToContributorTerms;

  /**
   * The number of changesets submitted by the user.
   */
  final int changesetsCount;

  /**
   * The number of gps traces uploaded by the user.
   */
	final int gpsTracesCount;

  /**
   * The url to the profile image of the user.
   *
   * This is null if the user doesn't have a profile image.
   */
  final String? profileImageUrl;

  /**
   * A list of roles as [String]s indicating if the user has any special user roles.
   */
  final List<String> roles;

  /**
   * The total amount of blocks the user received in the past.
   */
  final int receivedBlocksCount;

  /**
   * The number of currently active blocks.
   * A blocked user is not allowed to make edits.
   */
  final int activeBlocksCount;


  const OSMUserDetails({
    required super.id,
    required super.name,
    required this.createdAt,
    required this.profileDescription,
    this.profileImageUrl,
    required this.hasAgreedToContributorTerms,
    required this.changesetsCount,
    required this.gpsTracesCount,
    required this.roles,
    required this.receivedBlocksCount,
    required this.activeBlocksCount,
  });


  /**
   * A factory method for constructing an [OSMUserDetails] object from a JSON object.
   */
  factory OSMUserDetails.fromJSONObject(Map<String, dynamic> obj) => OSMUserDetails(
    id: obj['id'],
    name: obj['display_name'],
    createdAt: DateTime.parse(obj['account_created']),
    profileImageUrl: obj['img']?['href'],
    profileDescription: obj['description'],
    hasAgreedToContributorTerms: obj['contributor_terms']['agreed'],
    changesetsCount: obj['changesets']['count'],
    gpsTracesCount: obj['traces']['count'],
    roles: obj['roles'].cast<String>(),
    receivedBlocksCount: obj['blocks']['received']['count'],
    activeBlocksCount: obj['blocks']['received']['active'],
  );


  @override
  String toString() => '${super.toString()}; createdAt: $createdAt; profileImageUrl: $profileImageUrl; profileDescription: $profileDescription; hasAgreedToContributorTerms: $hasAgreedToContributorTerms; changesetsCount: $changesetsCount; gpsTracesCount: $gpsTracesCount; gpsTracesCount: $gpsTracesCount; roles: $roles; receivedBlocksCount: $receivedBlocksCount; activeBlocksCount: $activeBlocksCount';


  @override
  int get hashCode =>
    super.hashCode ^
    profileDescription.hashCode ^
    profileImageUrl.hashCode ^
    hasAgreedToContributorTerms.hashCode ^
    changesetsCount.hashCode ^
    gpsTracesCount.hashCode ^
    // do not use roles.hashCode since the hasCodes may differ even if the values are equal.
    // see https://api.flutter.dev/flutter/dart-core/Object/hashCode.html
    // "The default hash code implemented by Object represents only the identity of the object,"
    Object.hashAll(roles) ^
    receivedBlocksCount.hashCode ^
    activeBlocksCount;


  @override
  bool operator == (o) =>
    identical(this, o) ||
    o is OSMUserDetails &&
    runtimeType == o.runtimeType &&
    super == o &&
    profileDescription == o.profileDescription &&
    profileImageUrl == o.profileImageUrl &&
    hasAgreedToContributorTerms == o.hasAgreedToContributorTerms &&
    changesetsCount == o.changesetsCount &&
    gpsTracesCount == o.gpsTracesCount &&
    roles == o.roles &&
    receivedBlocksCount == o.receivedBlocksCount &&
    activeBlocksCount == o.activeBlocksCount;
}