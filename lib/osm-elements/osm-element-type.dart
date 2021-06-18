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