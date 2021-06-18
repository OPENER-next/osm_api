import 'package:osmapi/osm-elements/osm-element.dart';

import 'osm-element-type.dart';

class OSMMember {
  int ref;

  OSMElementType type;

  String role;

  OSMMember(this.type, this.ref, [String? role]) : this.role = role ?? '';

  OSMMember.fromOSMElement(OSMElement element, [String? role])
    : ref = element.id, type = element.type, this.role = role ?? '';

  String toXML() {
    return '<member type="${type.toShortString()}" role="$role" ref="$ref"/>';
  }

  @override
  String toString() {
    return '$runtimeType - ref: $ref; type: $type; role: $role';
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