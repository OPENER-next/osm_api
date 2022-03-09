/**
 * This [enum] is a representation of the main 3 OSM elements: node, way and relation.
 */
enum OSMElementType {
  node, way, relation
}


/**
 * A function that returns the lowercase name of the [OSMElementType] as a [String].
 */
extension ParseToString on OSMElementType {
  String toShortString() {
    return this.toString().split('.').last;
  }
}


/**
 * A function that tries to convert a given [String] to a [OSMElementType].
 */
OSMElementType osmElementTypeFromString(String value) {
  switch (value.trim()) {
    case 'node':
    return OSMElementType.node;

    case 'way':
    return OSMElementType.way;

    case 'relation':
    return OSMElementType.relation;

    default: throw("Given string cannot be converted to OSMElementType");
  }
}