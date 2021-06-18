class OSMChangeset {
  Map<String, String> tags;

  int id;

  OSMChangeset({
    Map<String, String>? tags,
    this.id = 0,
  }) : this.tags = tags ?? <String, String>{};

  OSMChangeset.fromXML(String xml) : tags = const <String, String>{}, id = 0;

  String tagsToXML() {
    String xmlString = '';
    tags.forEach((key, value) {
      xmlString +='<tag k="$key" v="$value"/>';
    });
    return xmlString;
  }
}