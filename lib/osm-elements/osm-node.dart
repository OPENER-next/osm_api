import 'osm-element-type.dart';
import 'osm-element.dart';
import 'package:xml/xml.dart';


class OSMNode extends OSMElement {
  late double lat;
  late double lon;

  OSMNode(this.lat, this.lon, {
    Map<String, String>? tags,
    int? id,
    int? version
  }) : super(id: id, version: version, tags: tags);


 static OSMNode fromXMLElement(XmlElement node) {
    var latAttr = node.getAttribute('lat');
    var lonAttr = node.getAttribute('lon');
    var idAttr = node.getAttribute('id');
    var versionAttr = node.getAttribute('version');

    if (latAttr == null || lonAttr == null || idAttr == null || versionAttr == null) {
      throw "TODO ERROR";
    }

    var lat = double.parse(latAttr);
    var lon = double.parse(lonAttr);
    var id = int.parse(idAttr);
    var version = int.parse(versionAttr);

    var xmlTags = node.findElements('tag');

    var tags = <String, String>{};
    for (var xmlTag in xmlTags) {
      var key = xmlTag.getAttribute('k');
      var value = xmlTag.getAttribute('v');
      if (key == null || value == null) continue;
      tags[key] = value;
    }

    return OSMNode(lat, lon, id: id, version: version, tags: tags);
  }


  static OSMNode fromXMLString(String xmlString) {
    var xmlDoc = XmlDocument.parse(xmlString);
    // search xml string for first node occurence
    var node = xmlDoc.findAllElements('node').first;
    return (fromXMLElement(node));
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