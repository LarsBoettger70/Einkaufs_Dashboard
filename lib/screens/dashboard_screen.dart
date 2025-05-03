
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

  Map<String, int> _ernaehrungsVerteilung() {
    final Map<String, int> verteilung = {
      'Fleisch': 0,
      'Fisch': 0,
      'Vegetarisch': 0,
      'Vegan': 0,
      'Getränk': 0,
    };

    for (var e in _einkaeufe) {
      final kategorie = e.kategorie.toLowerCase();
      if (kategorie.contains('fleisch') || kategorie.contains('geflügel')) {
        verteilung['Fleisch'] = verteilung['Fleisch']! + 1;
      } else if (kategorie.contains('fisch')) {
        verteilung['Fisch'] = verteilung['Fisch']! + 1;
      } else if (kategorie.contains('vegan')) {
        verteilung['Vegan'] = verteilung['Vegan']! + 1;
      } else if (kategorie.contains('getränk')) {
        verteilung['Getränk'] = verteilung['Getränk']! + 1;
      } else if (kategorie.contains('vegetarisch') || kategorie.contains('süßigkeit') || kategorie.contains('dessert') || kategorie.contains('obst') || kategorie.contains('gemüse')) {
        verteilung['Vegetarisch'] = verteilung['Vegetarisch']! + 1;
      }
    }

    return verteilung;
  }

  List<PieChartSectionData> _buildPieChartSections() {
    final data = _ernaehrungsVerteilung();
    final colors = [
      Colors.redAccent,
      Colors.lightBlueAccent,
      Colors.green,
      Colors.purple,
      Colors.orange,
    ];
    final labels = data.keys.toList();
    final values = data.values.toList();

    return List.generate(data.length, (i) {
      final value = values[i].toDouble();
      return PieChartSectionData(
        value: value,
        title: '\${labels[i]}\n\${values[i]}',
        color: colors[i],
        radius: 60,
        titleStyle: TextStyle(color: Colors.black, fontSize: 12),
      );
    });
  }

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
      final csvRows = const CsvToListConverter(fieldDelimiter: ',', eol: '\n').convert(content);

      if (csvRows.isNotEmpty) csvRows.removeAt(0); // remove header

      setState(() {
        _einkaeufe = csvRows.map((row) {
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

  List<BarChartGroupData> _top5EinzelartikelChart() {
    final Map<String, double> summen = {};
    final Map<String, String> kategorien = {};
    for (var e in _einkaeufe) {
      final key = e.artikel;
      summen[key] = (summen[key] ?? 0) + e.preis;
      kategorien[key] = e.kategorie;
    }

    final top5 = summen.entries.toList()
      ..sort((a, b) => b.value.compareTo(a.value));
    final top = top5.take(5).toList();

    return List.generate(top.length, (i) {
      return BarChartGroupData(
        x: i,
        barRods: [
          BarChartRodData(
            toY: top[i].value,
            width: 16,
            color: Colors.amberAccent,
            borderRadius: BorderRadius.circular(4),
          )
        ],
      );
    });
  }

  List<String> _top5Labels() {
    final Map<String, double> summen = {};
    final Map<String, String> kategorien = {};
    for (var e in _einkaeufe) {
      final key = e.artikel;
      summen[key] = (summen[key] ?? 0) + e.preis;
      kategorien[key] = e.kategorie;
    }

    final top5 = summen.entries.toList()
      ..sort((a, b) => b.value.compareTo(a.value));
    final top = top5.take(5).map((e) => "${e.key} (${kategorien[e.key]})").toList();
    return top;
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
    final topLabels = _top5Labels();
    return Scaffold(
      appBar: AppBar(toolbarHeight: 0),
      
body: SingleChildScrollView(
  padding: const EdgeInsets.all(16.0),
  child: Column(
    crossAxisAlignment: CrossAxisAlignment.start,
    children: [
                ElevatedButton(
              onPressed: _pickFileAndParse,
              child: Text('CSV wählen'),
            ),
            SizedBox(height: 12),
            Text(status),
            SizedBox(height: 20),
            if (_einkaeufe.isNotEmpty) ...[
              Text("Top 5 Artikel", style: Theme.of(context).textTheme.titleLarge),
              SizedBox(
                height: 200,
                child: BarChart(BarChartData(
                  barGroups: _top5EinzelartikelChart(),
                  titlesData: FlTitlesData(
                    bottomTitles: AxisTitles(
                      sideTitles: SideTitles(
                        showTitles: true,
                        reservedSize: 60,
                        getTitlesWidget: (value, _) {
                          final i = value.toInt();
                          if (i >= 0 && i < topLabels.length) {
                            return Padding(
                              padding: const EdgeInsets.only(top: 8.0),
                              child: Transform.rotate(
                                angle: -0.7,
                                child: Text(topLabels[i], style: TextStyle(fontSize: 10)),
                              ),
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
              SizedBox(height: 30),
              
              SizedBox(height: 32),
              Text("Ernährungsanteile", style: Theme.of(context).textTheme.titleLarge),
              SizedBox(
                height: 250,
                child: PieChart(
                  PieChartData(
                    sections: _buildPieChartSections(),
                    sectionsSpace: 2,
                    centerSpaceRadius: 40,
                  ),
                ),
              ),
              SizedBox(height: 32),
Text("Top 10 Kategorien", style: Theme.of(context).textTheme.titleLarge),
              SizedBox(
                height: 300,
                child: BarChart(BarChartData(
                  barGroups: _kategorienChart(),
                  titlesData: FlTitlesData(
                    bottomTitles: AxisTitles(
                      sideTitles: SideTitles(
                        showTitles: true,
                        reservedSize: 60,
                        getTitlesWidget: (value, _) {
                          final i = value.toInt();
                          if (i >= 0 && i < labels.length) {
                            return Padding(
                              padding: const EdgeInsets.only(top: 8.0),
                              child: Transform.rotate(
                                angle: -0.7,
                                child: Text(labels[i], style: TextStyle(fontSize: 10)),
                              ),
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
            ]
          ],
        ),
      ),
    );
  }
}
