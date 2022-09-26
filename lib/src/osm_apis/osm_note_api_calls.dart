import 'dart:convert';

import '/src/commons/order.dart';
import '/src/osm_note/osm_note.dart';
import '/src/commons/bounding_box.dart';
import '/src/osm_apis/osm_api_base.dart';
import '/src/osm_note/osm_note_sort_property.dart';

/**
 * A mixin containing methods for handling OSM changesets.
 */
mixin OSMNoteAPICalls on OSMAPIBase {


  /**
   * A function for querying multiple [OSMNote]s by a given bounding box.
   *
   * Returns the existing notes in the specified bounding box.
   * Notes will be ordered by the date of their last change, so the most recent one will be first.
   *
   * The amount of queried notes is limited by the [limit] parameter.
   * The [limit] needs to be between `1` and `10000` and defaults to `100`.
   *
   * Closed notes can be excluded by specifying a period in days using the [excludeClosedAfterPeriod] parameter.
   * This will only query closed notes that were closed less than the specified number of days ago.
   * A value of `0` means that no closed notes / only open notes will be queried.
   */
  Future<Iterable<OSMNote>> getNotesByBoundingBox(BoundingBox bbox, {
    int limit = 100,
    int? excludeClosedAfterPeriod,
  }) async {
    assert(limit >= 1 && limit <= 10000, 'The limit needs to be between 1 and 10000.');
    assert(excludeClosedAfterPeriod == null || excludeClosedAfterPeriod >= 0, 'The closed days period should be equal to or greater than zero.');

    final queryUri = Uri(
      path: '/notes',
      queryParameters: <String, String>{
        'bbox': bbox.toList().join(','),
        'limit': limit.toString(),
        'closed': (excludeClosedAfterPeriod ?? -1).toString(),
      },
    );

    final response = await sendRequest(
      queryUri.toString(),
      headers: const { 'Accept': 'application/json' },
    );

    return json.decode(response.data)['features']
      .cast<Map<String, dynamic>>()
      .map<OSMNote>(OSMNote.fromJSONObject);
  }


  /**
   * A function for getting an [OSMNote] from the server by its [id].
   *
   * Returns the [OSMNote] wrapped in a [Future] which resolves when the operation has been completed.
   */
  Future<OSMNote> getNote(int id) async {
    final response = await sendRequest(
      '/notes/$id',
      headers: const { 'Accept': 'application/json' },
    );

    return OSMNote.fromJSONObject(json.decode(response.data));
  }


  /**
   * A function for creating a note on the server.
   *
   * This request can be done as an unauthenticated/anonymous user.
   *
   * Returns a [OSMNote] wrapped in a [Future] which resolves when the operation has been completed.
   */
  Future<OSMNote> createNote({
    required double latitude,
    required double longitude,
    required String text,
  }) async {
    final queryUri = Uri(
      path: '/notes',
      queryParameters: <String, String>{
        'lat': latitude.toString(),
        'lon': longitude.toString(),
        'text': text,
      },
    );

    final response = await sendRequest(
      queryUri.toString(),
      type: 'POST',
      headers: const { 'Accept': 'application/json' },
    );

    return OSMNote.fromJSONObject(json.decode(response.data));
  }


  /**
   * A function for adding a comment to an existing note by its [id] on the server.
   *
   * This request needs to be done as an authenticated user.
   *
   * Returns the updated [OSMNote] wrapped in a [Future] which resolves when the operation has been completed.
   */
  Future<OSMNote> commentNote(int id, String text) async {
    final queryUri = Uri(
      path: '/notes/$id/comment',
      queryParameters: <String, String>{
        'text': text,
      },
    );

    final response = await sendRequest(
      queryUri.toString(),
      type: 'POST',
      headers: const { 'Accept': 'application/json' },
    );

    return OSMNote.fromJSONObject(json.decode(response.data));
  }


  /**
   * A function for closing a note on the server by its [id].
   *
   * Optionally a comment describing the reason for the closing can be added.
   *
   * This request needs to be done as an authenticated user.
   *
   * If the note is already closed this throw a 409 Conflict error.
   */
  Future<OSMNote> closeNote(int id, [ String? comment ]) async {
    final queryUri = Uri(
      path: '/notes/$id/close',
      queryParameters: <String, String>{
        if (comment != null) 'text': comment,
      },
    );

    final response = await sendRequest(
      queryUri.toString(),
      type: 'POST',
      headers: const { 'Accept': 'application/json' },
    );

    return OSMNote.fromJSONObject(json.decode(response.data));
  }


  /**
   * A function for reopening a closed note on the server by its [id].
   *
   * Optionally a comment describing the reason for the reopening can be added.
   *
   * This request needs to be done as an authenticated user.
   *
   * If the note is already open this throw a 409 Conflict error.
   */
  Future<OSMNote> reopenNote(int id, [ String? comment ]) async {
    final queryUri = Uri(
      path: '/notes/$id/reopen',
      queryParameters: <String, String>{
        if (comment != null) 'text': comment,
      },
    );

    final response = await sendRequest(
      queryUri.toString(),
      type: 'POST',
      headers: const { 'Accept': 'application/json' },
    );

    return OSMNote.fromJSONObject(json.decode(response.data));
  }


  /**
   * A function to query multiple [OSMNote]s by different parameters and properties.
   *
   * [searchTerm] specifies a string that must be present in a note.
   *
   * [uid] specifies a user by its id who participated in a note.
   *
   * [userName] specifies a user by its name who participated in a note. This parameter is ignored if the [uid] parameter is set.
   *
   * [from] specifies the beginning of a date range to search in for a note.
   *
   * [to] specifies the end of a date range to search in for a note. Defaults to the current date.
   *
   * [limit] specifies the amount of queried notes, defaults to `100`.
   * Needs to be between `1` and `10000` and.
   *
   * [excludeClosedAfterPeriod] excludes closed notes that were closed after the specified number of days.
   * A value of `0` means that no closed notes / only open notes will be queried.
   *
   * [sortBy] specifies if notes should be sorted either by their creation date or the date of their last update.
   *
   * [order] specifies the order of the returned notes.
   * Descending means newest first and ascending oldest first.
   *
   * Visit https://wiki.openstreetmap.org/wiki/API_v0.6#Search_for_notes:_GET_/api/0.6/notes/search for more details.
   */
  Future<Iterable<OSMNote>> queryNotes({String? searchTerm, int? uid, String? userName, DateTime? from, DateTime? to, int limit = 100, int? excludeClosedAfterPeriod, OSMNoteSortProperty sortBy = OSMNoteSortProperty.updatedAt, Order order = Order.descending}) async {
    assert(limit >= 1 && limit <= 10000, 'The limit needs to be between 1 and 10000.');
    assert(excludeClosedAfterPeriod == null || excludeClosedAfterPeriod >= 0, 'The closed days period should be equal to or greater than zero.');

    final queryParameters = <String, String>{
      'limit': limit.toString(),
      'closed': (excludeClosedAfterPeriod ?? -1).toString(),
    };

    if (searchTerm != null) {
      queryParameters['q'] = searchTerm;
    }

    if (uid != null) {
      queryParameters['user'] = uid.toString();
    }
    else if (userName != null) {
      queryParameters['display_name'] = userName;
    }

    if (from != null) {
      queryParameters['from'] = from.toIso8601String();
    }
    if (to != null) {
      queryParameters['to'] = to.toIso8601String();
    }

    switch (sortBy) {
      case OSMNoteSortProperty.createdAt:
        queryParameters['sort'] = 'created_at';
      break;
      case OSMNoteSortProperty.updatedAt:
        queryParameters['sort'] = 'updated_at';
      break;
    }

    switch (order) {
      case Order.ascending:
        queryParameters['order'] = 'oldest';
      break;
      case Order.descending:
        queryParameters['order'] = 'newest';
      break;
    }

    final queryUri = Uri(
      path: '/notes/search',
      queryParameters: queryParameters,
    );

    final response = await sendRequest(
      queryUri.toString(),
      headers: const { 'Accept': 'application/json' },
    );

    return json.decode(response.data)['features']
      .cast<Map<String, dynamic>>()
      .map<OSMNote>(OSMNote.fromJSONObject);
  }
}
