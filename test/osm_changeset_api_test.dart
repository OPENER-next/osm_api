import 'package:osm_api/osm_api.dart';
import 'package:test/test.dart';

void main() async {
  late OSMAPI osmapi;

  setUpAll(() async {
    osmapi = OSMAPI(
      baseUrl: 'http://127.0.0.1:3000/api/0.6',
      authentication: BasicAuth(
        username: 'testuser',
        password: 'testpass'
      )
    );
  });

  test('check for correct return of createChangeset() and getChangeset()', () async {
    var tags = {
      'created_by': 'Opener Next',
      'comment': 'Just adding some streetnames'
    };

    var changesetId = await osmapi.createChangeset(tags);

    // add example node so changeset will generate a bbox
    var node = await osmapi.createElement(OSMNode(1, 1), changesetId);

    var changeset = await osmapi.getChangeset(changesetId);

    expect(changeset.id, greaterThan(0));
    expect(changeset.tags, equals(tags));
    expect(changeset.createdAt, isA<DateTime>());
    expect(changeset.closedAt, isNull);
    expect(changeset.user.name, 'testuser');
    expect(changeset.changesCount, equals(1));
    expect(changeset.commentsCount, isZero);
    expect(changeset.bbox?.contains(node.lat, node.lon), isTrue);
    expect(changeset.isOpen, isTrue);
    expect(changeset.isClosed, isFalse);
    expect(changeset.discussion, isNull);
  });


  test('check if closeChangeset() and addCommentToChangeset() works by getChangeset() with discussions', () async {
    var changesetId = await osmapi.createChangeset({
      'created_by': 'Opener Next',
      'comment': 'Just adding some streetnames'
    });

    await osmapi.closeChangeset(changesetId);

    // changeset needs to be closed to add comments
    await osmapi.addCommentToChangeset(changesetId, 'my comment');

    var changeset = await osmapi.getChangeset(changesetId, true);

    expect(changeset.discussion?.first.text, equals('my comment'));
    expect(changeset.discussion?.first.user.name, equals('testuser'));
    expect(changeset.closedAt, isA<DateTime>());
    expect(changeset.commentsCount, equals(1));
    expect(changeset.isOpen, isFalse);
    expect(changeset.isClosed, isTrue);
  });


  test('check if updateChangeset() works correctly', () async {
    var changesetId = await osmapi.createChangeset({
      'created_by': 'Opener Next',
      'comment': 'Just adding some streetnames'
    });

    var newTags = {
      'created_by': 'Opener Next 2',
      'test': '123',
    };
    var changeset = await osmapi.updateChangeset(changesetId, newTags);

    expect(changeset.tags, equals(newTags));
  });


  test('check for correct return of queryChangesets()', () async {
    var dateTime = DateTime.now();

    var changesetId01 = await osmapi.createChangeset({
      'created_by': 'Opener Next',
      'comment': 'Just adding some streetnames'
    });
    var changesetId02 = await osmapi.createChangeset({
      'created_by': 'Opener Next',
      'comment': 'Just adding some streetnames'
    });

    await osmapi.createElement(
      OSMNode(10, 20, tags: {'key': 'value'}),
      changesetId01
    );

    await osmapi.closeChangeset(changesetId01);

    // query changesets with get for later comparison
    var changeset01 = await osmapi.getChangeset(changesetId01);
    var changeset02 = await osmapi.getChangeset(changesetId02);

    var query01 = await osmapi.queryChangesets(userName: 'testuser', closedAfter: dateTime);
    var query02 = await osmapi.queryChangesets(userName: 'testuser', open: true);
    var query03 = await osmapi.queryChangesets(userName: 'testuser', closedAfter: dateTime, open: false);
    var query04 = await osmapi.queryChangesets(userName: 'testuser', closedAfter: dateTime, bbox: BoundingBox(
      19.999, 9.999, 20.001, 10.001
    ));
    var query05 = await osmapi.queryChangesets(userName: 'testuser', closedAfter: dateTime, createdBefore: dateTime.add(Duration(seconds: 1)), open: false);
    var query06 = await osmapi.queryChangesets(changesets: [changesetId01, changesetId02]);

    expect(query01, containsAll([changeset01, changeset02]));
    expect(query02.first, changeset02);
    expect(query03, equals([changeset01]));
    expect(query04.first, changeset01);
    expect(query05, equals([changeset01]));
    expect(query06, equals([changeset02, changeset01]));
  });


  test('check if subscribeToChangeset() and unsubscribeFromChangeset() methods exist', () async {
    var changesetId = await osmapi.createChangeset({
      'created_by': 'Opener Next',
      'comment': 'Just adding some streetnames'
    });

    await osmapi.closeChangeset(changesetId);

    // user is automatically subscribed to its changeset

    await osmapi.unsubscribeFromChangeset(changesetId);
    await osmapi.subscribeToChangeset(changesetId);
  });
}