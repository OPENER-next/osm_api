/**
 * A container class for a geographical bounding box.
 */
class BoundingBox {

  /**
   * The left, bottom and right, top coordinates.
   */
	double minLongitude, minLatitude, maxLongitude, maxLatitude;


  /**
   * Expects the coordinates as follows:
   * [minLongitude] (left), [minLatitude] (bottom), [maxLongitude] (right) and [maxLatitude] (top).
   */
	BoundingBox(this.minLongitude, this.minLatitude, this.maxLongitude, this.maxLatitude);


  /**
   * A function which converts this bounding box to a fixed [List] of coordinates.
   *
   * The order will be:
   * [minLongitude] (left), [minLatitude] (bottom), [maxLongitude] (right) and [maxLatitude] (top).
   */
  List<double> toList() {
    return List.of([minLongitude, minLatitude, maxLongitude, maxLatitude], growable: false);
  }


  @override
  String toString() => '$runtimeType: min Longitude: $minLongitude, min Latitude: $minLatitude, max Longitude: $maxLongitude, max Latitude: $maxLatitude';


  @override
  int get hashCode =>
    minLongitude.hashCode ^
    minLatitude.hashCode ^
    maxLongitude.hashCode ^
    maxLatitude.hashCode;


  /**
   * BoundingBoxes are considered equal if their geographical coordinates match.
   */
  @override
  bool operator == (o) =>
    identical(this, o) ||
    o is BoundingBox &&
    runtimeType == o.runtimeType &&
    minLongitude == o.minLongitude &&
    minLatitude == o.minLatitude &&
    maxLongitude == o.maxLongitude &&
    maxLatitude == o.maxLatitude;
}