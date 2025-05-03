
import 'dart:io';
import 'package:flutter/material.dart';
import 'package:file_picker/file_picker.dart';
import 'package:csv/csv.dart';
import 'package:fl_chart/fl_chart.dart';

class Einkauf {
  final String artikel;
  final String kategorie;
  final double preis;

  Einkauf({required this.artikel, required this.kategorie, required this.preis});
}

class DashboardFromCSV extends StatefulWidget {
  @override
  State<DashboardFromCSV> createState() => _DashboardFromCSVState();
}

class _DashboardFromCSVState extends State<DashboardFromCSV> {
  List<Einkauf> _einkaeufe = [];
  String status = "Noch keine Datei geladen.";

  Future<void> _pickFileAndParse() async {
    final result = await FilePicker.platform.pickFiles(
      type: FileType.any,
      allowMultiple: false,
    );

    if (result != null && result.files.single.path != null) {
      final file = File(result.files.single.path!);
      final content = await file.readAsString();
      print("📄 Dateiinhalt (erster Teil):\n${content.substring(0, 200)}");

      final csvRows = const CsvToListConverter(fieldDelimiter: ',', eol: '\n').convert(content);

      if (csvRows.isNotEmpty) {
        print("✅ CSV-Zeilen geladen: ${csvRows.length}");
        csvRows.removeAt(0); // Header entfernen
      }

      setState(() {
        _einkaeufe = csvRows.map((row) {
          print("➡️ Zeile: ${row.take(6).join(' | ')}");
          return Einkauf(
            artikel: row[1].toString(),
            kategorie: row[2].toString(),
            preis: double.tryParse(row[5].toString().replaceAll(',', '.')) ?? 0.0,
          );
        }).toList();

        status = "CSV geladen: ${_einkaeufe.length} Einkäufe.";
      });
    }
  }

  List<BarChartGroupData> _kategorienChart() {
    final Map<String, double> summen = {};
    for (var e in _einkaeufe) {
      summen[e.kategorie] = (summen[e.kategorie] ?? 0) + e.preis;
    }

    final kategorien = summen.entries.toList()
      ..sort((a, b) => b.value.compareTo(a.value));
    final top10 = kategorien.take(10).toList();

    return List.generate(top10.length, (i) {
      return BarChartGroupData(
        x: i,
        barRods: [
          BarChartRodData(
            toY: top10[i].value,
            width: 16,
            color: Colors.cyanAccent,
            borderRadius: BorderRadius.circular(4),
          )
        ],
      );
    });
  }

  List<String> _kategorienLabels() {
    final Map<String, double> summen = {};
    for (var e in _einkaeufe) {
      summen[e.kategorie] = (summen[e.kategorie] ?? 0) + e.preis;
    }
    final kategorien = summen.entries.toList()
      ..sort((a, b) => b.value.compareTo(a.value));
    return kategorien.take(10).map((e) => e.key).toList();
  }

  @override
  Widget build(BuildContext context) {
    final labels = _kategorienLabels();
    return Scaffold(
      appBar: AppBar(title: Text('Test: Kategorien')),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          children: [
            ElevatedButton(
              onPressed: _pickFileAndParse,
              child: Text('CSV wählen'),
            ),
            SizedBox(height: 12),
            Text(status),
            SizedBox(height: 20),
            if (_einkaeufe.isNotEmpty)
              SizedBox(
                height: 300,
                child: BarChart(BarChartData(
                  barGroups: _kategorienChart(),
                  titlesData: FlTitlesData(
                    bottomTitles: AxisTitles(
                      sideTitles: SideTitles(
                        showTitles: true,
                        reservedSize: 42,
                        getTitlesWidget: (value, _) {
                          final i = value.toInt();
                          if (i >= 0 && i < labels.length) {
                            return Transform.rotate(
                              angle: -0.7,
                              child: Text(labels[i], style: TextStyle(fontSize: 10)),
                            );
                          }
                          return Text('');
                        },
                      ),
                    ),
                  ),
                  borderData: FlBorderData(show: false),
                )),
              ),
          ],
        ),
      ),
    );
  }
}
