import 'package:osm_api/osm_api.dart';
import 'package:test/test.dart';

void main() async {
  late final OSMAPI osmapi;

  setUpAll(() async {
    osmapi = OSMAPI(
      baseUrl: 'http://127.0.0.1:3000/api/0.6',
      authentication: OAuth2(
        accessToken: 'DummyTestToken',
      ),
    );
  });

  test('check for correct return of createChangeset() and getChangeset()', () async {
    final tags = {
      'created_by': 'Opener Next',
      'comment': 'Just adding some streetnames',
      'test_special_characters': '<>&"\'',
    };

    final changesetId = await osmapi.createChangeset(tags);

    // add example node so changeset will generate a bbox
    final node = await osmapi.createElement(OSMNode(1, 1), changesetId);

    final changeset = await osmapi.getChangeset(changesetId);

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

    final changeset = await osmapi.getChangeset(changesetId, true);

    expect(changeset.discussion?.first.text, equals('my comment'));
    expect(changeset.discussion?.first.user.name, equals('testuser'));
    expect(changeset.closedAt, isA<DateTime>());
    expect(changeset.commentsCount, equals(1));
    expect(changeset.isOpen, isFalse);
    expect(changeset.isClosed, isTrue);
  });


  test('check if updateChangeset() works correctly', () async {
    final changesetId = await osmapi.createChangeset({
      'created_by': 'Opener Next',
      'comment': 'Just adding some streetnames'
    });

    final newTags = {
      'created_by': 'Opener Next 2',
      'test': '123',
    };
    final changeset = await osmapi.updateChangeset(changesetId, newTags);

    expect(changeset.tags, equals(newTags));
  });


  test('check for correct return of queryChangesets()', () async {
    // ensure at least one second difference to previous date
    await Future.delayed(Duration(seconds: 1));
    final beforeChange = DateTime.now();

    final changesetId01 = await osmapi.createChangeset({
      'created_by': 'Opener Next',
      'comment': 'Just adding some streetnames'
    });
    final changesetId02 = await osmapi.createChangeset({
      'created_by': 'Opener Next',
      'comment': 'Just adding some streetnames'
    });

    await osmapi.createElement(
      OSMNode(10, 20, tags: {'key': 'value'}),
      changesetId01
    );

    await osmapi.closeChangeset(changesetId01);

    final afterChange = DateTime.now().add(Duration(seconds: 1));

    // query changesets with get for later comparison
    final changeset01 = await osmapi.getChangeset(changesetId01);
    final changeset02 = await osmapi.getChangeset(changesetId02);

    final query01 = await osmapi.queryChangesets(userName: 'testuser', closedAfter: beforeChange);
    final query02 = await osmapi.queryChangesets(userName: 'testuser', open: true);
    final query03 = await osmapi.queryChangesets(userName: 'testuser', closedAfter: beforeChange, open: false);
    final query04 = await osmapi.queryChangesets(userName: 'testuser', closedAfter: beforeChange, bbox: BoundingBox(
      19.999, 9.999, 20.001, 10.001
    ));
    final query05 = await osmapi.queryChangesets(userName: 'testuser', closedAfter: beforeChange, createdBefore: afterChange, open: false);
    final query06 = await osmapi.queryChangesets(changesets: [changesetId01, changesetId02]);

    expect(query01, containsAllInOrder([changeset02, changeset01]));
    expect(query02.first, equals(changeset02));
    expect(query03, contains(changeset01));
    expect(query04.first, equals(changeset01));
    expect(query05, contains(changeset01));
    expect(query06, equals([changeset02, changeset01]));
  });


  test('check if subscribeToChangeset() and unsubscribeFromChangeset() methods exist', () async {
    final changesetId = await osmapi.createChangeset({
      'created_by': 'Opener Next',
      'comment': 'Just adding some streetnames'
    });

    await osmapi.closeChangeset(changesetId);

    // user is automatically subscribed to its changeset

    await osmapi.unsubscribeFromChangeset(changesetId);
    await osmapi.subscribeToChangeset(changesetId);
  });
}
