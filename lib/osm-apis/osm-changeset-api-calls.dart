import 'package:osmapi/osm-changesets/osm-changeset.dart';

import 'osm-api-base.dart';
import 'osm-api.dart';

/**
 * A mixin containing methods for handling OSM changesets.
 */
mixin OSMChangesetAPICalls on OSMAPIBase {

  Future<int> createChangeset(OSMChangeset changeset) async {
    var response = await sendRequest(
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


  Future<String> getChangeset(int id, [ bool includeDiscussion = true ]) async {
    var response = await sendRequest(
      '/changeset/$id?include_discussion=$includeDiscussion'
    );
    return response.data;
  }


  Future<void> closeChangeset(int id) async {
    var response = await sendRequest(
      '/changeset/$id/close',
      type: 'PUT'
    );
  }
}