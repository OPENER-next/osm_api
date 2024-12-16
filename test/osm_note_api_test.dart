import 'package:osm_api/osm_api.dart';
import 'package:test/test.dart';

void main() async {
  late final OSMAPI osmapi;
  late final OSMAPI osmapiNoAuth;

  late final OSMUser testUser;

  const specialText = r'!"§$%&/()=?`¹²³¼½¬{[]}\,.-+*~<>|@€#abc123';

  setUpAll(() async {
    osmapi = OSMAPI(
      baseUrl: 'http://127.0.0.1:3000/api/0.6',
      authentication: OAuth2(
        accessToken: 'DummyTestToken',
      ),
    );

    osmapiNoAuth = OSMAPI(
      baseUrl: 'http://127.0.0.1:3000/api/0.6',
    );

    final userDetails = await osmapi.getCurrentUserDetails();
    testUser = OSMUser(id: userDetails.id, name: userDetails.name);
  });


  // note creation tests

  test('check anonymous and authenticated note creation', () async {
    final lat = 0.1, lon = 0.1;

    final anonymousNote = await osmapiNoAuth.createNote(
      latitude: lat,
      longitude: lon,
      text: specialText,
    );

    final authenticatedNote = await osmapi.createNote(
      latitude: lat,
      longitude: lon,
      text: specialText,
    );

    // ensure at least one second difference to previous date
    await Future.delayed(Duration(seconds: 1));

    for (final note in [anonymousNote, authenticatedNote]) {
      expect(note.comments, hasLength(equals(1)));
      expect(note.comments.first, isA<OSMNoteComment>());
      expect(note.comments.first.action, equals(OSMNoteAction.opened));
      expect(note.comments.first.date.isBefore(DateTime.now()), isTrue);
      expect(note.comments.first.text, equals(specialText));

      expect(note.isOpen, isTrue);
      expect(note.closedAt, isNull);
      expect(note.createdAt.isBefore(DateTime.now()), isTrue);
      expect(note.id, isPositive);
      expect(note.isClosed, isFalse);
      expect(note.isOpen, isTrue);
      expect(note.isHidden, isFalse);
      expect(note.status, equals(OSMNoteStatus.open));
      expect(note.lat, equals(lat));
      expect(note.lon, equals(lon));
    }

    expect(anonymousNote.comments.first.isAnonymous, isTrue);
    expect(anonymousNote.comments.first.user, isNull);

    expect(authenticatedNote.comments.first.isAnonymous, isFalse);
    expect(authenticatedNote.comments.first.user, equals(testUser));
  });

  // note retrieval tests

  test('check retrieving specific note', () async {
    final createdNote = await osmapi.createNote(
      latitude: 0.1,
      longitude: 0.1,
      text: 'test',
    );

    final queriedNote = await osmapi.getNote(createdNote.id);

    expect(queriedNote, equals(createdNote));
  });

  test('check retrieving notes by bounding box', () async {
    var anonymousNote = await osmapiNoAuth.createNote(
      latitude: 0.1,
      longitude: 0.1,
      text: 'test1',
    );
    final authenticatedNote = await osmapi.createNote(
      latitude: 0.2,
      longitude: 0.2,
      text: 'test2',
    );

    {
      final queriedNotes = await osmapi.getNotesByBoundingBox(
        BoundingBox(0, 0, 0.3, 0.3),
      );
      // expect at least 2 notes in this bbox (more might be returned)
      expect(queriedNotes, hasLength(greaterThanOrEqualTo(2)));
      // check for correct order
      expect(queriedNotes, containsAllInOrder([
        authenticatedNote,
        anonymousNote,
      ]));
    }

    {
      final queriedNotes = await osmapi.getNotesByBoundingBox(
        BoundingBox(0, 0, 0.3, 0.3),
        limit: 1,
      );
      expect(queriedNotes, equals([
        authenticatedNote
      ]));
    }

    // close note to check exclude parameter
    anonymousNote = await osmapi.closeNote(anonymousNote.id);
    {
      final queriedNotes = await osmapi.getNotesByBoundingBox(
        BoundingBox(0, 0, 0.3, 0.3),
        limit: 2,
      );
      // check for correct order
      expect(queriedNotes, equals([
        anonymousNote,
        authenticatedNote,
      ]));
    }

    {
      final queriedNotes = await osmapi.getNotesByBoundingBox(
        BoundingBox(0, 0, 0.3, 0.3),
        excludeClosedAfterPeriod: 0,
      );
      expect(queriedNotes, hasLength(greaterThanOrEqualTo(1)));
      expect(queriedNotes, contains(authenticatedNote));
      expect(queriedNotes, isNot(contains(anonymousNote)));
    }
  });

  // note action/comment tests

  test('check note actions', () async {
    final originalNote = await osmapi.createNote(
      latitude: 0.2,
      longitude: 0.2,
      text: 'test2',
    );

    // check comments
    var updatedNote = await osmapi.commentNote(originalNote.id, specialText);
        updatedNote = await osmapi.commentNote(originalNote.id, 'test');

    final commentA = OSMNoteComment(
      action: OSMNoteAction.commented,
      date: updatedNote.comments[1].date,
      text: specialText,
      user: testUser,
    );
    final commentB = OSMNoteComment(
      action: OSMNoteAction.commented,
      date: updatedNote.comments[2].date,
      text: 'test',
      user: testUser,
    );

    expect(updatedNote.closedAt, isNull);
    expect(updatedNote.isClosed, isFalse);
    expect(updatedNote.isOpen, isTrue);
    expect(updatedNote.isHidden, isFalse);
    expect(updatedNote.status, equals(OSMNoteStatus.open));
    expect(updatedNote.comments, equals([
      originalNote.comments.first,
      commentA,
      commentB,
    ]));

    // check note closing
    updatedNote = await osmapi.closeNote(originalNote.id);

    final closeComment = OSMNoteComment(
      action: OSMNoteAction.closed,
      date: updatedNote.closedAt!,
      text: '',
      user: testUser,
    );

    // ensure at least one second difference to previous date
    await Future.delayed(Duration(seconds: 1));

    expect(updatedNote.closedAt!.isBefore(DateTime.now()), isTrue);
    expect(updatedNote.isClosed, isTrue);
    expect(updatedNote.isOpen, isFalse);
    expect(updatedNote.isHidden, isFalse);
    expect(updatedNote.status, equals(OSMNoteStatus.closed));
    expect(updatedNote.comments, equals([
      originalNote.comments.first,
      commentA,
      commentB,
      closeComment,
    ]));

    // close already closed note and check for conflict error
    await expectLater(
      () => osmapi.closeNote(originalNote.id),
      throwsA(isA<OSMConflictException>()),
    );

    // check note reopening
    updatedNote = await osmapi.reopenNote(originalNote.id);

    final reopenComment = OSMNoteComment(
      action: OSMNoteAction.closed,
      date: updatedNote.comments[4].date,
      text: '',
      user: testUser,
    );

    expect(updatedNote.closedAt, isNull);
    expect(updatedNote.isClosed, isFalse);
    expect(updatedNote.isOpen, isTrue);
    expect(updatedNote.isHidden, isFalse);
    expect(updatedNote.status, equals(OSMNoteStatus.open));
    expect(updatedNote.comments, equals([
      originalNote.comments.first,
      commentA,
      commentB,
      closeComment,
      reopenComment,
    ]));

    // reopen already opened note and check for conflict error
    expect(
      () async => await osmapi.reopenNote(originalNote.id),
      throwsA(isA<OSMConflictException>()),
    );
  });

  // note query tests

  test('check for correct return of note queries', () async {
    // ensure at least one second difference to previous date
    await Future.delayed(Duration(seconds: 1));

    var noteA = await osmapi.createNote(
      latitude: 0.1,
      longitude: 0.1,
      text: specialText,
    );

    // used to exclude old nodes from previous runs and tests
    final startDate = noteA.createdAt;

    {
      final notes = await osmapi.queryNotes(
        searchTerm: specialText,
      );
      expect(notes, contains(noteA));
    }

    {
      final notes = await osmapi.queryNotes(
        uid: testUser.id,
      );
      expect(notes, contains(noteA));
    }

    {
      final notes = await osmapi.queryNotes(
        userName: testUser.name,
      );
      expect(notes, contains(noteA));
    }

    {
      final notes = await osmapi.queryNotes(
        searchTerm: specialText,
        uid: testUser.id,
      );
      expect(notes, contains(noteA));
    }

    {
      final notes = await osmapi.queryNotes(
        searchTerm: specialText,
        userName: testUser.name,
      );
      expect(notes, contains(noteA));
    }

    {
      final notes = await osmapi.queryNotes(
        searchTerm: specialText,
        userName: testUser.name,
        limit: 1,
      );
      expect(notes, equals([noteA]));
    }

    // add second note

    // ensure at least one second difference to previous date
    await Future.delayed(Duration(seconds: 1));
    var noteB = await osmapi.createNote(
      latitude: 0.2,
      longitude: 0.2,
      text: specialText,
    );

    {
      final notes = await osmapi.queryNotes(
        searchTerm: specialText,
        limit: 2,
      );
      expect(notes, equals([noteB, noteA]));
    }

    // ensure at least one second difference to previous date
    await Future.delayed(Duration(seconds: 1));
    noteB = await osmapi.closeNote(noteB.id);

    {
      final notes = await osmapi.queryNotes(
        searchTerm: specialText,
        excludeClosedAfterPeriod: 0,
      );
      expect(notes, contains(noteA));
      expect(notes, isNot(contains(noteB)));
    }

    {
      final notes = await osmapi.queryNotes(
        from: DateTime.now(),
      );
      expect(notes, isEmpty);
    }

    {
      final notes = await osmapi.queryNotes(
        from: DateTime.now().subtract(Duration(days: 1)),
      );
      expect(notes, containsAllInOrder([noteB, noteA]));
    }

    {
      final now = DateTime.now();
      final notes = await osmapi.queryNotes(
        from: now.subtract(Duration(hours: 24)),
        to: now.subtract(Duration(hours: 23)),
      );
      expect(notes, isNot(contains(noteA)));
      expect(notes, isNot(contains(noteB)));
    }

    {
      final notes = await osmapi.queryNotes(
        from: noteB.createdAt,
      );
      expect(notes, isNot(contains(noteA)));
      expect(notes, contains(noteB));
    }

    // test order and sorting

    {
      final notes = await osmapi.queryNotes(
        from: startDate,
        sortBy: OSMNoteSortProperty.createdAt,
        order: Order.descending,
      );
      expect(notes, equals([noteB, noteA]));
    }

    {
      final notes = await osmapi.queryNotes(
        from: startDate,
        sortBy: OSMNoteSortProperty.createdAt,
        order: Order.ascending,
      );
      expect(notes, equals([noteA, noteB]));
    }

    {
      final notes = await osmapi.queryNotes(
        from: startDate,
        sortBy: OSMNoteSortProperty.updatedAt,
        order: Order.descending,
      );
      expect(notes, equals([noteB, noteA]));
    }

    {
      final notes = await osmapi.queryNotes(
        from: startDate,
        sortBy: OSMNoteSortProperty.updatedAt,
        order: Order.ascending,
      );
      expect(notes, equals([noteA, noteB]));
    }

    // update note A
    // ensure at least one second difference to previous date
    await Future.delayed(Duration(seconds: 1));
    noteA = await osmapi.commentNote(noteA.id, 'test');

    {
      final notes = await osmapi.queryNotes(
        from: startDate,
        sortBy: OSMNoteSortProperty.updatedAt,
        order: Order.descending,
      );
      expect(notes, equals([noteA, noteB]));
    }

    {
      final notes = await osmapi.queryNotes(
        from: startDate,
        sortBy: OSMNoteSortProperty.updatedAt,
        order: Order.ascending,
      );
      expect(notes, equals([noteB, noteA]));
    }
  });
}
