import 'package:xml/xml.dart';

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


  /**
   * A factory method for constructing an [OSMNode] from a XML [String].
   */
  factory OSMNode.fromXMLString(String xmlString) {
    final xmlDoc = XmlDocument.parse(xmlString);
    final nodeElement = xmlDoc.findAllElements(OSMElementType.node.toShortString()).first;
    return OSMNode.fromXMLElement(nodeElement);
  }


  /**
   * A factory method for constructing an [OSMNode] from a XML [XmlElement].
   */
  factory OSMNode.fromXMLElement(XmlElement nodeElement) {
    final double lat, lon;
    final int? id, version;
    final tags = <String, String>{};

    // try parsing the necessary xml attributes
    try {
      lat = double.parse(
        nodeElement.getAttribute('lat')!
      );
      lon = double.parse(
        nodeElement.getAttribute('lon')!
      );
    }
    catch (e) {
      throw('Could not parse the given node XML string.');
    }

    id = int.tryParse(
      nodeElement.getAttribute('id') ?? ''
    );
    version = int.tryParse(
      nodeElement.getAttribute('version') ?? ''
    );

    nodeElement.findElements('tag').forEach((tag) {
      final key = tag.getAttribute('k');
      final value = tag.getAttribute('v');
      if (key != null && value != null) {
        tags[key] = value;
      }
    });

    return OSMNode(
      lat, lon,
      id: id,
      version: version,
      tags: tags
    );
  }


  @override
  OSMElementType get type => OSMElementType.node;


  @override
  StringBuffer toXML({
    StringBuffer? buffer,
    Map<String, dynamic> additionalAttributes = const {},
    bool includeBody = true,
  }) {
    return super.toXML(
      buffer: buffer,
      additionalAttributes: {
        'lat': lat.toStringAsFixed(7),
        'lon': lon.toStringAsFixed(7),
        ...additionalAttributes
      },
      includeBody: includeBody
    );
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