import 'package:dcli/dcli.dart' hide isEmpty;

class Utils {
  static String get root {
    final scriptPath = DartScript.self.pathToScriptDirectory.split('/bin');
    scriptPath.removeLast();
    return scriptPath.join('/');
  }
}

extension StringExtension on String {
  String get toCamelCase {
    final words = split('-');
    final capitalizedWords = words.getRange(1, words.length).map((word) => word.capitalize);
    return [words.first.toLowerCase(), ...capitalizedWords].join();
  }

  String get capitalize {
    if (isEmpty) return this;
    return '${this[0].toUpperCase()}${substring(1)}';
  }
}
