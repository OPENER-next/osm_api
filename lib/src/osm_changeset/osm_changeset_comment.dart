import '/src/commons/osm_comment.dart';
import '/src/osm_user/osm_user.dart';


/**
 * An immutable container class for an OSM comment on a changeset.
 */
class OSMChangesetComment extends OSMComment {

  /**
   * The user who posted the comment.
   */
  final OSMUser user;


  const OSMChangesetComment({
    required this.user,
    required super.date,
    required super.text,
  });


  @override
  String toString() => '$runtimeType - date: $date; user: $user; text: $text';


  @override
  int get hashCode =>
    super.hashCode ^
    user.hashCode;


  @override
  bool operator == (o) =>
    identical(this, o) ||
    o is OSMChangesetComment &&
    runtimeType == o.runtimeType &&
    super == o &&
    user == o.user;
}