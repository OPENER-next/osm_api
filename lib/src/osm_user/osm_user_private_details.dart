import '/src/osm_user/osm_user_details.dart';

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
	final int receivedMessageCount;

  /**
   * The number of unread messages.
   */
	final int unreadMessagesCount;

  /**
   * The number of sent messages by the user.
   */
	final int sentMessagesCount;


  OSMUserPrivateDetails({
    required super.id,
    required super.name,
    required super.createdAt,
    required super.profileDescription,
    String? super.profileImageUrl,
    required super.hasAgreedToContributorTerms,
    required super.changesetsCount,
    required super.gpsTracesCount,
    required super.roles,
    required super.receivedBlocksCount,
    required super.activeBlocksCount,
    required this.contributionsArePublicDomain,
    this.homeZoom,
    this.homeLat,
    this.homeLon,
    required this.preferredLanguages,
    required this.receivedMessageCount,
    required this.unreadMessagesCount,
    required this.sentMessagesCount,
  });


  /**
   * A factory method for constructing an [OSMUserPrivateDetails] object from a JSON object.
   */
  factory OSMUserPrivateDetails.fromJSONObject(Map<String, dynamic> obj) => OSMUserPrivateDetails(
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
    contributionsArePublicDomain: obj['contributor_terms']['pd'],
    homeZoom: obj['home']?['zoom'],
    homeLat: obj['home']?['lat'],
    homeLon: obj['home']?['lon'],
    preferredLanguages: obj['languages']?.cast<String>() ?? List.empty(),
    receivedMessageCount: obj['messages']['received']['count'],
    unreadMessagesCount: obj['messages']['received']['unread'],
    sentMessagesCount: obj['messages']['sent']['count'],
  );


  @override
  String toString() => '${super.toString()}; contributionsArePublicDomain: $contributionsArePublicDomain; homeZoom: $homeZoom; homeLat: $homeLat; homeLon: $homeLon; preferredLanguages: $preferredLanguages; reiceivedMessageCount: $receivedMessageCount; unreadMessagesCount: $unreadMessagesCount; sentMessagesCount: $sentMessagesCount';


  @override
  int get hashCode =>
    super.hashCode ^
    contributionsArePublicDomain.hashCode ^
    homeZoom.hashCode ^
    homeLat.hashCode ^
    homeLon.hashCode ^
    // do not use preferredLanguages.hashCode since the hasCodes may differ even if the values are equal.
    // see https://api.flutter.dev/flutter/dart-core/Object/hashCode.html
    // "The default hash code implemented by Object represents only the identity of the object,"
    Object.hashAll(preferredLanguages) ^
    receivedMessageCount.hashCode ^
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
    receivedMessageCount == o.receivedMessageCount &&
    unreadMessagesCount == o.unreadMessagesCount &&
    sentMessagesCount == o.sentMessagesCount;
}