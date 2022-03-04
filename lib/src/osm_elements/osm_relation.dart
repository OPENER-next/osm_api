import 'package:collection/collection.dart';
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
   * A relation should at least contain one member.
   */
  final List<OSMMember> members;


  OSMRelation(this.members, {
    Map<String, String>? tags,
    int? id,
    int? version
  }) : assert(members.isNotEmpty),
       super(id: id, version: version, tags: tags);


  /**
   * A factory method for constructing an [OSMRelation] from a JSON object.
   */
  factory OSMRelation.fromJSONObject(Map<String, dynamic> obj) {
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
  StringBuffer bodyToXML([ StringBuffer? buffer ]) {
    final stringBuffer = super.bodyToXML(buffer);
    members.forEach((member) => member.toXML(stringBuffer));
    return stringBuffer;
  }


  @override
  StringBuffer toXML({
    StringBuffer? buffer,
    int? changesetId
  }) {
    final stringBuffer = buffer ?? StringBuffer()
    ..write('<relation')
    ..write(' id="')..write(id)..write('"')
    ..write(' version="')..write(version)..write('"');
    if (changesetId != null) {
      stringBuffer..write(' changeset="')..write(changesetId)..write('"');
    }
    stringBuffer.writeln('>');
    bodyToXML(stringBuffer)
    .writeln('</relation>');

    return stringBuffer;
  }


  @override
  OSMElementType get type => OSMElementType.relation;


  @override
  String toString() => '$runtimeType - members: $members; id: $id; version: $version; tags: $tags';


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