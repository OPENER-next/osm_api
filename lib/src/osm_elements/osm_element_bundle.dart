import 'dart:core';

import '/src/osm_elements/osm_element_type.dart';
import '/src/osm_elements/osm_element.dart';
import '/src/osm_elements/osm_node.dart';
import '/src/osm_elements/osm_way.dart';
import '/src/osm_elements/osm_relation.dart';
import '/src/osm_elements/osm_member.dart';


/**
 * A container class for multiple OSM elements of different types.
 * This provides also some helper functions to deal with the data more easily.
 */
class OSMElementBundle {

  final nodes =  <OSMNode>{};

  final ways = <OSMWay>{};

  final relations = <OSMRelation>{};


  /**
   * This takes an iterable of [OSMElement]s and puts each element in its dedicated [nodes], [ways] or [relations] list.
   */
  OSMElementBundle([
    Iterable<OSMElement> elements = const Iterable.empty()
  ]) {
    for (final element in elements) {
      switch (element.runtimeType) {
        case OSMNode:
          nodes.add(element as OSMNode);
        break;
        case OSMWay:
          ways.add(element as OSMWay);
        break;
        case OSMRelation:
          relations.add(element as OSMRelation);
        break;
      }
    }
  }


  /**
   * Returns an iterable of all [OSMElement]s in this bundle.
   * This can be used to easily iterate over [nodes], [ways] and [relations] in one loop.
   */
  Iterable<OSMElement> get elements sync* {
    yield* nodes;
    yield* ways;
    yield* relations;
  }


  bool get isEmpty => nodes.isEmpty && ways.isEmpty && relations.isEmpty;


  bool get isNotEmpty => !isEmpty;


  /**
   * A function to get all [OSMNode]s from the current [OSMElementBundle] that are contained in the given [OSMWay].
   */
  Iterable<OSMNode> getNodesFromWay(OSMWay way) sync* {
    for (final nodeId in way.nodeIds) {
      // skip nodes that do not have a valid id yet
      if (nodeId == 0) continue;

      try {
        yield nodes.firstWhere((node) => node.id == nodeId);
      }
      on StateError {
        throw StateError('Node $nodeId of way ${way.id} not found in $OSMElementBundle.');
      }
    }
  }


  /**
   * A function to get all [OSMNode]s from the current [OSMElementBundle] that are contained in the given [OSMRelation].
   */
  Iterable<OSMNode> getNodesFromRelation(OSMRelation relation) {
    return _getElementsFromRelation(nodes, relation);
  }


  /**
   * A function to get all [OSMWay]s from the current [OSMElementBundle] that are contained in the given [OSMRelation].
   */
  Iterable<OSMWay> getWaysFromRelation(OSMRelation relation) {
    return _getElementsFromRelation(ways, relation);
  }


  /**
   * A function to get all [OSMRelation]s from the current [OSMElementBundle] that are contained in the given [OSMRelation].
   */
  Iterable<OSMRelation> getRelationsFromRelation(OSMRelation relation) {
    return _getElementsFromRelation(relations, relation);
  }



  Iterable<T> _getElementsFromRelation<T extends OSMElement>(Iterable<T> elements, OSMRelation relation) sync* {
    // only loop through the members with the respective osm element type
    final Iterable<OSMMember> relevantMembers;
    switch (T) {
      case OSMNode: relevantMembers = relation.members.where(
        (member) => member.type == OSMElementType.node
      ); break;

      case OSMWay: relevantMembers = relation.members.where(
        (member) => member.type == OSMElementType.way
      ); break;

      case OSMRelation: relevantMembers = relation.members.where(
        (member) => member.type == OSMElementType.relation
      ); break;

      default: relevantMembers = relation.members;
    }

    for (final member in relevantMembers) {
      // skip elements that do not have a valid id yet
      if (member.ref == 0) continue;

      try {
        yield elements.firstWhere((element) => element.id == member.ref);
      }
      on StateError {
        throw StateError('Member of type ${member.type.name} with ref ${member.ref} of relation ${relation.id} not found in $OSMElementBundle.');
      }
    }
  }
}