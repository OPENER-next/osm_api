import 'package:osm_api/osm_api.dart';
import 'package:osm_api/src/osm_change.dart';
import 'package:test/test.dart';

void main() async {
  late OSMAPI osmapi;

  setUpAll(() async {
    osmapi = OSMAPI(
      baseUrl: 'http://127.0.0.1:3000/api/0.6',
      authentication: OAuth2(
        accessToken: 'DummyTestToken',
      ),
    );
  });


  test('test OSMChange toXML and fromXML methods', () async {
    final constructedChange = OSMChange(
      changesetId: 1,
      generator: 'Test1',
      version: '0.1'
    );
    final constructedChangeString = constructedChange.toXML().toString()
    // remove new lines
    .replaceAll('\n', '');

    expect(constructedChangeString, equalsIgnoringWhitespace('<osmChange version="0.1" generator="Test1"></osmChange>'));

    const tags = {
      'test': 'value'
    };

    const nodeIds = [1,2];


    final members = [
      OSMMember(
        type: OSMElementType.node,
        ref: 1,
        role: 'inner',
      ),
      OSMMember(
        type: OSMElementType.way,
        ref: 1,
        role: 'inner',
      ),
      OSMMember(
        type: OSMElementType.relation,
        ref: 1,
        role: 'inner',
      )
    ];

    // create

    constructedChange.create.nodes.add(
      OSMNode(
        12, 14,
        tags: tags,
        id: 1,
        version: 1
      )
    );
    constructedChange.create.ways.add(
      OSMWay(
        nodeIds,
        tags: tags,
        id: 1,
        version: 1
      )
    );
    constructedChange.create.relations.add(
      OSMRelation(
        members,
        tags: tags,
        id: 1,
        version: 1
      )
    );

    // modify

    constructedChange.modify.nodes.add(
      OSMNode(
        12, 14,
        tags: tags,
        id: 2,
        version: 4
      )
    );
    constructedChange.modify.ways.add(
      OSMWay(
        nodeIds,
        tags: tags,
        id: 2,
        version: 4
      )
    );
    constructedChange.modify.relations.add(
      OSMRelation(
        members,
        tags: tags,
        id: 2,
        version: 4
      )
    );

    // delete

    constructedChange.delete.nodes.add(
      OSMNode(
        12, 14,
        tags: tags,
        id: 3,
        version: 4
      )
    );
    constructedChange.delete.ways.add(
      OSMWay(
        nodeIds,
        tags: tags,
        id: 3,
        version: 4
      )
    );
    constructedChange.delete.relations.add(
      OSMRelation(
        members,
        tags: tags,
        id: 3,
        version: 4
      )
    );

    final c2String = constructedChange.toXML().toString()
    // remove new lines
    .replaceAll('\n', '');

    const expectedXMLString =
    '<osmChange version="0.1" generator="Test1">'
      '<create>'
        '<node id="1" version="1" lat="12.0000000" lon="14.0000000" changeset="1">'
          '<tag k="test" v="value"/>'
        '</node>'
      '</create>'
      '<create>'
        '<way id="1" version="1" changeset="1">'
          '<nd ref="1"/>'
          '<nd ref="2"/>'
          '<tag k="test" v="value"/>'
        '</way>'
      '</create>'
      '<create>'
        '<relation id="1" version="1" changeset="1">'
          '<member type="node" ref="1" role="inner"/>'
          '<member type="way" ref="1" role="inner"/>'
          '<member type="relation" ref="1" role="inner"/>'
          '<tag k="test" v="value"/>'
        '</relation>'
      '</create>'

      '<modify>'
        '<node id="2" version="4" lat="12.0000000" lon="14.0000000" changeset="1">'
          '<tag k="test" v="value"/>'
        '</node>'
      '</modify>'
      '<modify>'
        '<way id="2" version="4" changeset="1">'
          '<nd ref="1"/>'
          '<nd ref="2"/>'
          '<tag k="test" v="value"/>'
        '</way>'
      '</modify>'
      '<modify>'
        '<relation id="2" version="4" changeset="1">'
          '<member type="node" ref="1" role="inner"/>'
          '<member type="way" ref="1" role="inner"/>'
          '<member type="relation" ref="1" role="inner"/>'
          '<tag k="test" v="value"/>'
        '</relation>'
      '</modify>'

      '<delete>'
        '<node id="3" version="4" lat="12.0000000" lon="14.0000000" changeset="1"/>'
      '</delete>'
      '<delete>'
        '<way id="3" version="4" changeset="1"/>'
      '</delete>'
      '<delete>'
        '<relation id="3" version="4" changeset="1"/>'
      '</delete>'
    '</osmChange>';

    // test xml stringification

    expect(c2String, equalsIgnoringWhitespace(expectedXMLString));

    // test parsing

    final parsedChange = OSMChange.fromXMLString(c2String);

    expect(parsedChange.changesetId, equals(1));
    expect(parsedChange.version, equals('0.1'));
    expect(parsedChange.generator, equals('Test1'));

    expect(parsedChange.create.elements, equals(constructedChange.create.elements));
    expect(parsedChange.modify.elements, equals(constructedChange.modify.elements));

    // deleted elements won't contain any tags, node refs, members or lat/lon attributes
    // therefore only compare version and id
    final deletedElementsFromConstructed = constructedChange.delete.elements.toList();
    final deletedElementsFromParsed = parsedChange.delete.elements.toList();
    for (var i = 0; i < deletedElementsFromConstructed.length; i++) {
      expect(deletedElementsFromConstructed[i].id, equals(deletedElementsFromParsed[i].id));
      expect(deletedElementsFromConstructed[i].version, equals(deletedElementsFromParsed[i].version));
      expect(deletedElementsFromConstructed[i].type, equals(deletedElementsFromParsed[i].type));
      expect(deletedElementsFromParsed[i].tags, isEmpty);
    }
  });


  test('test API getChangesetChanges method', () async {
    const tags = {
      'amenity': 'test'
    };

    const tagsMod = {
      'amenity': 'toilet'
    };

    final changeset01Id = await osmapi.createChangeset({});

    // create example elements

    final node1 = await osmapi.createElement(OSMNode(1, 1, tags: tags), changeset01Id);
    final node2 = await osmapi.createElement(OSMNode(1, 2, tags: tags), changeset01Id);
    final way = await osmapi.createElement(OSMWay([node1.id, node2.id], tags: tags), changeset01Id);
    final member1 = OSMMember(
      type: OSMElementType.node,
      ref: node1.id,
    );
    final member2 = OSMMember(
      type: OSMElementType.way,
      ref: way.id,
    );
    final relation = await osmapi.createElement(OSMRelation([member1, member2], tags: tags), changeset01Id);

    // modify example elements

    final node1Mod = await osmapi.updateElement(
      OSMNode(node1.lat, 10, id: node1.id, version: node1.version, tags: node1.tags), changeset01Id
    );
    final node2Mod = await osmapi.updateElement(
      OSMNode(node2.lat, node2.lon, id: node2.id, version: node2.version, tags: tagsMod), changeset01Id
    );
    final wayMod = await osmapi.updateElement(
      OSMWay([node1Mod.id, node2Mod.id], id: way.id, version: way.version, tags: tagsMod), changeset01Id
    );
    final relationMod = await osmapi.updateElement(
      OSMRelation(relation.members, id: relation.id, version: relation.version, tags: tagsMod), changeset01Id
    );

    // delete example elements

    final relationDel = await osmapi.deleteElement(
      OSMRelation(relationMod.members, id: relationMod.id, version: relationMod.version, tags: relationMod.tags), changeset01Id
    );
    final wayDel = await osmapi.deleteElement(
      OSMWay([node1Mod.id, node2Mod.id], id: wayMod.id, version: wayMod.version, tags: wayMod.tags), changeset01Id
    );
    final node2Del = await osmapi.deleteElement(
      OSMNode(node2Mod.lat, node2Mod.lon, id: node2Mod.id, version: node2Mod.version, tags: node2Mod.tags), changeset01Id
    );

    await osmapi.closeChangeset(changeset01Id);

    // get and test osm changes

    final changes = await osmapi.getChangesetChanges(changeset01Id);

    expect(changes.version, '0.6');
    expect(changes.generator, 'OpenStreetMap server');
    expect(changes.changesetId, changeset01Id);

    expect(changes.create.nodes, containsAll([node1, node2]));
    expect(changes.create.ways.single, equals(way));
    expect(changes.create.relations.single, equals(relation));

    expect(changes.modify.nodes, containsAll([node1Mod, node2Mod]));
    expect(changes.modify.ways.single, equals(wayMod));
    expect(changes.modify.relations.single, equals(relationMod));


    // cannot compare OSMNode directly if NaN, because NaN == NaN is false by definition
    expect(changes.delete.nodes.single.id, equals(node2Del.id));
    expect(changes.delete.nodes.single.version, equals(node2Del.version));
    expect(changes.delete.nodes.single.lat, isNaN);
    expect(changes.delete.nodes.single.lon, isNaN);

    expect(changes.delete.ways.single, equals(
      OSMWay(
        [],
        id: wayDel.id,
        version: wayDel.version
      )
    ));
    expect(changes.delete.relations.single, equals(
      OSMRelation(
        [],
        id: relationDel.id,
        version: relationDel.version
      )
    ));
  });
}
