import 'dart:convert';

extension StreamListOfInt on Stream<List<int>> {
  Future<void> splitForEach(void Function(String) action) {
    return transform(utf8.decoder).transform(const LineSplitter()).forEach(action);
  }
}