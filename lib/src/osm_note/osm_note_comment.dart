import 'package:osm_api/src/commons/osm_comment.dart';

import '/src/commons/date_time_utils.dart';
import '/src/osm_user/osm_user.dart';
import 'osm_note_action.dart';


class OSMNoteComment extends OSMComment {

  final OSMNoteAction action;

  final OSMUser? user;


  OSMNoteComment({
    required this.action,
    required super.date,
    required super.text,
    this.user,
  });

  /**
   * A shorthand to check whether this note is created anonymously and thus is
   * not connected to any user.
   */
  bool get isAnonymous => user == null;


  /**
   * A factory method for constructing an [OSMNoteComment] from a JSON object.
   */
  factory OSMNoteComment.fromJSONObject(Map<String, dynamic> obj) {
    return OSMNoteComment(
      action: osmNoteActionFromString(obj['action']),
      date: parseUTCDate(obj['date']),
      text: obj['text'],
      user: obj['uid'] != null && obj['user'] != null
        ? OSMUser(
          id: obj['uid'],
          name: obj['user'],
        )
        : null,
    );
  }
}
