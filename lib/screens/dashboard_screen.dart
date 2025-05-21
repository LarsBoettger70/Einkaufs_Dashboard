// Spaltenbezeichnungen und Reihenfolge der csv-Datei
// Nr;Datum;Artikel;Artikelbeschreibung;Kategorie;Produktart;Menge;Einheit;Preis (€);Supermarkt;Kommentar;Wer

import 'dart:convert';
import 'dart:io';
import 'package:csv/csv.dart';
import 'package:file_picker/file_picker.dart';
import 'package:flutter/material.dart';
import 'package:fl_chart/fl_chart.dart';
import 'package:image_picker/image_picker.dart';
import 'package:google_ml_kit/google_ml_kit.dart';

class Einkauf {
  final String nr;
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
    required this.nr,
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
  bool zeigePreise = true;

  Future<void> _pickFileAndParse() async {
    FilePickerResult? result = await FilePicker.platform.pickFiles();
    if (result != null) {
      final file = File(result.files.single.path!);
      final content = await file.readAsString();
      final csvRows = const CsvToListConverter(fieldDelimiter: ';', eol: '\n').convert(content);

      if (csvRows.isNotEmpty) csvRows.removeAt(0);

      setState(() {
        _einkaeufe = csvRows
            .where((row) => row.length >= 12)
            .map((row) => Einkauf(
                  nr: row[0]?.toString() ?? '',
                  datum: row[1]?.toString() ?? '',
                  artikel: row[2]?.toString() ?? '',
                  beschreibung: row[3]?.toString() ?? '',
                  kategorie: row[4]?.toString() ?? '',
                  produktart: row[5]?.toString() ?? '',
                  menge: double.tryParse(row[6]?.toString().replaceAll(',', '.') ?? '') ?? 0.0,
                  einheit: row[7]?.toString() ?? '',
                  preis: double.tryParse(row[8]?.toString().replaceAll(',', '.') ?? '') ?? 0.0,
                  supermarkt: row[9]?.toString() ?? '',
                  kommentar: row[10]?.toString() ?? '',
                  wer: row[11]?.toString() ?? '',
                ))
            .toList();
        status = "Datei geladen: ${result.files.single.name}";
      });
    }
  }

  Future<void> _pickReceiptImage() async {
    final ImagePicker _picker = ImagePicker();
    final XFile? image = await _picker.pickImage(source: ImageSource.camera);
    
    if (image != null) {
      _processReceiptImage(image.path);
    }
  }
  
  Future<void> _pickReceiptFromGallery() async {
    final ImagePicker _picker = ImagePicker();
    final XFile? image = await _picker.pickImage(source: ImageSource.gallery);
    
    if (image != null) {
      _processReceiptImage(image.path);
    }
  }
  
  Future<void> _processReceiptImage(String imagePath) async {
    setState(() {
      status = "Bild wird verarbeitet...";
    });
    
    try {
      // Check if the file exists
      final File imageFile = File(imagePath);
      if (!await imageFile.exists()) {
        setState(() {
          status = "Fehler: Bilddatei nicht gefunden";
        });
        return;
      }
      
      // Special handling for HEIC images
      if (imagePath.toLowerCase().endsWith('.heic')) {
        setState(() {
          status = "HEIC-Format wird nicht unterstützt. Bitte wählen Sie ein JPEG oder PNG-Bild aus.";
        });
        return;
      }
      
      // Process the receipt image with OCR
      try {
        final inputImage = InputImage.fromFilePath(imagePath);
        final textRecognizer = TextRecognizer();
        
        try {
          final RecognizedText recognizedText = await textRecognizer.processImage(inputImage);
          print("Erkannter Text: ${recognizedText.text}");
          
          // Extract data from OCR result
          List<Einkauf> extractedEinkaeufe = await _parseReceiptText(recognizedText.text);
          
          setState(() {
            if (extractedEinkaeufe.isNotEmpty) {
              _einkaeufe = extractedEinkaeufe;
              status = "Kassenbon erfolgreich verarbeitet";
            } else {
              status = "Keine Einträge im Kassenbon erkannt";
            }
          });
        } finally {
          textRecognizer.close();
        }
      } catch (e) {
        setState(() {
          status = "OCR-Fehler: $e";
        });
      }
    } catch (e) {
      setState(() {
        status = "Dateifehler: $e";
      });
    }
  }

  Future<List<Einkauf>> _parseReceiptText(String text) async {
    // This is a simplified example of receipt parsing
    // In a real application, you would need more sophisticated pattern matching
    List<Einkauf> results = [];
    
    // Split text into lines
    List<String> lines = text.split('\n');
    
    int counter = 1;
    String currentDate = DateTime.now().toString().split(' ')[0];
    String currentSupermarkt = '';
    
    // Identify supermarket name if possible
    for (String line in lines) {
      if (line.contains('REWE')) currentSupermarkt = 'REWE';
      else if (line.contains('ALDI')) currentSupermarkt = 'ALDI';
      else if (line.contains('LIDL')) currentSupermarkt = 'LIDL';
      // More supermarkets can be added here
    }
    
    // Look for price patterns in each line
    for (String line in lines) {
      // Match patterns like "Item Name     10,99 €" or "Item Name 1x10,99 €"
      RegExp pricePattern = RegExp(r'(.+?)(?:\s+|x)(\d+[,.]\d+)\s*€');
      Match? match = pricePattern.firstMatch(line);
      
      if (match != null && match.groupCount >= 2) {
        String artikel = match.group(1)?.trim() ?? '';
        String preisStr = match.group(2)?.replaceAll(',', '.') ?? '0.0';
        double preis = double.tryParse(preisStr) ?? 0.0;
        
        if (artikel.isNotEmpty && preis > 0) {
          results.add(Einkauf(
            nr: counter.toString(),
            datum: currentDate,
            artikel: artikel,
            beschreibung: artikel,
            kategorie: 'Unbestimmt',
            produktart: 'Unbestimmt',
            menge: 1.0,
            einheit: 'Stk',
            preis: preis,
            supermarkt: currentSupermarkt,
            kommentar: 'Automatisch erfasst',
            wer: '',
          ));
          counter++;
        }
      }
    }
    
    return results;
  }

  Map<String, double> _berechneAusgabenNachProduktart() {
    final Map<String, double> ausgaben = {};
    for (var e in _einkaeufe) {
      if (e.produktart.toLowerCase() == 'nicht essbar') continue;
      final art = e.produktart.isEmpty ? 'Unbestimmt' : e.produktart;
      final wert = zeigePreise ? e.preis : 1.0;
      ausgaben[art] = (ausgaben[art] ?? 0) + wert;
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
        title: "${labels[i]}\n${values[i].toInt()} ${zeigePreise ? '€' : ''}",
        radius: 90,
        titleStyle: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold, color: Colors.white),
      );
    });
  }

  Map<String, double> _berechneTopKategorien() {
    final Map<String, double> ausgaben = {};
    for (var e in _einkaeufe) {
      final wert = zeigePreise ? e.preis : 1.0;
      ausgaben[e.kategorie] = (ausgaben[e.kategorie] ?? 0) + wert;
    }
    return Map.fromEntries(
      ausgaben.entries.toList()
        ..sort((a, b) => b.value.compareTo(a.value))
        ..length = ausgaben.length < 7 ? ausgaben.length : 7,
    );
  }

  List<BarChartGroupData> _buildBarChartData() {
    final data = _berechneTopKategorien();
    final values = data.values.toList();

    return List.generate(data.length, (i) {
      return BarChartGroupData(
        x: i,
        barRods: [
          BarChartRodData(
            toY: values[i],
            color: Colors.blueAccent,
            width: 15,
            borderRadius: BorderRadius.zero,
          )
        ],
        showingTooltipIndicators: [0],
      );
    });
  }

  @override
  Widget build(BuildContext context) {
    final topKategorien = _berechneTopKategorien();

    return Scaffold(
      appBar: AppBar(
        title: const Text("Einkaufs-Dashboard"),
        actions: [
          Row(
            children: [
              const Text("€"),
              Switch(
                value: zeigePreise,
                onChanged: (val) {
                  setState(() {
                    zeigePreise = val;
                  });
                },
              ),
              const Text("Anzahl"),
              const SizedBox(width: 12),
            ],
          )
        ],
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: SingleChildScrollView(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  ElevatedButton(
                    onPressed: _pickFileAndParse,
                    child: const Text("CSV laden"),
                  ),
                  const SizedBox(width: 12),
                  ElevatedButton(
                    onPressed: _pickReceiptImage,
                    child: const Text("Bon Scan"),
                  ),
                  const SizedBox(width: 12),
                  ElevatedButton(
                    onPressed: _pickReceiptFromGallery,
                    child: const Text("Bon Foto"),
                  ),
                ],
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
                Text("Top 7 Kategorien nach ${zeigePreise ? 'Ausgaben' : 'Anzahl'}"),
                const SizedBox(height: 12),
                SizedBox(
                  height: 300,
                  child: BarChart(
                    BarChartData(
                      barGroups: _buildBarChartData(),
                      titlesData: FlTitlesData(
                        leftTitles: AxisTitles(
                          sideTitles: SideTitles(
                            showTitles: true,
                            reservedSize: 90,
                            getTitlesWidget: (value, meta) {
                              return const SizedBox();
                            },
                          ),
                        ),
                        topTitles: AxisTitles(sideTitles: SideTitles(showTitles: false)),
                        bottomTitles: AxisTitles(
                          sideTitles: SideTitles(
                            showTitles: true,
                            reservedSize: 80,
                            getTitlesWidget: (value, meta) {
                              final index = value.toInt();
                              if (index < topKategorien.length) {
                                final categoryName = topKategorien.keys.toList()[index];
                                final displayText = categoryName.length > 10 
                                    ? categoryName.substring(0, 10) + '...' 
                                    : categoryName;
                                
                                return RotatedBox(
                                  quarterTurns: 3, // 270 degrees (vertical text)
                                  child: Padding(
                                    padding: const EdgeInsets.only(right: 10),
                                    child: Text(
                                      displayText,
                                      style: const TextStyle(fontSize: 11),
                                      maxLines: 1,
                                    ),
                                  ),
                                );
                              }
                              return const SizedBox();
                            },
                          ),
                        ),
                        rightTitles: AxisTitles(
                          sideTitles: SideTitles(
                            showTitles: true,
                            getTitlesWidget: (value, meta) {
                              return Text(value.toInt().toString(), style: const TextStyle(fontSize: 10));
                            },
                          ),
                        ),
                      ),
                      barTouchData: BarTouchData(
                        enabled: true,
                        touchTooltipData: BarTouchTooltipData(
                          tooltipPadding: const EdgeInsets.symmetric(horizontal: 4, vertical: 2),
                          tooltipMargin: 4,
                          getTooltipItem: (group, groupIndex, rod, rodIndex) {
                            final value = rod.toY.toInt();
                            return BarTooltipItem(
                              '${value} ${zeigePreise ? '€' : ''}',
                              const TextStyle(
                                color: Colors.white,
                                fontWeight: FontWeight.bold,
                                fontSize: 10,
                              ),
                            );
                          },
                        ),
                      ),
                      gridData: FlGridData(show: true),
                      alignment: BarChartAlignment.center,
                      maxY: _berechneTopKategorien().values.fold(0.0, (prev, elem) => elem > prev ? elem : prev) * 1.2,
                      borderData: FlBorderData(show: false),
                    ),
                  ),
                ),
              ]
            ],
          ),
        ),
      ),
    );
  }
}
