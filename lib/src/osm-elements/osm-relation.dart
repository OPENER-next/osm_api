import 'package:collection/collection.dart';
import '/src/osm-elements/osm-element-type.dart';
import '/src/osm-elements/osm-member.dart';
import '/src/osm-elements/osm-element.dart';

/**
 * A container class for the relation OSM element.
 */
class OSMRelation extends OSMElement {

  /**
   * A list of all [OSMMembers] that this relation contains.
   *
   * A relation should at least contain one member.
   */
  List <OSMMember> members;


  OSMRelation(this.members, {
    Map<String, String>? tags,
    int? id,
    int? version
  }) : assert(members.isNotEmpty),
       super(id: id, version: version, tags: tags);


  /**
   * A factory method for constructing an [OSMRelation] from a JSON object.
   */
  static OSMRelation fromJSONObject(Map<String, dynamic> obj) {
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
  OSMElementType get type => OSMElementType.relation;


  @override
  String toString() => '$runtimeType - members: $members; id: $id; version: $version; tags: $tags';


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