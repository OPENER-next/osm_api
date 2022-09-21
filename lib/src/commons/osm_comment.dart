/**
 * An immutable base class for an OSM comment.
 */
abstract class OSMComment {

  /**
   * The date and time the comment was published.
   */
  final DateTime date;

  /**
   * The text content of the comment.
   */
  final String text;


  const OSMComment({
    required this.date,
    required this.text,
  });


  @override
  String toString() => '$runtimeType - date: $date; user: text: $text';


  @override
  int get hashCode =>
    date.hashCode ^
    text.hashCode;


  @override
  bool operator == (o) =>
    identical(this, o) ||
    o is OSMComment &&
    runtimeType == o.runtimeType &&
    date == o.date &&
    text == o.text;
}
