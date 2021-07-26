import '/src/osm-elements/osm-element.dart';
import '/src/osm-elements/osm-element-type.dart';

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


  OSMMember(this.type, this.ref, [String? role]) : this.role = role ?? '';


  /**
   * Construct an [OSMMember] from an [OSMElement] with an optional [role].
   */
  OSMMember.fromOSMElement(OSMElement element, [String? role])
    : ref = element.id, type = element.type, this.role = role ?? '';


  /**
   * A function to serialize the element to an XML [String].
   */
  String toXML() {
    return '<member type="${type.toShortString()}" role="$role" ref="$ref"/>';
  }


  @override
  String toString() => '$runtimeType - ref: $ref; type: $type; role: $role';


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