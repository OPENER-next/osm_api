import 'package:collection/collection.dart';
import 'package:xml/xml.dart';
import '/src/osm_elements/osm_element_type.dart';
import '/src/osm_elements/osm_element.dart';

/**
 * A container class for the way OSM element.
 */
class OSMWay extends OSMElement {

  /**
   * A list of all node ids ([OSMNode.id]) that this way contains.
   *
   * Normally a way contains at least two nodes.
   */
  final List<int> nodeIds;


  OSMWay(this.nodeIds, {
    Map<String, String>? tags,
    int? id,
    int? version
  }) : super(id: id, version: version, tags: tags);


  /**
   * A factory method for constructing an [OSMWay] from a JSON object.
   */
  factory OSMWay.fromJSONObject(Map<String, dynamic> obj) => OSMWay(
    obj['nodes']?.cast<int>(),
    id: obj['id'],
    version: obj['version'],
    tags: obj['tags']?.cast<String, String>()
  );


  /**
   * A factory method for constructing an [OSMWay] from a XML [String].
   */
  factory OSMWay.fromXMLString(String xmlString) {
    final xmlDoc = XmlDocument.parse(xmlString);
    final wayElement = xmlDoc.findAllElements(OSMElementType.way.toShortString()).first;
    return OSMWay.fromXMLElement(wayElement);
  }


  /**
   * A factory method for constructing an [OSMWay] from a XML [XmlElement].
   */
  factory OSMWay.fromXMLElement(XmlElement wayElement) {
    final List<int> nodeIds;
    final int? id, version;
    final tags = <String, String>{};

    nodeIds = wayElement.findElements('nd')
      .map((node) => int.tryParse(node.getAttribute('ref') ?? ''))
      .whereType<int>()
      .toList();

    id = int.tryParse(
      wayElement.getAttribute('id') ?? ''
    );
    version = int.tryParse(
      wayElement.getAttribute('version') ?? ''
    );

    wayElement.findElements('tag').forEach((tag) {
      final key = tag.getAttribute('k');
      final value = tag.getAttribute('v');
      if (key != null && value != null) {
        tags[key] = value;
      }
    });

    return OSMWay(
      nodeIds,
      id: id,
      version: version,
      tags: tags
    );
  }


  @override
  StringBuffer bodyToXML([ StringBuffer? buffer ]) {
    final stringBuffer = buffer ?? StringBuffer();
    nodeIds.forEach((nodeId) {
      stringBuffer
      ..write('<nd')
      ..write(' ref="')..write(nodeId)..write('"')
      ..writeln('/>');
    });
    return super.bodyToXML(stringBuffer);
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