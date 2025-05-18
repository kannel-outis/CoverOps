
import 'dart:io';

import 'package:dcli/dcli.dart';


/// A utility class for logging messages with colored output.
///
/// The [Logger] class provides static methods to log messages at different severity
/// levels (info, warning, error, log, success) with color-coded output using the
/// `dcli` package.
class Logger {

  /// The output sink for error messages.
  /// 
  /// By default, writes to stderr (standard output). Can be modified to redirect
  /// error output to a different destination like a file.
  static IOSink errorOutput = stderr;
  /// Parses a message into a string, handling various input types.
  ///
  /// Converts the input [message] to a string, extracting relevant details for
  /// exceptions and errors. If the message is null, returns an empty string.
  /// For exceptions, extracts the message after the last colon. For errors,
  /// includes a truncated stack trace.
  ///
  /// @param message The message to parse, which can be any type (e.g., String,
  ///               Exception, Error, or null).
  /// @return A formatted string representation of the message.
  static String _parseMessage(dynamic message) {
    if (message == null) {
      return '';
    }
    if (message is Exception) {
      final parts = message.toString().split(':');
      return parts.isNotEmpty ? parts.last.trim() : message.toString();
    }
    if (message is Error) {
      final stackTrace = message.stackTrace?.toString().split('\n').take(2).join('\n') ?? '';
      return '${message.toString()}\n$stackTrace'.trim();
    }
    return message.toString().trim();
  }

  /// Logs an informational message in blue with an [INFO] prefix.
  ///
  /// Suitable for general status updates or informational messages.
  ///
  /// @param message The message to log, which can be a String, Exception, Error,
  ///               or any object with a meaningful toString().
  /// @example
  /// ```dart
  /// Logger.info('Processing data...');
  /// Logger.info(Exception('Invalid input'));
  /// ```
  static void info(dynamic message) {
    print(blue('[INFO] ${_parseMessage(message)}'));
  }

  /// Logs a warning message in yellow with a [WARNING] prefix.
  ///
  /// Use for non-critical issues that may need attention.
  ///
  /// @param message The message to log, which can be a String, Exception, Error,
  ///               or any object with a meaningful toString().
  /// @example
  /// ```dart
  /// Logger.warning('Deprecated API used');
  /// ```
  static void warning(dynamic message) {
    print(yellow('[WARNING] ${_parseMessage(message)}'));
  }

  /// Logs an error message in red with an [ERROR] prefix.
  ///
  /// Use for critical issues or failures that require immediate attention.
  ///
  /// @param message The message to log, which can be a String, Exception, Error,
  ///               or any object with a meaningful toString().
  /// @example
  /// ```dart
  /// Logger.error('Failed to connect to server');
  /// Logger.error(Error());
  /// ```
  static void error(dynamic message) {
    errorOutput.writeln(red('[ERROR] ${_parseMessage(message)}'));
  }

  /// Logs a general message in grey with a [LOG] prefix.
  ///
  /// Suitable for debug or miscellaneous logging without specific severity.
  ///
  /// @param message The message to log, which can be a String, Exception, Error,
  ///               or any object with a meaningful toString().
  /// @example
  /// ```dart
  /// Logger.log('Received 42 items');
  /// ```
  static void log(dynamic message) {
    print(grey('[LOG] ${_parseMessage(message)}'));
  }

  /// Logs a success message in green with a [SUCCESS] prefix.
  ///
  /// Use for operations that complete successfully.
  ///
  /// @param message The message to log, which can be a String, Exception, Error,
  ///               or any object with a meaningful toString().
  /// @example
  /// ```dart
  /// Logger.success('Build completed successfully');
  /// ```
  static void success(dynamic message) {
    print(green('[SUCCESS] ${_parseMessage(message)}'));
  }
}