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
  final List<int> nodeIds;


  OSMWay(this.nodeIds, {
    Map<String, String>? tags,
    int? id,
    int? version
  }) : assert (nodeIds.length >= 2),
       super(id: id, version: version, tags: tags);


  /**
   * A factory method for constructing an [OSMWay] from a JSON object.
   */
  factory OSMWay.fromJSONObject(Map<String, dynamic> obj) => OSMWay(
    obj['nodes']?.cast<int>(),
    id: obj['id'],
    version: obj['version'],
    tags: obj['tags']?.cast<String, String>()
  );


  @override
  StringBuffer bodyToXML([ StringBuffer? buffer ]) {
    final stringBuffer = super.bodyToXML(buffer);
    nodeIds.forEach((nodeId) {
      stringBuffer
      ..write('<nd')
      ..write(' ref="')..write(nodeId)..write('"')
      ..writeln('/>');
    });
    return stringBuffer;
  }


  @override
  StringBuffer toXML({
    StringBuffer? buffer,
    int? changesetId
  }) {
    final stringBuffer = buffer ?? StringBuffer()
    ..write('<way')
    ..write(' id="')..write(id)..write('"')
    ..write(' version="')..write(version)..write('"');
    if (changesetId != null) {
      stringBuffer..write(' changeset="')..write(changesetId)..write('"');
    }
    stringBuffer.writeln('>');
    bodyToXML(stringBuffer)
    .writeln('</way>');

    return stringBuffer;
  }


  @override
  OSMElementType get type => OSMElementType.way;


  /// Returns true if the way is closed (in other words the first point equals the last point),
  /// but only if the way is at least composed of 3 nodes.

  bool get isClosed => nodeIds.length > 2 && nodeIds.first == nodeIds.last;


  @override
  String toString() => '$runtimeType - nodes: $nodeIds; id: $id; version: $version; tags: $tags';


  @override
  int get hashCode =>
    super.hashCode ^
    // do not use nodeIds.hashCode since the hasCodes may differ even if the values are equal.
    // see https://api.flutter.dev/flutter/dart-core/Object/hashCode.html
    // "The default hash code implemented by Object represents only the identity of the object,"
    Object.hashAll(nodeIds);


  @override
  bool operator == (o) =>
    identical(this, o) ||
    super == o &&
    o is OSMWay &&
    runtimeType == o.runtimeType &&
    ListEquality().equals(nodeIds, o.nodeIds);
}