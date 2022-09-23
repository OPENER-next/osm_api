/**
 * Helper function to parse the special OSM date time UTC format.
 *
 * OSM returns "2022-09-13 20:52:52 UTC" but Dart expects "2022-09-13 20:52:52 Z"
 */
DateTime parseUTCDate(String dateString) {
  final stringIndex = dateString.lastIndexOf('UTC');
  return stringIndex > -1
    ? DateTime.parse(dateString.replaceRange(stringIndex, null, 'Z'))
    : DateTime.parse(dateString);
}
