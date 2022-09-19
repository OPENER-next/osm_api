import '/src/osm_user/osm_user.dart';

/**
 * An immutable container class for an OSM comment.
 */
class OSMComment {

  /**
   * The user who posted the comment.
   */
  final OSMUser user;

  /**
   * The date and time the comment was published.
   */
  final DateTime date;

  /**
   * The text content of the comment.
   */
  final String text;


  OSMComment({
    required this.user,
    required this.date,
    required this.text,
  });


  @override
  String toString() => '$runtimeType - date: $date; user: $user; text: $text';


  @override
  int get hashCode =>
    date.hashCode ^
    user.hashCode ^
    text.hashCode;


  @override
  bool operator == (o) =>
    identical(this, o) ||
    o is OSMComment &&
    runtimeType == o.runtimeType &&
    date == o.date &&
    user == o.user &&
    text == o.text;
}