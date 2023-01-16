import 'dart:convert';

import 'package:xml/xml.dart';

import '/src/osm_elements/osm_element.dart';
import '/src/osm_elements/osm_element_type.dart';

/**
 * A container class for the member OSM element.
 */
class OSMMember {

  /**
   * A reference/id of the OSM element this member points to.
   */
  int ref;

  /**
   * The [OSMElementType] this member points to.
   */
  OSMElementType type;

  /**
   * The role of the element in the parent relation.
   */
  String role;


  OSMMember({
    required this.type,
    required this.ref,
    String? role,
  }) : role = role ?? '';


  /**
   * Construct an [OSMMember] from an [OSMElement] with an optional [role].
   */
  OSMMember.fromOSMElement(OSMElement element, [String? role])
    : ref = element.id, type = element.type, role = role ?? '';


  /**
   * A factory method for constructing an [OSMMember] from a XML [XmlElement].
   */
  factory OSMMember.fromXMLElement(XmlElement memberElement) {
    final int ref;
    final OSMElementType type;
    final String? role;

    // try parsing the necessary xml attributes
    try {
      ref = int.parse(
        memberElement.getAttribute('ref')!
      );
      type = osmElementTypeFromString(
        memberElement.getAttribute('type')!
      );
    }
    catch (e) {
      throw('Could not parse the given member XML string.');
    }

    role = memberElement.getAttribute('role');

    return OSMMember(
      type: type,
      ref: ref,
      role: role,
    );
  }


  /**
   * A function to serialize the element to an XML [String].
   */
  StringBuffer toXML([ StringBuffer? buffer ]) {
    final sanitizer = const HtmlEscape(HtmlEscapeMode.attribute);
    // escape special XML characters
    final role = sanitizer.convert(this.role);

    return buffer ?? StringBuffer()
      ..write('<member')
      ..write(' type="')..write(type.name)..write('"')
      ..write(' ref="')..write(ref)..write('"')
      ..write(' role="')..write(role)..write('"')
      ..writeln('/>');
  }


  @override
  String toString() => '$runtimeType - ref: $ref; type: $type; role: $role';


  OSMMember copyWith({
    int? ref,
    OSMElementType? type,
    String? role,
  }) {
    return OSMMember(
      type: type ?? this.type,
      ref: ref ?? this.ref,
      role: role ?? this.role,
    );
  }


  @override
  int get hashCode =>
    ref.hashCode ^
    type.hashCode ^
    role.hashCode;


  @override
  bool operator == (o) =>
    identical(this, o) ||
    o is OSMMember &&
    runtimeType == o.runtimeType &&
    ref == o.ref &&
    type == o.type &&
    role == o.role;
}
