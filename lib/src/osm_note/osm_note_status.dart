/**
 * This [enum] is a representation of the 3 statuses an osm note can have: open, closed and hidden.
 */
enum OSMNoteStatus {
  open, closed, hidden
}


/**
 * A function that tries to convert a given [String] to a [OSMNoteStatus].
 */
OSMNoteStatus osmNoteStatusFromString(String value) {
  value = value.trim().toLowerCase();

  return OSMNoteStatus.values.firstWhere(
    (action) => action.name == value,
    orElse: () => throw StateError("Given string cannot be converted to OSMNoteStatus."),
  );
}
