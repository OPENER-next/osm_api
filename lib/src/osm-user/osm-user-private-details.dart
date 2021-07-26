import '/src/osm-user/osm-user-details.dart';

/**
 * An immutable container class for OSM user details including private information like location.
 */
class OSMUserPrivateDetails extends OSMUserDetails {

  /**
   * Whether the user considers his/her contributions as public domain or not.
   */
  final bool contributionsArePublicDomain;

  /**
   * The zoom level of the user's home location.
   *
   * This is null if the user didn't set a zoom level.
   */
	final int? homeZoom;

  /**
   * The coordinates given in latitude and longitude of the user's home location.
   *
   * This is null if the user didn't set a home location.
   */
	final double? homeLat, homeLon;

  /**
   * A list of user preferred languages represented by language codes like "en-US".
   */
	final List<String> preferredLanguages;

  /**
   * The total number of received messages.
   */
	final int reiceivedMessageCount;

  /**
   * The number of unread messages.
   */
	final int unreadMessagesCount;

  /**
   * The number of sent messages by the user.
   */
	final int sentMessagesCount;


  OSMUserPrivateDetails({
    required int uid,
    required String userName,
    required DateTime createdAt,
    required String profileDescription,
    String? profileImageUrl,
    required bool hasAgreedToContributorTerms,
    required int changesetsCount,
    required int gpsTracesCount,
    required List<String> roles,
    required int receivedBlocksCount,
    required int activeBlocksCount,
    required this.contributionsArePublicDomain,
    this.homeZoom,
    this.homeLat,
    this.homeLon,
    required this.preferredLanguages,
    required this.reiceivedMessageCount,
    required this.unreadMessagesCount,
    required this.sentMessagesCount
  }) : super(
    uid: uid,
    userName: userName,
    createdAt: createdAt,
    profileDescription: profileDescription,
    profileImageUrl: profileImageUrl,
    hasAgreedToContributorTerms: hasAgreedToContributorTerms,
    changesetsCount: changesetsCount,
    gpsTracesCount: gpsTracesCount,
    roles: roles,
    receivedBlocksCount: receivedBlocksCount,
    activeBlocksCount: activeBlocksCount
  );


  /**
   * A factory method for constructing an [OSMUserPrivateDetails] object from a JSON object.
   */
  static OSMUserPrivateDetails fromJSONObject(Map<String, dynamic> obj) => OSMUserPrivateDetails(
    uid: obj['id'],
    userName: obj['display_name'],
    createdAt: DateTime.parse(obj['account_created']),
    profileImageUrl: obj['img']?['href'],
    profileDescription: obj['description'],
    hasAgreedToContributorTerms: obj['contributor_terms']['agreed'],
    changesetsCount: obj['changesets']['count'],
    gpsTracesCount: obj['traces']['count'],
    roles: obj['roles'].cast<String>(),
    receivedBlocksCount: obj['blocks']['received']['count'],
    activeBlocksCount: obj['blocks']['received']['active'],
    contributionsArePublicDomain: obj['contributor_terms']['pd'],
    homeZoom: obj['home']?['zoom'],
    homeLat: obj['home']?['lat'],
    homeLon: obj['home']?['lon'],
    preferredLanguages: obj['languages']?.cast<String>() ?? List.empty(),
    reiceivedMessageCount: obj['messages']['received']['count'],
    unreadMessagesCount: obj['messages']['received']['unread'],
    sentMessagesCount: obj['messages']['sent']['count']
  );


  @override
  String toString() => '${super.toString()}; contributionsArePublicDomain: $contributionsArePublicDomain; homeZoom: $homeZoom; homeLat: $homeLat; homeLon: $homeLon; preferredLanguages: $preferredLanguages; reiceivedMessageCount: $reiceivedMessageCount; unreadMessagesCount: $unreadMessagesCount; sentMessagesCount: $sentMessagesCount';


  @override
  int get hashCode =>
    super.hashCode ^
    contributionsArePublicDomain.hashCode ^
    homeZoom.hashCode ^
    homeLat.hashCode ^
    homeLon.hashCode ^
    preferredLanguages.hashCode ^
    reiceivedMessageCount.hashCode ^
    unreadMessagesCount.hashCode ^
    sentMessagesCount.hashCode;


  @override
  bool operator == (o) =>
    identical(this, o) ||
    o is OSMUserPrivateDetails &&
    runtimeType == o.runtimeType &&
    super == o &&
    contributionsArePublicDomain == o.contributionsArePublicDomain &&
    homeZoom == o.homeZoom &&
    homeLat == o.homeLat &&
    homeLon == o.homeLon &&
    preferredLanguages == o.preferredLanguages &&
    reiceivedMessageCount == o.reiceivedMessageCount &&
    unreadMessagesCount == o.unreadMessagesCount &&
    sentMessagesCount == o.sentMessagesCount;
}