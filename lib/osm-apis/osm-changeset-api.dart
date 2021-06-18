import 'package:osmapi/osm-changesets/osm-changeset.dart';

import 'osm-api.dart';

class OSMChangesetAPI {

  // TODO: change static methods to class methods, perhaps even merge with elements api

  static Future<int> createChangeset(OSMAPI osmapi, OSMChangeset changeset) async {
    var response = await osmapi.sendRequest(
      '/changeset/create',
      type: 'PUT',
      body: '''
        <osm>
          <changeset>
            ${changeset.tagsToXML()}
          </changeset>
        </osm>
      '''
    );
    return int.parse(response.data);
  }


  static Future<String> getChangeset(OSMAPI osmapi, int id, [ bool includeDiscussion = true ]) async {
    var response = await osmapi.sendRequest(
      '/changeset/$id?include_discussion=$includeDiscussion'
    );
    return response.data;
  }


  static Future<void> closeChangeset(OSMAPI osmapi, int id) async {
    var response = await osmapi.sendRequest(
      '/changeset/$id/close',
      type: 'PUT'
    );
  }
}