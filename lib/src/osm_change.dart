import 'package:xml/xml.dart';

import '/src/osm_elements/osm_node.dart';
import '/src/osm_elements/osm_way.dart';
import '/src/osm_elements/osm_relation.dart';
import '/src/osm_elements/osm_element_bundle.dart';


/**
 * A container class that holds the changes of a particular changeset.
 *
 * More details can be found here: https://wiki.openstreetmap.org/wiki/OsmChange
 */
class OSMChange {
  final OSMElementBundle create;
  final OSMElementBundle modify;
  final OSMElementBundle delete;

  int? changesetId;
  String? generator;
  String? version;

  OSMChange({
    OSMElementBundle? create,
    OSMElementBundle? modify,
    OSMElementBundle? delete,
    this.changesetId,
    this.generator,
    this.version
  }) :
    create = create ?? OSMElementBundle(),
    modify = modify ?? OSMElementBundle(),
    delete = delete ?? OSMElementBundle();


  /**
   * A factory method for constructing an [OSMChange] from a XML [String].
   */
  factory OSMChange.fromXMLString(String xmlString) {
    final xmlDoc = XmlDocument.parse(xmlString);
    final osmChangeElement = xmlDoc.findAllElements('osmChange').first;
    return OSMChange.fromXMLElement(osmChangeElement);
  }


  /**
   * A factory method for constructing an [OSMChange] from a XML [XmlElement].
   */
  factory OSMChange.fromXMLElement(XmlElement osmChangeElement) {
    final version = osmChangeElement.getAttribute('version');
    final generator = osmChangeElement.getAttribute('generator');

    int? changesetId;
    try {
      final firstChangesetAttribute = osmChangeElement.descendantElements
        .expand((element) => element.attributes)
        .firstWhere((attribute) => attribute.name.local == 'changeset');
      changesetId = int.tryParse(firstChangesetAttribute.value);
    }
    on StateError {
      changesetId = null;
    }

    final changesMap = {
      'create': OSMElementBundle(),
      'modify': OSMElementBundle(),
      'delete': OSMElementBundle()
    };

    for (final changeChild in osmChangeElement.childElements) {
      final changeBundle = changesMap[changeChild.name.local];

      if (changeBundle == null) {
        continue;
      }

      for (final osmElement in changeChild.childElements) {
        switch(osmElement.name.local) {
          case 'node':
            changeBundle.nodes.add(OSMNode.fromXMLElement(osmElement));
          break;
          case 'way':
            changeBundle.ways.add(OSMWay.fromXMLElement(osmElement));
          break;
          case 'relation':
            changeBundle.relations.add(OSMRelation.fromXMLElement(osmElement));
          break;
        }
      }
    }

    return OSMChange(
      create: changesMap['create'],
      modify: changesMap['modify'],
      delete: changesMap['delete'],
      version: version,
      generator: generator,
      changesetId: changesetId
    );
  }


  StringBuffer toXML() {
    final additionalAttributes = changesetId != null
      ? { 'changeset': changesetId }
      : const <String, dynamic>{};

    final stringBuffer = StringBuffer()..write('<osmChange');
    if (version != null) {
      stringBuffer..write(' version="')..write(version)..write('"');
    }
    if (generator != null) {
      stringBuffer..write(' generator="')..write(generator)..write('"');
    }
    stringBuffer.writeln('>');

    final changesMap = {
      'create': create,
      'modify': modify,
      'delete': delete
    };

    for (final entry in changesMap.entries) {
      final changeName = entry.key;
      final changeBundle = entry.value;
      final includeBody = changeName != 'delete';

      for (final element in changeBundle.elements) {
        stringBuffer..write('<')..write(changeName)..writeln('>');
        element.toXML(
          buffer: stringBuffer,
          additionalAttributes: additionalAttributes,
          includeBody: includeBody
        );
        stringBuffer..write('</')..write(changeName)..writeln('>');
      }
    }

    return stringBuffer..write('</osmChange>');
  }
}
