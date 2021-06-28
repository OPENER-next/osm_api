import 'osm-element-type.dart';
import 'osm-element.dart';

class OSMNode extends OSMElement {
  late double lat;
  late double lon;

  OSMNode(this.lat, this.lon, {
    Map<String, String>? tags,
    int? id,
    int? version
  }) : super(id: id, version: version, tags: tags);


  static OSMNode fromJSONObject(obj) {
    return OSMNode(
      obj['lat'],
      obj['lon'],
      id: obj['id'],
      version: obj['version'],
      tags: obj['tags']?.cast<String, String>()
    );
  }


  @override
  OSMElementType get type {
    return OSMElementType.node;
  }


  @override
  String toString() {
    return '$runtimeType - lat: $lat; lon: $lon; id: $id; version: $version; tags: $tags';
  }


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