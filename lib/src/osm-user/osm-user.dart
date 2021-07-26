/**
 * An immutable container class for an OSM user.
 * This contains the uid and display_name of a user.
 */
class OSMUser {

  /**
   * The unique identifier of the user.
   */
  final int id;

  /**
   * The unique user name (also known as display name) of the user.
   */
  final String name;


  OSMUser(this.id, this.name);


  @override
  String toString() => '$runtimeType - id: $id; name: $name';


  @override
  int get hashCode =>
    id.hashCode ^
    name.hashCode;


  @override
  bool operator == (o) =>
    identical(this, o) ||
    o is OSMUser &&
    runtimeType == o.runtimeType &&
    id == o.id &&
    name == o.name;
}