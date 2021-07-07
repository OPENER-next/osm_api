import 'osm-element-type.dart';
import 'osm-element.dart';

/**
 * A container class for the node OSM element.
 */
class OSMNode extends OSMElement {

  /**
   * The latitude of this node.
   */

  double lat;
  /**
   * The longitude of this node.
   */
  double lon;


  OSMNode(this.lat, this.lon, {
    Map<String, String>? tags,
    int? id,
    int? version
  }) : super(id: id, version: version, tags: tags);


  /**
   * A factory method for constructing an [OSMNode] from a JSON object.
   */
  static OSMNode fromJSONObject(Map<String, dynamic> obj) => OSMNode(
    obj['lat'],
    obj['lon'],
    id: obj['id'],
    version: obj['version'],
    tags: obj['tags']?.cast<String, String>()
  );


  @override
  OSMElementType get type => OSMElementType.node;


  @override
  String toString() => '$runtimeType - lat: $lat; lon: $lon; id: $id; version: $version; tags: $tags';


  @override
  int get hashCode =>
    super.hashCode ^
    lat.hashCode ^
    lon.hashCode;


  @override
  bool operator == (o) =>
    identical(this, o) ||
    super == o &&
    o is OSMNode &&
    runtimeType == o.runtimeType &&
    lat == o.lat &&
    lon == o.lon;
}