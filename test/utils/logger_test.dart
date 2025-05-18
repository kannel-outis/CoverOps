import 'dart:async';
import 'dart:convert';
import 'dart:io';

import 'package:test/test.dart';
import 'package:cover_ops/utils/logger.dart';



void main() {
  StreamController<List<int>>? controller = StreamController<List<int>>();

  Future<String> captureStdout(void Function() callback) async {
  controller = StreamController<List<int>>();
  final sink = IOSink(controller!.sink, encoding: utf8);

  final originalStdout = Logger.errorOutput;
  final completer = Completer<String>();
  final bytes = <int>[];

  final buffer = StringBuffer();

  controller?.stream.listen(
    bytes.addAll,
    onDone: () {
      final result = utf8.decode(bytes);
      if(!completer.isCompleted) completer.complete(result);
    },
  );

  // Redirect stdout
  Logger.errorOutput = sink;

  try {
    runZonedGuarded(
    () {
      callback();
    },
    (e, st) {},
    zoneSpecification: ZoneSpecification(
      print: (_, __, ___, String msg) {
        buffer.writeln(msg);
        completer.complete(msg);
      },
    ),
  );
  } finally {
    await sink.flush();
    await sink.close();
    Logger.errorOutput = originalStdout; // Restore
  }

  return await completer.future;
}

void tearDownController() {
  addTearDown(() {
    controller?.close();
    controller = null;
  });
}
  test('Logger.info prints [INFO] message', () async {
    tearDownController();
    final output = await captureStdout(() => Logger.info('Info message'));
    expect(output, contains('[INFO] Info message'));
  });

  test('Logger.warning prints [WARNING] message', () async {
    final output = await captureStdout(() => Logger.warning('Warn'));
    expect(output, contains('[WARNING] Warn'));
  });

  test('Logger.error prints [ERROR] message', () async {
    final output = await captureStdout(() => Logger.error('Something broke'));
    expect(output, contains('[ERROR] Something broke'));
  });

  test('Logger.success prints [SUCCESS] message', () async {
    final output = await captureStdout(() => Logger.success('OK'));
    expect(output, contains('[SUCCESS] OK'));
  });

  test('Logger.log prints [LOG] message', () async {
    final output = await captureStdout(() => Logger.log('Just logging'));
    expect(output, contains('[LOG] Just logging'));
  });

  test('Logger handles Exception input', () async {
    final output = await captureStdout(() => Logger.error(Exception('Oops: Critical')));
    expect(output, contains('[ERROR] Critical'));
  });

  test('Logger handles Error input', () async {
    final output = await captureStdout(() => Logger.error(StateError('Bad state')));
    expect(output, contains('[ERROR] Bad state'));
  });

  test('Logger handles null input', () async {
    final output = await captureStdout(() => Logger.info(null));
    expect(output.trim(), contains('[INFO]'));
  });
}
