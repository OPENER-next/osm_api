import 'package:collection/collection.dart';

import 'osm-element-type.dart';

/**
 * A function for getting an [OSMRelation] from the server by its id.
 *
 * Optionally a specific version of the relation can be requested by using the [version] parameter.
 * Returns the [OSMRelation] as a [Future].
 */
abstract class OSMElement {
  Map<String, String> tags;

  int id;

  int version;

  OSMElement({
    Map<String, String>? tags,
    int? id,
    int? version
  }) :
  this.tags = tags ?? <String, String>{},
  this.id = id ?? 0,
  this.version = version ?? 0;

  OSMElementType get type;

  String bodyToXML() {
    var xmlString = '';
    tags.forEach((key, value) => xmlString +='<tag k="$key" v="$value"/>');
    return xmlString;
  }

  @override
  int get hashCode =>
    id.hashCode ^
    version.hashCode ^
    tags.hashCode;

  @override
  bool operator == (o) =>
    o is OSMElement &&
    id == o.id &&
    version == o.version &&
    MapEquality().equals(tags, o.tags);
}