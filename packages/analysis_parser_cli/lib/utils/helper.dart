import 'dart:convert';
import 'dart:io';
import 'package:analysis_parser_cli/models/file.dart';

class AnalysisCLIHelpers {

  static const projectPathKey = 'project-dir';
  static const outputDirKey = 'output-dir';
  static const languageKey = 'lang';
  static const configFileKey = 'config';
  
  static Map<String, Map<String, dynamic>> generateAnalysisMap(List<AnalysisFile> analysisFiles, String rootPath) {
    final Map<String, Map<String, dynamic>> analysisMap = {};
    for (var file in analysisFiles) {
      final lines = <String, dynamic>{};
      for (var line in file.lines) {
        final lineNumber = line.lineNumber.toString();
        lines.update(lineNumber, (existing) {
          return _mergeLineMaps(existing, line.toJson());
        }, ifAbsent: line.toJson);
      }
      analysisMap['$rootPath/${file.path}'] = lines;
    }
    return analysisMap;
  }

  static Map<String, dynamic> _mergeLineMaps(Map<String, dynamic> map1, Map<String, dynamic> map2) {
    List<T> mergeValues<T>(dynamic v1, dynamic v2) {
      final list1 = v1 is List ? v1.cast<T>() : [v1 as T];
      final list2 = v2 is List ? v2.cast<T>() : [v2 as T];
      return [...list1, ...list2];
    }

    return {
      'line': map1['line'],
      'message': mergeValues<String>(map1['message'], map2['message']),
      'type': mergeValues<String>(map1['type'], map2['type']),
      'column': mergeValues<int>(map1['column'], map2['column']),
      'rule': mergeValues<String>(map1['rule'], map2['rule']),
    };
  }

   static Future<String?> writeAnalysisMapToJson(Map<String, Map<String, dynamic>> analysisMap, String filePath) async {
    try {
      String jsonString = json.encode(analysisMap);
      File file = File(filePath);
      if (await file.exists()) {
        await file.delete(); // Deletes the file if it exists
      }
      await file.create(recursive: true);
      await file.writeAsString(jsonString);
      return file.path;
    } catch (e) {
      print('Unable to write to file: $e');
      exit(-1);
    }
  }
}
