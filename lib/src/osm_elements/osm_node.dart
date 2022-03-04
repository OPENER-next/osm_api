import '/src/osm_elements/osm_element_type.dart';
import '/src/osm_elements/osm_element.dart';

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
  factory OSMNode.fromJSONObject(Map<String, dynamic> obj) => OSMNode(
    obj['lat'],
    obj['lon'],
    id: obj['id'],
    version: obj['version'],
    tags: obj['tags']?.cast<String, String>()
  );


  @override
  OSMElementType get type => OSMElementType.node;


  @override
  StringBuffer toXML({
    StringBuffer? buffer,
    int? changesetId
  }) {
    final stringBuffer = buffer ?? StringBuffer()
    ..write('<node')
    ..write(' id="')..write(id)..write('"')
    ..write(' version="')..write(version)..write('"')
    ..write(' lat="')..write(lat)..write('"')
    ..write(' lon="')..write(lon)..write('"');
    if (changesetId != null) {
      stringBuffer..write(' changeset="')..write(changesetId)..write('"');
    }
    stringBuffer.writeln('>');
    bodyToXML(stringBuffer)
    .writeln('</node>');

    return stringBuffer;
  }


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