// Spaltenbezeichnungen und Reihenfolge der csv-Datei
// Datum,Artikel,Artikelbeschreibung,Kategorie,Produktart,Menge,Einheit,Preis (€),Supermarkt,Kommentar,Wer

import 'dart:convert';
import 'dart:io';
import 'package:csv/csv.dart';
import 'package:file_picker/file_picker.dart';
import 'package:flutter/material.dart';
import 'package:fl_chart/fl_chart.dart';

class Einkauf {
  final String datum;
  final String artikel;
  final String beschreibung;
  final String kategorie;
  final String produktart;
  final double menge;
  final String einheit;
  final double preis;
  final String supermarkt;
  final String kommentar;
  final String wer;

  Einkauf({
    required this.datum,
    required this.artikel,
    required this.beschreibung,
    required this.kategorie,
    required this.produktart,
    required this.menge,
    required this.einheit,
    required this.preis,
    required this.supermarkt,
    required this.kommentar,
    required this.wer,
  });
}

class DashboardFromCSV extends StatefulWidget {
  @override
  _DashboardFromCSVState createState() => _DashboardFromCSVState();
}

class _DashboardFromCSVState extends State<DashboardFromCSV> {
  List<Einkauf> _einkaeufe = [];
  String status = 'Keine Datei geladen';

  Future<void> _pickFileAndParse() async {
    FilePickerResult? result = await FilePicker.platform.pickFiles();
    if (result != null) {
      final file = File(result.files.single.path!);
      final content = await file.readAsString();
      final csvRows = const CsvToListConverter(fieldDelimiter: ';', eol: '\n').convert(content);

      if (csvRows.isNotEmpty) csvRows.removeAt(0);

      setState(() {
        _einkaeufe = csvRows
            .where((row) => row.length >= 11)
            .map((row) => Einkauf(
                  datum: row[0]?.toString() ?? '',
                  artikel: row[1]?.toString() ?? '',
                  beschreibung: row[2]?.toString() ?? '',
                  kategorie: row[3]?.toString() ?? '',
                  produktart: row[4]?.toString() ?? '',
                  menge: double.tryParse(row[5]?.toString().replaceAll(',', '.') ?? '') ?? 0.0,
                  einheit: row[6]?.toString() ?? '',
                  preis: double.tryParse(row[7]?.toString().replaceAll(',', '.') ?? '') ?? 0.0,
                  supermarkt: row[8]?.toString() ?? '',
                  kommentar: row[9]?.toString() ?? '',
                  wer: row[10]?.toString() ?? '',
                ))
            .toList();
        status = "Datei geladen: ${result.files.single.name}";
      });
    }
  }

  Map<String, double> _berechneAusgabenNachProduktart() {
    final Map<String, double> ausgaben = {};
    for (var e in _einkaeufe) {
      final art = e.produktart.isEmpty ? 'Unbekannt' : e.produktart;
      ausgaben[art] = (ausgaben[art] ?? 0) + e.preis;
    }
    return ausgaben;
  }

  List<PieChartSectionData> _buildPieChartSections() {
    final data = _berechneAusgabenNachProduktart();
    final total = data.values.fold(0.0, (sum, item) => sum + item);
    final labels = data.keys.toList();
    final values = data.values.toList();

    if (total == 0) return [];

    return List.generate(data.length, (i) {
      return PieChartSectionData(
        color: Colors.primaries[i % Colors.primaries.length],
        value: values[i],
        title: "${labels[i]}\n${values[i].toStringAsFixed(2)} €",
        radius: 100,
        titleStyle: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold, color: Colors.white),
      );
    });
  }

  Map<String, double> _berechneTopKategorien() {
    final Map<String, double> ausgaben = {};
    for (var e in _einkaeufe) {
      ausgaben[e.kategorie] = (ausgaben[e.kategorie] ?? 0) + e.preis;
    }
    return Map.fromEntries(
      ausgaben.entries.toList()
        ..sort((a, b) => b.value.compareTo(a.value))
        ..length = ausgaben.length < 5 ? ausgaben.length : 5,
    );
  }
List<BarChartGroupData> _buildBarChartData() {
  final data = _berechneTopKategorien();
  final values = data.values.toList();

  return List.generate(data.length, (i) {
    return BarChartGroupData(x: i, barRods: [
      BarChartRodData(
        toY: values[i],
        color: Colors.blueAccent,
        width: 20, // Breite der Balken hinzufügen
      )
    ]);
  });
}

  @override
  Widget build(BuildContext context) {
    final topKategorien = _berechneTopKategorien();

    return Scaffold(
      appBar: AppBar(title: const Text("Einkaufs-Dashboard")),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: SingleChildScrollView(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              ElevatedButton(
                onPressed: _pickFileAndParse,
                child: const Text("CSV-Datei laden"),
              ),
              const SizedBox(height: 12),
              Text(status),
              const SizedBox(height: 24),
              if (_einkaeufe.isNotEmpty) ...[
                const Text("Ausgaben nach Produktart"),
                const SizedBox(height: 12),
                SizedBox(
                  height: 300,
                  child: PieChart(
                    PieChartData(
                      sections: _buildPieChartSections(),
                      sectionsSpace: 2,
                      centerSpaceRadius: 60,
                    ),
                  ),
                ),
                const SizedBox(height: 24),
                const Text("Top 5 Kategorien nach Ausgaben"),
                const SizedBox(height: 12),
                SizedBox(
                  height: 300,
                  child: BarChart(
                    BarChartData(
                      barGroups: _buildBarChartData(),
                      titlesData: FlTitlesData(
                        leftTitles: AxisTitles(sideTitles: SideTitles(showTitles: true)),
                        bottomTitles: AxisTitles(
                          sideTitles: SideTitles(
                            showTitles: true,
                            reservedSize: 80,
                            getTitlesWidget: (value, meta) {
                              final index = value.toInt();
                              return Transform.rotate(
                                angle: -1.2, // ca 69 Grad
                                child: Padding(
                                  padding: const EdgeInsets.only(top: 40), // weiter hochschieben
                                  child: Text(
                                    index < topKategorien.length ? topKategorien.keys.toList()[index] : '',
                                    style: const TextStyle(fontSize: 14),
                                    textAlign: TextAlign.right,
                                  ),
                                ),
                              );
                            },
                          ),
                        ),
                      ),
                    ),
                  ),
                )
              ]
            ],
          ),
        ),
      ),
    );
  }
}
