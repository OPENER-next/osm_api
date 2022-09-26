/**
 * This [enum] is a representation of all the actions that can be taken on a note.
 */
enum OSMNoteAction {
  opened, commented, closed, reopened, hidden
}


/**
 * A function that tries to convert a given [String] to a [OSMNoteAction].
 */
OSMNoteAction osmNoteActionFromString(String value) {
  value = value.trim().toLowerCase();

  return OSMNoteAction.values.firstWhere(
    (action) => action.name == value,
    orElse: () => throw StateError("Given string cannot be converted to OSMNoteAction."),
  );
}
