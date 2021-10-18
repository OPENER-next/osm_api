import 'package:collection/collection.dart';
import '/src/osm_elements/osm_element_type.dart';
import '/src/osm_elements/osm_element.dart';

/**
 * A container class for the way OSM element.
 */
class OSMWay extends OSMElement {

  /**
   * A list of all node ids ([OSMNode.id]) that this way contains.
   *
   * A way should at least contain two nodes.
   */
  List<int> nodeIds;


  OSMWay(this.nodeIds, {
    Map<String, String>? tags,
    int? id,
    int? version
  }) : assert (nodeIds.length >= 2),
       super(id: id, version: version, tags: tags);


  /**
   * A factory method for constructing an [OSMWay] from a JSON object.
   */
  static OSMWay fromJSONObject(Map<String, dynamic> obj) => OSMWay(
    obj['nodes']?.cast<int>(),
    id: obj['id'],
    version: obj['version'],
    tags: obj['tags']?.cast<String, String>()
  );


  @override
  String bodyToXML() {
    var xmlString = super.bodyToXML();
    nodeIds.forEach((nodeId) => xmlString += '<nd ref="$nodeId"/>');
    return xmlString;
  }


  @override
  OSMElementType get type => OSMElementType.way;


  @override
  String toString() => '$runtimeType - nodes: $nodeIds; id: $id; version: $version; tags: $tags';


  @override
  int get hashCode =>
    super.hashCode ^
    nodeIds.hashCode;


  @override
  bool operator == (o) =>
    identical(this, o) ||
    super == o &&
    o is OSMWay &&
    runtimeType == o.runtimeType &&
    ListEquality().equals(nodeIds, o.nodeIds);
}