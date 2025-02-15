import 'dart:io';

void exitWithMessage(String message, {int exitCode = 1, bool shouldExit = true}) {
  stderr.writeln(message);
  if(shouldExit) exit(exitCode);
}
