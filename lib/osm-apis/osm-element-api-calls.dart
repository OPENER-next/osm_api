import 'dart:convert';
import 'package:osmapi/commons/bounding-box.dart';
import 'package:osmapi/elements.dart';
import 'osm-api-base.dart';

/**
 * A mixin containing methods for uploading, manipulating and retrieving OSM elements from and to the server.
 */
mixin OSMElementAPICalls on OSMAPIBase {


  /**
   * A function for uploading an [OSMElement] to the server.
   *
   * This updates the [OSMElement.id] and [OSMElement.version] of the given [OSMElement].
   * Returns the updated [OSMElement] as a [Future].
   */
  Future<T> createElement<T extends OSMElement>(T element, int changeset) async {
    var additionalAttributes = '';
    final type = element.type.toShortString();

    if (element is OSMNode) {
      additionalAttributes += 'lat="${element.lat}" lon="${element.lon}"';
    }

    // returns element id
    final response = await sendRequest(
      '/$type/create',
      type: 'PUT',
      body:
        '<osm>'
          '<$type changeset="$changeset" $additionalAttributes>'
            '${element.bodyToXML()}'
          '</$type>'
        '</osm>'
    );

    // set server assigned id
    element.id = int.parse(response.data);
    // always set starting version
    element.version = 1;

    return element;
  }


  /**
   * A function for updating an [OSMElement] on the server.
   *
   * This updates the [OSMElement.version] of the given [OSMElement].
   * Returns the updated [OSMElement] as a [Future].
   */
  Future<T> updateElement<T extends OSMElement>(T element, int changeset) async {
    var additionalAttributes = '';
    final type = element.type.toShortString();

    if (element is OSMNode) {
      additionalAttributes += 'lat="${element.lat}" lon="${element.lon}"';
    }

    // returns new version number
    final response = await sendRequest(
      '/$type/${element.id}',
      type: 'PUT',
      body:
        '<osm>'
          '<$type changeset="$changeset" version="${element.version}" id="${element.id}" $additionalAttributes>'
            '${element.bodyToXML()}'
          '</$type>'
        '</osm>'
    );

    // set new server assigned version
    element.version = int.parse(response.data);

    return element;
  }


  /**
   * A function for deleting an [OSMElement] from the server.
   *
   * This updates the [OSMElement.version] of the given [OSMElement].
   * Returns the updated [OSMElement] as a [Future].
   */
  Future<T> deleteElement<T extends OSMElement>(T element, int changeset) async {
    var additionalAttributes = '';
    final type = element.type.toShortString();

    if (element is OSMNode) {
      additionalAttributes += 'lat="${element.lat}" lon="${element.lon}"';
    }

    // returns new version number
    final response = await sendRequest(
      '/$type/${element.id}',
      type: 'DELETE',
      body:
        '<osm>'
          '<$type changeset="$changeset" version="${element.version}" id="${element.id}" $additionalAttributes/>'
        '</osm>'
    );

    // set new server assigned version
    element.version = int.parse(response.data);

    return element;
  }


  /**
   * A function for getting an [OSMNode] from the server by its id.
   *
   * Optionally a specific version of the node can be requested by using the [version] parameter.
   * Returns the [OSMNode] as a [Future].
   */
  Future<OSMNode> getNode(int id, [ int? version ]) {
    final versionParameter = version == null ? '' : '/$version';
    return _getElement<OSMNode>('/node/$id$versionParameter');
  }


  /**
   * A function for getting an [OSMWay] from the server by its id.
   *
   * Optionally a specific version of the way can be requested by using the [version] parameter.
   * Returns the [OSMWay] as a [Future].
   */
  Future<OSMWay> getWay(int id, [ int? version ]) {
    final versionParameter = version == null ? '' : '/$version';
    return _getElement<OSMWay>('/way/$id$versionParameter');
  }


  /**
   * A function for getting an [OSMRelation] from the server by its id.
   *
   * Optionally a specific version of the relation can be requested by using the [version] parameter.
   * Returns the [OSMRelation] as a [Future].
   */
  Future<OSMRelation> getRelation(int id, [ int? version ]) {
    final versionParameter = version == null ? '' : '/$version';
    return _getElement<OSMRelation>('/relation/$id$versionParameter');
  }


  /**
   * A function for getting an [OSMElement] from the server by its type and a request url.
   * The generic type must be set to [OSMNode], [OSMWay] or [OSMRelation]
   *
   * Returns the typed [OSMElement] as a [Future].
   */
  Future<T> _getElement<T extends OSMElement>(String request) async {
    assert(T != OSMElement);

    // returns element as json
    final response = await sendRequest(request, headers: const { 'Accept': 'application/json' });
    // parse json
    final jsonData = json.decode(response.data);
    // get single element
    final jsonObject = jsonData['elements'][0];

    switch (T) {
      case OSMNode:
        return OSMNode.fromJSONObject(jsonObject) as T;

      case OSMWay:
        return OSMWay.fromJSONObject(jsonObject) as T;

      case OSMRelation:
        return OSMRelation.fromJSONObject(jsonObject) as T;

      default:
        throw('Got unsupported OSMElement type.');
    }
  }


  /**
   * A function for getting multiple [OSNode]s from the server by their ids.
   *
   * Returns a [Future] with a lazy [Iterable] of [OSMNode]s.
   */
  Future<Iterable<OSMNode>> getNodes(List<int> ids) {
    return _getElements<OSMNode>('/nodes/?nodes=${ids.join(',')}');
  }


  /**
   * A function for getting multiple [OSMWay]s from the server by their ids.
   *
   * Returns a [Future] with a lazy [Iterable] of [OSMWay]s.
   */
  Future<Iterable<OSMWay>> getWays(List<int> ids) {
    return _getElements<OSMWay>('/ways/?ways=${ids.join(',')}');
  }


  /**
   * A function for getting multiple [OSMRelation]s from the server by their ids.
   *
   * Returns a [Future] with a lazy [Iterable] of [OSMRelation]s.
   */
  Future<Iterable<OSMRelation>> getRelations(List<int> ids) {
    return _getElements<OSMRelation>('/relations/?relations=${ids.join(',')}');
  }


  /**
   * A function for getting a way with all its child nodes as an [OSMElementBundle] by ids.
   *
   * Returns a [Future] with a [OSMElementBundle]
   */
  Future<OSMElementBundle> getFullWay(int id) async {
    final elements = await _getElements('/way/$id/full');
    return OSMElementBundle(elements);
  }


  /**
   * A function for getting a relations with all its child elements as an [OSMElementBundle] by ids.
   * The nodes of child ways will also be retrieved.
   * Read more here: https://wiki.openstreetmap.org/wiki/API_v0.6#Full:_GET_.2Fapi.2F0.6.2F.5Bway.7Crelation.5D.2F.23id.2Ffull
   *
   * Returns a [Future] with a [OSMElementBundle]
   */
  Future<OSMElementBundle> getFullRelation(int id) async {
    final elements = await _getElements('/relation/$id/full');
    return OSMElementBundle(elements);
  }


  /**
   * A function for getting multiple [OSMNode]s from the server by their ids and version numbers.
   *
   * To get the latest version of an element set the version number to [null].
   * Returns a [Future] with a lazy [Iterable] of [OSMNode]s.
   *
   * Example:
   * ```
   * osmapi.getNodsWithVersion({ 34432: 3, 4554: 1, 32122: null, 43443: null });
   * ```
   */
  Future<Iterable<OSMNode>> getNodesWithVersion(Map<int, int?> idVersionMap) {
    return _getElementsWithVersion<OSMNode>('/nodes?nodes=', idVersionMap);
  }


  /**
   * A function for getting multiple [OSMWay]s from the server by their ids and version numbers.
   *
   * To get the latest version of an element set the version number to [null].
   * Returns a [Future] with a lazy [Iterable] of [OSMElement]s.
   *
   * Example:
   * ```
   * osmapi.getWaysWithVersion({ 34432: 3, 4554: 1, 32122: null, 43443: null });
   * ```
   */
  Future<Iterable<OSMWay>> getWaysWithVersion(Map<int, int?> idVersionMap) {
    return _getElementsWithVersion<OSMWay>('/ways?ways=', idVersionMap);
  }


  /**
   * A function for getting multiple [OSMRelation]s from the server by their ids and version numbers.
   *
   * To get the latest version of an element set the version number to [null].
   * Returns a [Future] with a lazy [Iterable] of [OSMRelation]s.
   *
   * Example:
   * ```
   * osmapi.getRelationsWithVersion({ 34432: 3, 4554: 1, 32122: null, 43443: null });
   * ```
   */
  Future<Iterable<OSMRelation>> getRelationsWithVersion(Map<int, int?> idVersionMap) {
    return _getElementsWithVersion<OSMRelation>('/relations?relations=', idVersionMap);
  }


  /**
   * A function for getting multiple [OSMElement]s of the same type from the server by their ids and version numbers.
   * The generic type must be set to [OSMNode], [OSMWay] or [OSMRelation]
   *
   * To get the latest version of an element set the version number to [null].
   * Returns a [Future] with a lazy [Iterable] of typed [OSMElement]s.
   */
  Future<Iterable<T>> _getElementsWithVersion<T extends OSMElement>(String request, Map<int, int?> idVersionMap) {
    var elementList = '';

    idVersionMap.forEach((id, version) {
      elementList += elementList.isEmpty ? '$id' : ',$id';
      if (version != null) {
        elementList += 'v$version';
      }
    });

    return _getElements<T>(request + elementList);
  }


  /**
   * A function for retrieving all [OSMWay]s from the server that contain a node with the given [id].
   *
   * Returns a [Future] with a lazy [Iterable] of [OSMWay]s.
   */
  Future<Iterable<OSMWay>> getWaysWithNode(int id) {
    return _getElements<OSMWay>('/node/$id/ways');
  }


  /**
   * A function for retrieving all [OSMRelation]s from the server that contain a node with the given [id].
   *
   * Returns a [Future] with a lazy [Iterable] of [OSMRelation]s.
   */
  Future<Iterable<OSMRelation>> getRelationsWithNode(int id) {
    return _getElements<OSMRelation>('/node/$id/relations');
  }


  /**
   * A function for retrieving all [OSMRelation]s from the server that contain a way with the given [id].
   *
   * Returns a [Future] with a lazy [Iterable] of [OSMRelation]s.
   */
  Future<Iterable<OSMRelation>> getRelationsWithWay(int id) {
    return _getElements<OSMRelation>('/way/$id/relations');
  }


  /**
   * A function for retrieving all [OSMRelation]s from the server that contain a relation with the given [id].
   *
   * Returns a [Future] with a lazy [Iterable] of [OSMRelation]s.
   */
  Future<Iterable<OSMRelation>> getRelationsWithRelation(int id) {
    return _getElements<OSMRelation>('/relation/$id/relations');
  }


  /**
   * A function for getting all versions of one [OSMNode] from the server by its [id].
   *
   * The elements are returned in ascending order by their version number.
   * This means the oldest version is the first and the newest version the last element in the returned [Iterable].
   * Returns a [Future] with a lazy [Iterable] of [OSMNode]s.
   */
  Future<Iterable<OSMNode>> getNodeHistory(int id) {
    return _getElements<OSMNode>('/node/$id/history');
  }


  /**
   * A function for getting all versions of one [OSMWay] from the server by its [id].
   *
   * The elements are returned in ascending order by their version number.
   * This means the oldest version is the first and the newest version the last element in the returned [Iterable].
   * Returns a [Future] with a lazy [Iterable] of [OSMWay]s.
   */
  Future<Iterable<OSMWay>> getWayHistory(int id) {
    return _getElements<OSMWay>('/way/$id/history');
  }


  /**
   * A function for getting all versions of one [OSMRelation] from the server by its [id].
   *
   * The elements are returned in ascending order by their version number.
   * This means the oldest version is the first and the newest version the last element in the returned [Iterable].
   * Returns a [Future] with a lazy [Iterable] of [OSMRelation]s.
   */
  Future<Iterable<OSMRelation>> getRelationHistory(int id) {
    return _getElements<OSMRelation>('/relation/$id/history');
  }


  /**
   * A function for getting all [OSMElement]s in a given bounding box.
   *
   * More details here: https://wiki.openstreetmap.org/wiki/API_v0.6#Retrieving_map_data_by_bounding_box:_GET_.2Fapi.2F0.6.2Fmap
   * Returns a [Future] with an [OSMElementBundle]
   */
  Future<OSMElementBundle> getElementsByBoundingBox(BoundingBox bbox) async {
    final elements = await _getElements<OSMElement>('/map?bbox=${bbox.toList().join(',')}');
    return OSMElementBundle(elements);
  }


  /**
   * A function for getting multiple [OSMElement]s from the server by a request url.
   *
   * Returns a [Future] with a lazy [Iterable] of the typed [OSMElement]s.
   */
  Future<Iterable<T>> _getElements<T extends OSMElement>(String request) async {
    // returns element as json
    final response = await sendRequest(request, headers: const { 'Accept': 'application/json' });
    // parse json
    final jsonData = json.decode(response.data);
    // get all elements
    final jsonObjects = jsonData['elements'].cast<Map<String, dynamic>>();

    return _lazyJSONtoOSMElements(jsonObjects).cast<T>();
  }


  /**
   * A generator/lazy iterable for converting JSON Objects to [OSMElement]s from a given type.
   */
  Iterable<OSMElement> _lazyJSONtoOSMElements(Iterable<Map<String, dynamic>> objects) sync* {
    for (final jsonObj in objects) {
      switch (jsonObj['type']) {
        case 'node':
          yield OSMNode.fromJSONObject(jsonObj);
        break;

        case 'way':
          yield OSMWay.fromJSONObject(jsonObj);
        break;

        case 'relation':
          yield OSMRelation.fromJSONObject(jsonObj);
        break;

        // skip/ignore invalid elements
        default: continue;
      }
    }
  }
}