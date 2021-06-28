import 'package:collection/collection.dart';
import 'osm-element-type.dart';
import 'osm-element.dart';

class OSMWay extends OSMElement {
  List<int> nodeIds;

  OSMWay(this.nodeIds, {
    Map<String, String>? tags,
    int? id,
    int? version
  }) : assert (nodeIds.length >= 2),
       super(id: id, version: version, tags: tags);


  static OSMWay fromJSONObject(obj) {
    return OSMWay(
      obj['nodes']?.cast<int>(),
      id: obj['id'],
      version: obj['version'],
      tags: obj['tags']?.cast<String, String>()
    );
  }


  @override
  String bodyToXML() {
    var xmlString = super.bodyToXML();
    nodeIds.forEach((nodeId) => xmlString += '<nd ref="$nodeId"/>');
    return xmlString;
  }


  @override
  OSMElementType get type {
    return OSMElementType.way;
  }


  @override
  String toString() {
    return '$runtimeType - nodes: $nodeIds; id: $id; version: $version; tags: $tags';
  }


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