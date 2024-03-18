import 'package:collection/collection.dart';
import 'package:xml/xml.dart';
import '/src/osm_elements/osm_element_type.dart';
import '/src/osm_elements/osm_member.dart';
import '/src/osm_elements/osm_element.dart';

/**
 * A container class for the relation OSM element.
 */
class OSMRelation extends OSMElement {

  /**
   * A list of all [OSMMembers] that this relation contains.
   *
   * Normally a relation contains at least one member.
   */
  final List<OSMMember> members;


  OSMRelation(this.members, {
    super.tags,
    super.id,
    super.version,
  });


  /**
   * A factory method for constructing an [OSMRelation] from a JSON object.
   */
  factory OSMRelation.fromJSONObject(Map<String, dynamic> obj) {
    // Relations unfortunately can have no members (see https://wiki.openstreetmap.org/wiki/Empty_relations)
    // In this case the "members" property is omitted/missing.
    // Therefore a check and fallback to an empty Iterable is required.
    final List<OSMMember> members = (obj['members'] ?? const Iterable.empty())
      .map<OSMMember>((memberObj) => OSMMember(
        type: OSMElementType.values.firstWhere((e) => e.name == memberObj['type']),
        ref: memberObj['ref'],
        role: memberObj['role'],
      ))
      .toList();

    return OSMRelation(
      members,
      id: obj['id'],
      version: obj['version'],
      tags: obj['tags']?.cast<String, String>(),
    );
  }


  /**
   * A factory method for constructing an [OSMRelation] from an XML [String].
   */
  factory OSMRelation.fromXMLString(String xmlString) {
    final xmlDoc = XmlDocument.parse(xmlString);
    final relationElement = xmlDoc.findAllElements(OSMElementType.relation.name).first;
    return OSMRelation.fromXMLElement(relationElement);
  }


  /**
   * A factory method for constructing an [OSMRelation] from an XML [XmlElement].
   */
  factory OSMRelation.fromXMLElement(XmlElement relationElement) {
    final List<OSMMember> members;
    final int? id, version;
    final tags = <String, String>{};

    members = relationElement.findElements('member')
      .map((member) => OSMMember.fromXMLElement(member))
      .toList();

    id = int.tryParse(
      relationElement.getAttribute('id') ?? ''
    );
    version = int.tryParse(
      relationElement.getAttribute('version') ?? ''
    );

    relationElement.findElements('tag').forEach((tag) {
      final key = tag.getAttribute('k');
      final value = tag.getAttribute('v');
      if (key != null && value != null) {
        tags[key] = value;
      }
    });

    return OSMRelation(
      members,
      id: id,
      version: version,
      tags: tags,
    );
  }


  @override
  StringBuffer bodyToXML([ StringBuffer? buffer ]) {
    final stringBuffer = buffer ?? StringBuffer();
    members.forEach((member) => member.toXML(stringBuffer));
    return super.bodyToXML(buffer);
  }


  @override
  OSMElementType get type => OSMElementType.relation;


  @override
  bool get hasBody => super.hasBody || members.isNotEmpty;


  @override
  String toString() => '$runtimeType - members: $members; id: $id; version: $version; tags: $tags';


  @override
  OSMRelation copyWith({
    List<OSMMember>? members,
    Map<String, String>? tags,
    int? id,
    int? version,
  }) {
    return OSMRelation(
      members ?? List.of(this.members.map((m) => m.copyWith())),
      tags: tags ?? Map.of(this.tags),
      id: id ?? this.id,
      version: version ?? this.version,
    );
  }


  @override
  int get hashCode =>
    super.hashCode ^
    // do not use members.hashCode since the hasCodes may differ even if the values are equal.
    // see https://api.flutter.dev/flutter/dart-core/Object/hashCode.html
    // "The default hash code implemented by Object represents only the identity of the object,"
    Object.hashAll(members);


  @override
  bool operator == (o) =>
    identical(this, o) ||
    super == o &&
    o is OSMRelation &&
    runtimeType == o.runtimeType &&
    ListEquality().equals(members, o.members);
}
