part of aushang;

class VpAushang {
  final String uniqueId;
  final bool isTicker;
  final String name;
  final DateTime lastChanged;
  ReadStatusBasic read;
  final String contentUrl;
  VpAushang(
      {required this.name,
      required this.lastChanged,
      required this.isTicker,
      required this.uniqueId,
      required this.contentUrl,
      required this.read});
  Aushang toAushang() {
    return Aushang(
        id: uniqueId,
        name: name,
        status: "vp",
        dateCreated: DateTime.fromMicrosecondsSinceEpoch(0),
        dateUpdated: lastChanged,
        textContent: contentUrl,
        files: [],
        klassenstufen: [],
        read: read,
        fixed: false);
  }
}
