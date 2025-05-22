// Spaltenbezeichnungen und Reihenfolge der csv-Datei
// Nr;Datum;Artikel;Artikelbeschreibung;Kategorie;Produktart;Menge;Einheit;Preis (€);Supermarkt;Kommentar;Wer

import 'dart:convert';
import 'dart:io';
import 'package:csv/csv.dart';
import 'package:drift/drift.dart' as drift;
import 'package:file_picker/file_picker.dart';
import 'package:flutter/material.dart';
import 'package:fl_chart/fl_chart.dart';
import 'package:image_picker/image_picker.dart';
import 'package:google_ml_kit/google_ml_kit.dart';
import '../database/database.dart';
import '../database/database_service.dart';
import '../services/ai_receipt_service.dart';

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

  // Convert Purchase (from database) to Einkauf
  factory Einkauf.fromPurchase(Purchase purchase) {
    return Einkauf(
      nr: purchase.nr ?? '',
      datum: purchase.datum,
      artikel: purchase.artikel,
      beschreibung: purchase.beschreibung ?? '',
      kategorie: purchase.kategorie,
      produktart: purchase.produktart ?? '',
      menge: purchase.menge,
      einheit: purchase.einheit ?? '',
      preis: purchase.preis,
      supermarkt: purchase.supermarkt ?? '',
      kommentar: purchase.kommentar ?? '',
      wer: purchase.wer ?? '',
    );
  }
}

class DashboardFromCSV extends StatefulWidget {
  @override
  _DashboardFromCSVState createState() => _DashboardFromCSVState();
}

class _DashboardFromCSVState extends State<DashboardFromCSV> {
  List<Einkauf> _einkaeufe = [];
  String status = 'Keine Daten geladen';
  bool zeigePreise = true;
  final DatabaseService _dbService = DatabaseService();
  final AIReceiptService _aiService = AIReceiptService();
  bool _isLoading = false;

  @override
  void initState() {
    super.initState();
    _loadPurchasesFromDB(); // Lade bestehende Daten aus der Datenbank
  }
  
  Future<void> _loadPurchasesFromDB() async {
    setState(() {
      _isLoading = true;
    });

    try {
      final purchases = await _dbService.database.getAllPurchases();
      
      // If database is empty, load data from CSV file
      if (purchases.isEmpty) {
        debugPrint("Database empty, loading CSV file");
        await _importDefaultCSV();
        // Reload after adding data from CSV
        final updatedPurchases = await _dbService.database.getAllPurchases();
        setState(() {
          _einkaeufe = updatedPurchases.map((p) => Einkauf.fromPurchase(p)).toList();
          status = 'CSV Daten geladen: ${_einkaeufe.length} Einträge';
          _isLoading = false;
        });
      } else {
        setState(() {
          _einkaeufe = purchases.map((p) => Einkauf.fromPurchase(p)).toList();
          status = 'Daten aus Datenbank geladen: ${_einkaeufe.length} Einträge';
          _isLoading = false;
        });
      }
    } catch (e) {
      setState(() {
        status = 'Fehler beim Laden: $e';
        _isLoading = false;
      });
    }
  }
  
  // Import default CSV file that's bundled with the app
  Future<void> _importDefaultCSV() async {
    try {
      final csvFile = File('Einkauf_2025.csv');
      if (await csvFile.exists()) {
        final purchases = await _dbService.csvToPurchases(csvFile.path);
        await _dbService.database.addMultiplePurchases(purchases);
        debugPrint("CSV file loaded: ${purchases.length} entries");
      } else {
        debugPrint("Default CSV file not found");
      }
    } catch (e) {
      debugPrint("Error loading default CSV: $e");
    }
  }

  Future<void> _pickFileAndParse() async {
    setState(() {
      _isLoading = true;
      status = 'CSV wird importiert...';
    });
    
    try {
      final count = await _dbService.importCSVFile();
      if (count > 0) {
        await _loadPurchasesFromDB();
        setState(() {
          status = '$count Einträge importiert';
        });
      } else {
        setState(() {
          status = 'Keine Daten importiert';
          _isLoading = false;
        });
      }
    } catch (e) {
      setState(() {
        status = 'Import fehlgeschlagen: $e';
        _isLoading = false;
      });
    }
  }

  Future<void> _exportToCSV() async {
    setState(() {
      _isLoading = true;
      status = 'Exportiere CSV...';
    });
    
    try {
      final filePath = await _dbService.exportToCSV();
      if (filePath != null) {
        setState(() {
          status = 'CSV exportiert nach: $filePath';
          _isLoading = false;
        });
      } else {
        setState(() {
          status = 'Export fehlgeschlagen';
          _isLoading = false;
        });
      }
    } catch (e) {
      setState(() {
        status = 'Export fehlgeschlagen: $e';
        _isLoading = false;
      });
    }
  }

  Future<void> _scanReceipt({ImageSource source = ImageSource.camera}) async {
    setState(() {
      _isLoading = true;
      status = source == ImageSource.camera 
          ? 'Kassenbon wird gescannt...' 
          : 'Kassenbon-Foto wird verarbeitet...';
    });
    
    try {
      final purchases = await _aiService.scanReceiptImage(source: source);
      
      if (purchases != null && purchases.isNotEmpty) {
        // Save to database
        await _dbService.database.addMultiplePurchases(purchases);
        await _loadPurchasesFromDB();
        
        setState(() {
          status = '${purchases.length} Einträge aus Kassenbon erkannt';
          _isLoading = false;
        });
        
        // Zeige die erkannten Einträge in einem Dialog an
        _showRecognizedItemsDialog(purchases);
      } else {
        setState(() {
          status = 'Keine Artikel erkannt. Der Kassenbon konnte nicht gelesen werden. Bitte versuchen Sie es mit einem anderen Foto oder besserer Belichtung.';
          _isLoading = false;
        });

        // Zeige Dialog mit Fehlermeldung
        showDialog(
          context: context,
          builder: (context) => AlertDialog(
            title: const Text('Keine Artikel erkannt'),
            content: const Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text('Der Kassenbon konnte nicht ausreichend gut gelesen werden.'),
                SizedBox(height: 12),
                Text('Tipps:'),
                Text('• Sorgen Sie für gute Beleuchtung'),
                Text('• Achten Sie auf hohen Kontrast'),
                Text('• Vermeiden Sie Schatten und Reflexionen'),
                Text('• Kassenbontext sollte deutlich sichtbar sein')
              ],
            ),
            actions: [
              TextButton(
                onPressed: () => Navigator.of(context).pop(),
                child: const Text('Verstanden'),
              ),
            ],
          ),
        );
      }
    } catch (e) {
      setState(() {
        status = 'Fehler bei der Verarbeitung: $e';
        _isLoading = false;
      });
    }
  }

  // Zeigt einen Dialog mit den erkannten Einträgen an
  void _showRecognizedItemsDialog(List<PurchasesCompanion> purchases) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Erkannte Artikel'),
        content: SizedBox(
          width: double.maxFinite,
          child: ListView.builder(
            shrinkWrap: true,
            itemCount: purchases.length,
            itemBuilder: (context, index) {
              final item = purchases[index];
              return ListTile(
                title: Text(item.artikel.value),
                subtitle: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text('Kategorie: ${item.kategorie.value}'),
                    Text('Supermarkt: ${item.supermarkt.value?.isNotEmpty == true ? item.supermarkt.value : "Unbekannt"}'),
                  ],
                ),
                trailing: Text(
                  '${item.menge.value} ${item.einheit.value} - ${item.preis.value.toStringAsFixed(2)}€',
                  style: const TextStyle(fontWeight: FontWeight.bold),
                ),
              );
            },
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(),
            child: const Text('Schließen'),
          ),
        ],
      ),
    );
  }

  Map<String, double> _berechneAusgabenNachProduktart() {
    final Map<String, double> ausgaben = {};
    for (var e in _einkaeufe) {
      if (e.produktart.toLowerCase() == 'nicht essbar') continue;
      final art = e.produktart.isEmpty ? 'Unbestimmt' : e.produktart;
      final wert = zeigePreise ? e.preis : 1.0;
      ausgaben[art] = (ausgaben[art] ?? 0) + wert;
    }
    
    // Sortieren und nur die Top 7 anzeigen, wie bei den Kategorien
    final sortedEntries = ausgaben.entries.toList()
      ..sort((a, b) => b.value.compareTo(a.value));
    
    final Map<String, double> topProductTypes = {};
    final int maxItems = ausgaben.length < 7 ? ausgaben.length : 7;
    
    for (int i = 0; i < maxItems; i++) {
      if (i < sortedEntries.length) {
        topProductTypes[sortedEntries[i].key] = sortedEntries[i].value;
      }
    }
    
    return topProductTypes;
  }

  List<PieChartSectionData> _buildPieChartSections() {
    final data = _berechneAusgabenNachProduktart();
    final total = data.values.fold(0.0, (sum, item) => sum + item);
    final labels = data.keys.toList();
    final values = data.values.toList();

    if (total == 0) return [];

    return List.generate(data.length, (i) {
      // Berechne den prozentualen Anteil für jede Sektion
      final percent = (values[i] / total * 100).toStringAsFixed(1);
      
      // Für kleine Sektionen zeige einfachere Beschriftung
      final isSmallSection = values[i] / total < 0.1; // weniger als 10%
      
      return PieChartSectionData(
        color: Colors.primaries[i % Colors.primaries.length],
        value: values[i],
        title: isSmallSection
            ? "$percent%" // Kleinen Sektionen nur den Prozentsatz zeigen
            : "${labels[i]}\n${values[i].toInt()}${zeigePreise ? '€' : ''}",
        radius: isSmallSection ? 80 : 90, // Kleinere Sektionen etwas kleiner machen
        titleStyle: TextStyle(
          fontSize: isSmallSection ? 12 : 16,
          fontWeight: FontWeight.bold,
          color: Colors.white
        ),
        titlePositionPercentageOffset: isSmallSection ? 0.6 : 0.5, // Kleine Sektionen nach außen schieben
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

  // Komplett neue Datenbank - wird für die Löschen-Funktion verwendet
  Future<void> _cleanStart() async {
    setState(() {
      _isLoading = true;
      status = 'Bereinige Datenbank...';
    });
    
    try {
      // Lösche alle vorherigen Daten
      await _dbService.database.deleteAllPurchases();
      
      setState(() {
        _einkaeufe = [];
        status = 'Datenbank bereinigt';
        _isLoading = false;
      });
    } catch (e) {
      setState(() {
        status = 'Fehler beim Bereinigen: $e';
        _isLoading = false;
      });
    }
  }

  // Bestätigungsdialog zum Löschen aller Daten anzeigen
  Future<void> _showClearConfirmDialog() async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Datenbank leeren'),
        content: const Text(
          'Sind Sie sicher, dass Sie alle Einträge aus der Datenbank löschen möchten? '
          'Dieser Vorgang kann nicht rückgängig gemacht werden.'
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(false),
            child: const Text('Abbrechen'),
          ),
          TextButton(
            onPressed: () => Navigator.of(context).pop(true),
            child: const Text('Löschen'),
          ),
        ],
      ),
    );
    
    if (confirmed == true) {
      await _cleanStart(); // Verwende die cleanStart-Methode statt direktem Löschen
    }
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
              const Text("Anzahl", style: TextStyle(fontSize: 12)),
              Switch(
                value: zeigePreise,
                onChanged: (val) {
                  setState(() {
                    zeigePreise = val;
                  });
                },
                activeColor: Colors.blue,
                activeTrackColor: Colors.blueAccent.withOpacity(0.5),
                inactiveThumbColor: Colors.blue,
                inactiveTrackColor: Colors.blueAccent.withOpacity(0.3),
              ),
              const Text("Preis €", style: TextStyle(fontSize: 12)),
              const SizedBox(width: 12),
            ],
          )
        ],
      ),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : Padding(
              padding: const EdgeInsets.all(16.0),
              child: SingleChildScrollView(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // Action buttons
                    Wrap(
                      spacing: 8,
                      runSpacing: 8,
                      children: [
                        PopupMenuButton<String>(
                          onSelected: (value) {
                            if (value == 'import') {
                              _pickFileAndParse();
                            } else if (value == 'export') {
                              _exportToCSV();
                            } else if (value == 'clear') {
                              _showClearConfirmDialog();
                            }
                          },
                          itemBuilder: (context) => [
                            const PopupMenuItem(
                              value: 'import',
                              child: Text('CSV importieren'),
                            ),
                            const PopupMenuItem(
                              value: 'export',
                              child: Text('CSV exportieren'),
                            ),
                            const PopupMenuItem(
                              value: 'clear',
                              child: Text('Datenbank leeren'),
                            ),
                          ],
                          child: ElevatedButton(
                            onPressed: null,
                            child: const Row(
                              mainAxisSize: MainAxisSize.min,
                              children: [
                                Text('CSV'),
                                Icon(Icons.arrow_drop_down),
                              ],
                            ),
                          ),
                        ),
                        ElevatedButton(
                          onPressed: () => _scanReceipt(source: ImageSource.camera),
                          child: const Text("Bon Scan"),
                        ),
                        ElevatedButton(
                          onPressed: () => _scanReceipt(source: ImageSource.gallery),
                          child: const Text("Bon Foto"),
                        ),
                      ],
                    ),
                    const SizedBox(height: 12),
                    Text(status),
                    const SizedBox(height: 24),
                    if (_einkaeufe.isNotEmpty) ...[
                      // Liste der Einkäufe
                      const Text("Einkaufsliste", style: TextStyle(fontWeight: FontWeight.bold, fontSize: 18)),
                      const SizedBox(height: 12),
                      Container(
                        decoration: BoxDecoration(
                          border: Border.all(color: Colors.grey),
                          borderRadius: BorderRadius.circular(8),
                        ),
                        height: 200,
                        child: ListView.builder(
                          itemCount: _einkaeufe.length,
                          itemBuilder: (context, index) {
                            final item = _einkaeufe[index];
                            return ListTile(
                              dense: true,
                              title: Row(
                                children: [
                                  Expanded(child: Text(item.artikel)),
                                  Text(
                                    item.datum,
                                    style: TextStyle(
                                      fontSize: 12,
                                      color: Colors.grey[600],
                                    ),
                                  ),
                                ],
                              ),
                              subtitle: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text('${item.kategorie} - ${item.produktart}'),
                                  Text(
                                    'Supermarkt: ${item.supermarkt}', 
                                    style: TextStyle(
                                      fontSize: 12,
                                      fontStyle: FontStyle.italic,
                                      color: Colors.grey[600],
                                    ),
                                  ),
                                ],
                              ),
                              trailing: Text(
                                '${item.menge} ${item.einheit} - ${item.preis.toStringAsFixed(2)}€',
                                style: const TextStyle(fontWeight: FontWeight.bold),
                              ),
                              isThreeLine: true,
                            );
                          },
                        ),
                      ),
                      const SizedBox(height: 24),
                      const Text("Ausgaben nach Produktart"),
                      const SizedBox(height: 12),
                      SizedBox(
                        height: 300,
                        child: Center(
                          child: PieChart(
                            PieChartData(
                              sections: _buildPieChartSections(),
                              sectionsSpace: 2,
                              centerSpaceRadius: 60,
                            ),
                          ),
                        ),
                      ),
                      const SizedBox(height: 24),
                      Text("Top 7 Kategorien nach ${zeigePreise ? 'Ausgaben' : 'Anzahl'}"),
                      const SizedBox(height: 12),
                      SizedBox(
                        height: 300,
                        child: Center(
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
                              ),
                              borderData: FlBorderData(show: false),
                              gridData: FlGridData(show: true),
                              alignment: BarChartAlignment.center,
                              maxY: _berechneTopKategorien().values.fold(0.0, (prev, elem) => elem > prev ? elem : prev) * 1.2,
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
                            ),
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
