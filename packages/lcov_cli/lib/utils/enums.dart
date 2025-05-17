enum ParserType {
  lcov,
  json,
}

enum ReportType {
  html,
  json,
  console;

  static List<ReportType> fromString(String? typeString) {
    if (typeString == null) return [ReportType.html];
    return typeString.split(',').map((type) => ReportType.values.byName(type)).toList();
  }
}
