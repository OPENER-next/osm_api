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
   *
   * Parsing an OsmChange from OSM will not include the lat/lon attributes,
   * for this very tiny exception instead of making [lat] and [lon] nullable we set them to [double.nan].
   * Find an example OsmChange here: https://www.openstreetmap.org/api/0.6/changeset/118455458/download
   */
  factory OSMNode.fromXMLString(String xmlString) {
    final xmlDoc = XmlDocument.parse(xmlString);
    final nodeElement = xmlDoc.findAllElements(OSMElementType.node.name).first;
    return OSMNode.fromXMLElement(nodeElement);
  }


  /**
   * A factory method for constructing an [OSMNode] from a XML [XmlElement].
   *
   * Parsing an OsmChange from OSM will not include the lat/lon attributes,
   * for this very tiny exception instead of making [lat] and [lon] nullable we set them to [double.nan].
   * Find an example OsmChange here: https://www.openstreetmap.org/api/0.6/changeset/118455458/download
   */
  factory OSMNode.fromXMLElement(XmlElement nodeElement) {
    final double lat, lon;
    final int? id, version;
    final tags = <String, String>{};

    lat = double.tryParse(
      nodeElement.getAttribute('lat') ?? 'NaN'
    ) ?? double.nan;
    lon = double.tryParse(
      nodeElement.getAttribute('lon') ?? 'NaN'
    ) ?? double.nan;

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
    bool includeBody = true
  }) {
    return super.toXML(
      buffer: buffer,
      additionalAttributes: {
        if (lat.isFinite) 'lat': lat.toStringAsFixed(7),
        if (lon.isFinite) 'lon': lon.toStringAsFixed(7),
        ...additionalAttributes
      },
      includeBody: includeBody
    );
  }


  @override
  String toString() => '$runtimeType - lat: $lat; lon: $lon; id: $id; version: $version; tags: $tags';


  @override
  OSMNode copyWith({
    double? lat,
    double? lon,
    Map<String, String>? tags,
    int? id,
    int? version
  }) {
    return OSMNode(lat ?? this.lat, lon ?? this.lon,
      tags: tags ?? Map.of(this.tags),
      id: id ?? this.id,
      version: version ?? this.version
    );
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
