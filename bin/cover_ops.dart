

import 'dart:io';

import 'package:cover_ops/cover_ops.dart';

Future<void> main(List<String> arguments) async {
 exit(await CoverOpsRunner().run(arguments));
}
