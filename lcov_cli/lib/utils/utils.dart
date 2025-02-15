import 'dart:io';

void exitWithMessage(String message, {int exitCode = 1}) {
  stderr.writeln(message);
  exit(exitCode);
}


extension ArgumentNotNull on Object? {
  bool get isNull {
    return this == null;
  }
}

extension OrEmpty on String? {
  String get orEmpty {
    return this == null ? '' : this!;
  }
}
