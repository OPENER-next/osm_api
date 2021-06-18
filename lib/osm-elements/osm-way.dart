import 'package:collection/collection.dart';
import 'package:xml/xml.dart';

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


  static OSMWay fromXMLElement(XmlElement way) {
    var idAttr = way.getAttribute('id');
    var versionAttr = way.getAttribute('version');

    if (idAttr == null || versionAttr == null) {
      throw "TODO ERROR";
    }

    var id = int.parse(idAttr);
    var version = int.parse(versionAttr);

    var xmlTags = way.findElements('tag');
    var xmlNodes = way.findElements('nd');

    var tags = <String, String>{};
    for (var xmlTag in xmlTags) {
      var key = xmlTag.getAttribute('k');
      var value = xmlTag.getAttribute('v');
      if (key == null || value == null) continue;

      tags[key] = value;
    }

    var nodeIds = <int>[];
    for (var xmlNode in xmlNodes) {
      var nodeRef = xmlNode.getAttribute('ref');
      if (nodeRef == null) continue;

      var nodeRefNum = int.tryParse(nodeRef);
      if (nodeRefNum == null) continue;

      nodeIds.add(nodeRefNum);
    }

    return OSMWay(nodeIds, id: id, version: version, tags: tags);
  }


  static OSMWay fromXMLString(String xmlString) {
    var xmlDoc = XmlDocument.parse(xmlString);
    // search xml string for first way occurence
    var way = xmlDoc.findAllElements('way').first;
    return fromXMLElement(way);
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