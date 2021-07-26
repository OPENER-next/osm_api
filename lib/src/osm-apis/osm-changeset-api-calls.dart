import 'package:xml/xml.dart';
import '/src/commons/bounding-box.dart';
import '/src/osm-changeset/osm-changeset.dart';
import '/src/osm-apis/osm-api-base.dart';

/**
 * A mixin containing methods for handling OSM changesets.
 */
mixin OSMChangesetAPICalls on OSMAPIBase {


  /**
   * The default `created_by` value for newly created changesets.
   */
  String CREATED_BY = 'Dart OSM API';


  /**
   * A function for getting an [OSMChangeset] from the server by its id.
   *
   * By default no discussions are included. These can be retrieved by setting the [includeDiscussion] parameter to true.
   * Returns the [OSMChangeset] wrapped in a [Future] which resolves when the operation has been completed.
   */
  Future<OSMChangeset> getChangeset(int id, [ bool includeDiscussion = false ]) async {
    var additionalParameters = '';
    if (includeDiscussion) {
      additionalParameters += '?include_discussion=true';
    }

    final response = await sendRequest(
      '/changeset/$id' + additionalParameters
    );

    return OSMChangeset.fromXMLString(response.data);
  }


  /**
   * A function for opening a changeset on the server.
   *
   * Returns the id of the created changeset wrapped in a [Future] which resolves when the operation has been completed.
   * If not present, this function will add the `created_by` tag to the changeset with the value defined in [OSMChangesetAPICalls.CREATED_BY].
   */
  Future<int> createChangeset(Map<String, String> tags) async {
    // add own "created_by" tag if missing
    // because the API documentation states this tag should be present
    tags['created_by'] ??= CREATED_BY;

    final response = await sendRequest(
      '/changeset/create',
      type: 'PUT',
      body: _tagsToXMLBody(tags)
    );

    return int.parse(response.data);
  }


  /**
   * A function for updating the tags of a changeset on the server by its id.
   *
   * This will overwrite all existing tags on the changeset.
   * Closed changesets cannot be updated.
   * Returns the [OSMChangeset] wrapped in a [Future] which resolves when the operation has been completed.
   */
  Future<OSMChangeset> updateChangeset(int changesetId, Map<String, String> tags) async {
    final response = await sendRequest(
      '/changeset/$changesetId',
      type: 'PUT',
      body: _tagsToXMLBody(tags)
    );

    return OSMChangeset.fromXMLString(response.data);
  }


  /**
   * A function to construct the XML message body [String] from a given tag Map..
   */
  String _tagsToXMLBody(Map<String, String> tags) {
    var xmlString = '';
    tags.forEach((key, value) => xmlString +='<tag k="$key" v="$value"/>');
    return
    '<osm>'
      '<changeset>'
        '$xmlString'
      '</changeset>'
    '</osm>';
  }


  /**
   * A function for closing a changeset on the server by its id.
   *
   * If the changeset is already closed an error will be thrown.
   */
  Future<void> closeChangeset(int id) async {
    await sendRequest(
      '/changeset/$id/close',
      type: 'PUT'
    );
  }


  /**
   * A function to query multiple [OSMChangeset]s by different parameters and properties.
   *
   * This call returns at most 100 changesets, it returns latest changesets ordered by `created_at`.
   * [bbox] can be used to query changesets located inside a given [BoundingBox].
   * [uid] indicates the user by its id which authored the changesets.
   * [userName] indicates the user by its name which authored the changesets. This parameter is ignored if the [uid] parameter is set.
   * [open] indicates whether only open or closed changesets should be returned.
   * [closedAfter] can be used to query changesets that have been closed after a certain date/time.
   * [createdBefore] can be used in conjunction with [closedAfter] to retrieve only changesets that were open at a specifc period. This parameter is ignored if the [closedAfter] is not provided.
   * [changesets] can be used to query multiple changesets by their ids.
   *
   * Visit https://wiki.openstreetmap.org/wiki/API_v0.6#Query:_GET_/api/0.6/changesets for more details.
   */
  Future<Iterable<OSMChangeset>> queryChangesets({BoundingBox? bbox, int? uid, String? userName, bool? open, DateTime? closedAfter, DateTime? createdBefore, List<int>? changesets}) async {
    final queryParameters = <String, String>{};

    if (bbox != null) {
      queryParameters['bbox'] = bbox.toList().join(',');
    }

    if (uid != null) {
      queryParameters['user'] = uid.toString();
    }
    else if (userName != null) {
      queryParameters['display_name'] = userName;
    }

    if (open == true) {
      queryParameters['open'] = 'true';
    }
    else if (open == false) {
      queryParameters['closed'] = 'true';
    }

    if (closedAfter != null) {
      // created before parameter depends on closed after parameter
      if (createdBefore != null) {
        queryParameters['time'] = '${closedAfter.toIso8601String()},${createdBefore.toIso8601String()}';
      }
      else {
        queryParameters['time'] = closedAfter.toIso8601String();
      }
    }

    if (changesets != null) {
      queryParameters['changesets'] = changesets.join(',');
    }

    // build query string with url class
    final queryString = Uri(queryParameters: queryParameters).query;
    final response = await sendRequest(
      '/changesets?$queryString'
    );

    var xmlDoc = XmlDocument.parse(response.data);

    return _lazyXMLtoOSMChangesets(xmlDoc.rootElement.childElements);
  }


  /**
   * A generator/lazy iterable for converting XML elements to [OSMChangeset]s.
   */
  Iterable<OSMChangeset> _lazyXMLtoOSMChangesets(Iterable<XmlElement> elements) sync* {
    for (var element in elements) {
      if (element.name.toString() == 'changeset') {
        yield OSMChangeset.fromXMLElement(element);
      }
    }
  }


  /**
   * A function for adding a comment to a changeset on the server by its id.
   *
   * The changeset needs to be closed inorder to add comments.
   * If the changeset is still open an error will be thrown.
   */
  Future<void> addCommentToChangeset(int id, String text) async {
    await sendRequest(
      '/changeset/$id/comment?text=${Uri.encodeQueryComponent(text)}',
      type: 'POST'
    );
  }


  /**
   * A function to subscribe to the discussion of a changeset on the server by its id.
   *
   * This will send notifications to the user whenever a comment is posted.
   */
  Future<void> subscribeToChangeset(int id) async {
    await sendRequest(
      '/changeset/$id/subscribe',
      type: 'POST',
      // ignore Conflict error which is thrown if the user is already subscribed to the specified changeset
      ignoreStatusCodes: [409]
    );
  }


  /**
   * A function to unsubscribe from the discussion of a changeset on the server by its id.
   *
   * This will stop sending notifications to the user.
   */
  Future<void> unsubscribeFromChangeset(int id) async {
    await sendRequest(
      '/changeset/$id/unsubscribe',
      type: 'POST',
      // ignore Not Found error which is thrown if the user is not subscribed to the specified changeset
      ignoreStatusCodes: [404]
    );
  }
}