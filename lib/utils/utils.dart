import 'package:dcli/dcli.dart';

class Utils {
  static String get root {
    final scriptPath = DartScript.self.pathToScriptDirectory.split('/bin');
    scriptPath.removeLast();
    return scriptPath.join('/');
  }
}