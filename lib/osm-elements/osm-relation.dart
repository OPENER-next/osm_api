import 'package:collection/collection.dart';
import 'package:xml/xml.dart';

import 'osm-element-type.dart';
import 'osm-member.dart';
import 'osm-element.dart';

class OSMRelation extends OSMElement {
  List <OSMMember> members;

  OSMRelation(this.members, {
    Map<String, String>? tags,
    int? id,
    int? version
  }) : assert(members.isNotEmpty),
       super(id: id, version: version, tags: tags);


  static OSMRelation fromXMLElement(XmlElement relation) {
    var idAttr = relation.getAttribute('id');
    var versionAttr = relation.getAttribute('version');

    if (idAttr == null || versionAttr == null) {
      throw "TODO ERROR";
    }

    var id = int.parse(idAttr);
    var version = int.parse(versionAttr);

    var xmlTags = relation.findElements('tag');
    var xmlMembers = relation.findElements('member');

    var tags = <String, String>{};
    for (var xmlTag in xmlTags) {
      var key = xmlTag.getAttribute('k');
      var value = xmlTag.getAttribute('v');
      if (key == null || value == null) continue;
      tags[key] = value;
    }

    var members = <OSMMember>[];
    for (var xmlMember in xmlMembers) {
      var type = xmlMember.getAttribute('type');
      var ref = xmlMember.getAttribute('ref');
      if (type == null || ref == null) continue;

      var refNum = int.tryParse(ref);
      if (refNum == null) continue;

      var typeEnum = OSMElementType.values.firstWhere((e) => e.toShortString() == type);

      var role = xmlMember.getAttribute('role');

      members.add( OSMMember(typeEnum, refNum, role) );
    }

    return OSMRelation(members, id: id, version: version, tags: tags);
  }




  static OSMRelation fromXMLString(String xmlString) {
    var xmlDoc = XmlDocument.parse(xmlString);
    // search xml string for first relation occurence
    var relation = xmlDoc.findAllElements('relation').first;
    return fromXMLElement(relation);
  }


  @override
  String bodyToXML() {
    var xmlString = super.bodyToXML();
    members.forEach((member) => xmlString += member.toXML());
    return xmlString;
  }

  @override
  OSMElementType get type {
    return OSMElementType.relation;
  }

  @override
  String toString() {
    return '$runtimeType - members: $members; id: $id; version: $version; tags: $tags';
  }

  @override
  int get hashCode =>
    super.hashCode ^
    members.hashCode;

  @override
  bool operator == (o) =>
    identical(this, o) ||
    super == o &&
    o is OSMRelation &&
    runtimeType == o.runtimeType &&
    ListEquality().equals(members, o.members);
}