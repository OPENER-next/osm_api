/**
 * An immutable container class for an OSM comment.
 */
class OSMComment {

  /**
   * The date and time the comment was published.
   */
  final DateTime date;

  /**
   * The unique identifier of the user who posted this comment.
   */
  final int uid;

  /**
   * The unique user name (also known as display name) of the user who posted this comment.
   */
  final String userName;

  /**
   * The text content of the comment.
   */
  final String text;


  OSMComment(this.date, this.uid, this.userName, this.text);


  @override
  String toString() {
    return '$runtimeType - date: $date; uid: $uid; userName: $userName; text: $text';
  }


  @override
  int get hashCode =>
    date.hashCode ^
    uid.hashCode ^
    userName.hashCode ^
    text.hashCode;


  @override
  bool operator == (o) =>
    identical(this, o) ||
    o is OSMComment &&
    runtimeType == o.runtimeType &&
    date == o.date &&
    uid == o.uid &&
    userName == o.userName &&
    text == o.text;
}