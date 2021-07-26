import 'package:osmapi/osm-api.dart';
import 'package:test/test.dart';

void main() async {
  late OSMAPI osmapi;
  late int changesetId;
  late List<OSMNode> nodes;
  late List<OSMWay> ways;
  late OSMRelation relation;

  setUpAll(() async {
    osmapi = OSMAPI(
      baseUrl: 'http://127.0.0.1:3000/api/0.6',
      authentication: BasicAuth(
        username: 'testuser',
        password: 'testpass'
      )
    );

    changesetId = await osmapi.createChangeset({
      'created_by': 'Opener Next',
      'comment': 'Just adding some streetnames'
    });

    // create some elements

    nodes = await Future.wait([
      osmapi.createElement(
        OSMNode(10, 20, tags: {'key': 'value'}),
        changesetId
      ),
      osmapi.createElement(
        OSMNode(30, 40),
        changesetId
      ),
      osmapi.createElement(
        OSMNode(80, 60),
        changesetId
      ),
      osmapi.createElement(
        OSMNode(40, 100),
        changesetId
      )
    ]);

    ways = await Future.wait([
      osmapi.createElement(
        OSMWay([nodes[0].id, nodes[1].id]),
        changesetId
      ),
      osmapi.createElement(
        OSMWay([nodes[1].id, nodes[2].id, nodes[3].id], tags: {'key': 'value'}),
        changesetId
      ),
    ]);

    relation = await osmapi.createElement(
      OSMRelation([
        OSMMember.fromOSMElement(ways[0]),
        OSMMember.fromOSMElement(nodes[0]),
        OSMMember.fromOSMElement(nodes[1])
      ]),
      changesetId
    );
  });

  test('compare single local node and getNode()', () async {
    var serverNode = await osmapi.getNode(nodes[0].id);
    expect(serverNode, equals(nodes[0]));
  });

  test('compare single local way and getWay()', () async {
    var serverWay = await osmapi.getWay(ways[0].id);
    expect(serverWay, equals(ways[0]));
  });

  test('compare single local relation and getRelation()', () async {
    var serverRelation = await osmapi.getRelation(relation.id);
    expect(serverRelation, equals(relation));
  });

  // update some elements
  // IMPORTANT: this updates the previously created local elements
  // thus this affects the tests below

  test('compare local nodes and getNodes() after update', () async {
    nodes[0].tags['one'] = 'more';
    await osmapi.updateElement(nodes[0], changesetId);

    nodes[1].lat = 23;
    await osmapi.updateElement(nodes[1], changesetId);

    var serverNodes = await osmapi.getNodes(
      nodes.map((node) => node.id).toList()
    );
    expect(serverNodes, equals(nodes));
  });

  test('compare local ways and getWays() after update', () async {
    ways[0].tags['one'] = 'more';
    await osmapi.updateElement(ways[0], changesetId);

    ways[1].nodeIds.add(nodes[0].id);
    await osmapi.updateElement(ways[1], changesetId);

    var serverWays = await osmapi.getWays(
      ways.map((way) => way.id).toList()
    );
    expect(serverWays, equals(ways));
  });

  test('compare local relation and getRelations() after update', () async {
    relation.members.add(OSMMember.fromOSMElement(ways[1]));
    await osmapi.updateElement(relation, changesetId);

    var serverRelation = await osmapi.getRelations(
      [relation.id]
    );
    expect(serverRelation, equals([relation]));
  });

  // get elements by version

  test('compare local node and getNode() with version', () async {
    var serverNodeV1 = await osmapi.getNode(nodes[0].id, 1);
    expect(serverNodeV1, isNot(equals(nodes[0])));

    var serverNodeV2 = await osmapi.getNode(nodes[0].id, 2);
    expect(serverNodeV2, equals(nodes[0]));
  });

  test('compare local way and getWay() with version', () async {
    var serverWayV1 = await osmapi.getWay(ways[0].id, 1);
    expect(serverWayV1, isNot(equals(ways[0])));

    var serverWayV2 = await osmapi.getWay(ways[0].id, 2);
    expect(serverWayV2, equals(ways[0]));
  });

  test('compare local relation and getRelation() with version', () async {
    var serverRelationV1 = await osmapi.getRelation(relation.id, 1);
    expect(serverRelationV1, isNot(equals(relation)));

    var serverRelationV2 = await osmapi.getRelation(relation.id, 2);
    expect(serverRelationV2, equals(relation));
  });

  // get multiple elements by version

  test('compare local nodes with getNodesWithVersion()', () async {
    var serverNodes = await osmapi.getNodesWithVersion(
      Map<int, int>.fromIterable(nodes, key: (e) => e.id, value: (e) => e.version)
    );
    expect(serverNodes, equals(nodes));
  });

  test('compare local ways with getWaysWithVersion()', () async {
    var serverWays = await osmapi.getWaysWithVersion(
      Map<int, int>.fromIterable(ways, key: (e) => e.id, value: (e) => e.version)
    );
    expect(serverWays, equals(ways));
  });

  test('compare local relation with getRelationsWithVersion()', () async {
    var serverRelations = await osmapi.getRelationsWithVersion(
      {relation.id: relation.version}
    );
    expect(serverRelations, equals([relation]));
  });

  // check get full way and relation

  test('compare local way and child elements with getFullWay()', () async {
    var elementBundle = await osmapi.getFullWay(ways[0].id);
    expect(elementBundle.nodes, unorderedEquals({ nodes[0], nodes[1] }));
    expect(elementBundle.ways, unorderedEquals({ ways[0] }));
    expect(elementBundle.relations, isEmpty);
  });

  test('compare local relation and child elements with getFullRelation()', () async {
    var elementBundle = await osmapi.getFullRelation(relation.id);
    expect(elementBundle.nodes, unorderedEquals({ nodes[0], nodes[1], nodes[2], nodes[3] }));
    expect(elementBundle.ways, unorderedEquals({ ways[0], ways[1] }));
    expect(elementBundle.relations, unorderedEquals({ relation }));
  });

  // check get by bbox

  test('compare local elements and elements from BBox', () async {
    // try to get the first node by bouding box
    // this will also return every way element and relation that the node belongs to
    // ways will also contain their nodes
    var elementBundle = await osmapi.getElementsByBoundingBox(
      BoundingBox(19.999, 9.999, 20.001, 10.001)
    );
    // use contains instead of equals to prevent local test from failing, because they might return additional elements
    // e.g. elements from previous/older test runs
    expect(elementBundle.nodes, containsAll({ nodes[0], nodes[1], nodes[2], nodes[3] }));
    expect(elementBundle.ways, containsAll({ ways[0], ways[1] }));
    expect(elementBundle.relations, containsAll({ relation }));
  });

  // check get ways by node

  test('check for correct return of getWaysWithNode()', () async {
    // nodes[1] should be present in all ways
    var serverWays = await osmapi.getWaysWithNode(nodes[1].id);
    expect(serverWays, unorderedEquals(ways));
  });

  // check get relations by element

  test('check for correct return of getRelationsWithNode()', () async {
    var serverRelations = await osmapi.getRelationsWithNode(nodes[0].id);
    expect(serverRelations, equals([relation]));
  });

  test('check for correct return of getRelationsWithWay()', () async {
    var serverRelations = await osmapi.getRelationsWithWay(ways[0].id);
    expect(serverRelations, equals([relation]));
  });

  test('check for correct return of getRelationsWithNode()', () async {
    var serverRelations = await osmapi.getRelationsWithRelation(relation.id);
    expect(serverRelations.isEmpty, true);
  });

  // check get element history

  test('check for correct return of getNodeHistory()', () async {
    var nodeHistory = await osmapi.getNodeHistory(nodes[0].id);
    var nodeHistoryList = nodeHistory.toList();
    expect(nodeHistoryList.length == 2, true);
    // check if newest element equals local element
    expect(nodeHistoryList.last, equals(nodes[0]));
  });

  test('check for correct return of getWayHistory()', () async {
    var wayHistory = await osmapi.getWayHistory(ways[0].id);
    var wayHistoryList = wayHistory.toList();
    expect(wayHistoryList.length == 2, true);
    // check if newest element equals local element
    expect(wayHistoryList.last, equals(ways[0]));
  });

  test('check for correct return of getRelationHistory()', () async {
    var relationHistory = await osmapi.getRelationHistory(relation.id);
    var relationHistoryList = relationHistory.toList();
    expect(relationHistoryList.length == 2, true);
    // check if newest element equals local element
    expect(relationHistoryList.last, equals(relation));
  });

  // delete some elements and try to get them afterwards

  test('check for correct error on get for deleted node', () async {
    // delete all elements that contain the nodes[0]
    // otherwise an error is thrown if an element still depends on another
    await osmapi.deleteElement(relation, changesetId);
    await osmapi.deleteElement(ways[0], changesetId);
    await osmapi.deleteElement(ways[1], changesetId);
    await osmapi.deleteElement(nodes[0], changesetId);

    try {
      await osmapi.getNode(nodes[0].id);
      fail('Exception for deleted element not thrown');
    } on OSMAPIException catch (e) {
      expect(e.errorCode, equals(410));
      expect(e,  isA<OSMGoneException>());
    }
  });
}