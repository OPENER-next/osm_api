import 'package:xml/xml.dart';
import 'package:collection/collection.dart';

/**
 * A container class for granted OSM permissions.
 */
class OSMPermissions {

  /**
   * OSM permission string constants.
   */
  static const
  READ_USER_PREFERENCES = 'allow_read_prefs',
  WRITE_USER_PREFERENCES = 'allow_write_prefs',
  WRITE_DIARY = 'allow_write_diary',
  WRITE_MAP = 'allow_write_api',
  READ_GPS_TRACES = 'allow_read_gpx',
  WRITE_GPS_TRACES = 'allow_write_gpx',
  WRITE_NOTES = 'allow_write_notes';


  /**
   * A Set holding all granted permissions.
   */
  final Set<String> _permissions;


  OSMPermissions([this._permissions = const <String>{}]) ;


  /**
   * A factory method for constructing an [OSMPermissions] object from an XML [String].
   */
  static OSMPermissions fromXMLString(xmlString) {
    var xmlDoc = XmlDocument.parse(xmlString);
    return OSMPermissions(
      xmlDoc.findAllElements('permission').expand((element) {
        var name = element.getAttribute('name');
        return name != null ? [name] : <String>[];
      }).toSet()
    );
  }


  /**
   * A function to check if a certain permission is granted.
   */
  bool has(String permission) => _permissions.contains(permission);


  /**
   * A function to check if multiple permissions are granted.
   */
  bool hasAll(Iterable<String> permissions) => _permissions.containsAll(permissions);


  @override
  String toString() {
    return '$runtimeType - permissions: $_permissions';
  }


  @override
  int get hashCode =>
    _permissions.hashCode;


  /**
   * [OSMPermissions] objects are considered equal if they contain the same set of permissions.
   */
  @override
  bool operator == (o) =>
    identical(this, o) ||
    o is OSMPermissions &&
    runtimeType == o.runtimeType &&
    SetEquality().equals(_permissions, o._permissions);
}