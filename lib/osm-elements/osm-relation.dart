import 'package:collection/collection.dart';
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


  static OSMRelation fromJSONObject(obj) {
    var members = <OSMMember>[];
    for (var memberObj in obj['members']) {
      var typeEnum = OSMElementType.values.firstWhere((e) => e.toShortString() == memberObj['type']);
      members.add( OSMMember(typeEnum, memberObj['ref'], memberObj['role']) );
    }

    return OSMRelation(
      members,
      id: obj['id'],
      version: obj['version'],
      tags: obj['tags']?.cast<String, String>()
    );
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