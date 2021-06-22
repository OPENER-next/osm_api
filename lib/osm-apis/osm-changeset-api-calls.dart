import 'package:osmapi/osm-changesets/osm-changeset.dart';

import 'osm-api-base.dart';
import 'osm-api.dart';

/**
 * A mixin containing methods for handling OSM changesets.
 */
mixin OSMChangesetAPICalls on OSMAPIBase {

  Future<int> createChangeset(OSMAPI osmapi, OSMChangeset changeset) async {
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


  Future<String> getChangeset(OSMAPI osmapi, int id, [ bool includeDiscussion = true ]) async {
    var response = await osmapi.sendRequest(
      '/changeset/$id?include_discussion=$includeDiscussion'
    );
    return response.data;
  }


  Future<void> closeChangeset(OSMAPI osmapi, int id) async {
    var response = await sendRequest(
      '/changeset/$id/close',
      type: 'PUT'
    );
  }
}