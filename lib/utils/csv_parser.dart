import 'dart:io';
import 'package:csv/csv.dart';
import '../models/einkauf.dart';

Future<List<Einkauf>> parseCSV(File file) async {
  final input = await file.readAsString();
  final rows = const CsvToListConverter(fieldDelimiter: ";", eol: "\n").convert(input, eol: "\n");
  rows.removeAt(0); // remove header
  return rows.map((row) => Einkauf.fromCSV(List<String>.from(row))).toList();
}