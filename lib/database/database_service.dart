import 'dart:io';
import 'package:csv/csv.dart';
import 'package:drift/drift.dart' as drift;
import 'package:file_picker/file_picker.dart';
import 'package:path_provider/path_provider.dart';
import 'package:path/path.dart' as p;
import 'database.dart';

class DatabaseService {
  late final AppDatabase _database;
  static final DatabaseService _instance = DatabaseService._internal();

  // Singleton pattern
  factory DatabaseService() {
    return _instance;
  }

  DatabaseService._internal() {
    _database = AppDatabase();
  }

  AppDatabase get database => _database;

  // Convert CSV file to Purchases
  Future<List<PurchasesCompanion>> csvToPurchases(String filePath) async {
    final file = File(filePath);
    final content = await file.readAsString();
    final csvRows = const CsvToListConverter(fieldDelimiter: ';', eol: '\n').convert(content);

    // Remove header row if it exists
    if (csvRows.isNotEmpty) csvRows.removeAt(0);

    List<PurchasesCompanion> purchases = [];
    for (var row in csvRows) {
      if (row.length >= 12) {
        purchases.add(PurchasesCompanion(
          nr: drift.Value(row[0]?.toString()),
          datum: drift.Value(row[1]?.toString() ?? ''),
          artikel: drift.Value(row[2]?.toString() ?? ''),
          beschreibung: drift.Value(row[3]?.toString()),
          kategorie: drift.Value(row[4]?.toString() ?? ''),
          produktart: drift.Value(row[5]?.toString()),
          menge: drift.Value(double.tryParse(row[6]?.toString().replaceAll(',', '.') ?? '') ?? 0.0),
          einheit: drift.Value(row[7]?.toString()),
          preis: drift.Value(double.tryParse(row[8]?.toString().replaceAll(',', '.') ?? '') ?? 0.0),
          supermarkt: drift.Value(row[9]?.toString()),
          kommentar: drift.Value(row[10]?.toString()),
          wer: drift.Value(row[11]?.toString()),
        ));
      }
    }
    return purchases;
  }

  // Import CSV file to database
  Future<int> importCSVFile() async {
    FilePickerResult? result = await FilePicker.platform.pickFiles();
    if (result != null) {
      final purchases = await csvToPurchases(result.files.single.path!);
      await _database.addMultiplePurchases(purchases);
      return purchases.length;
    }
    return 0;
  }

  // Export database to CSV file
  Future<String?> exportToCSV() async {
    try {
      final purchases = await _database.getAllPurchases();
      
      // Prepare CSV data
      List<List<dynamic>> csvData = [
        ['Nr', 'Datum', 'Artikel', 'Artikelbeschreibung', 'Kategorie', 'Produktart', 
         'Menge', 'Einheit', 'Preis (€)', 'Supermarkt', 'Kommentar', 'Wer']
      ];
      
      for (var item in purchases) {
        csvData.add([
          item.nr,
          item.datum,
          item.artikel,
          item.beschreibung,
          item.kategorie,
          item.produktart,
          item.menge.toString().replaceAll('.', ','),
          item.einheit,
          item.preis.toString().replaceAll('.', ','),
          item.supermarkt,
          item.kommentar,
          item.wer,
        ]);
      }
      
      // Convert to CSV string
      String csv = const ListToCsvConverter(fieldDelimiter: ';').convert(csvData);
      
      // Write to file
      final directory = await getApplicationDocumentsDirectory();
      final filePath = p.join(directory.path, 'Einkauf_${DateTime.now().year}.csv');
      final file = File(filePath);
      await file.writeAsString(csv);
      
      return filePath;
    } catch (e) {
      print('Error exporting to CSV: $e');
      return null;
    }
  }

  // Get purchases grouped by product type
  Future<Map<String, double>> getAusgabenNachProduktart(bool zeigePreise) async {
    final purchases = await _database.getAllPurchases();
    final Map<String, double> ausgaben = {};
    
    for (var e in purchases) {
      if (e.produktart?.toLowerCase() == 'nicht essbar') continue;
      final art = e.produktart?.isEmpty ?? true ? 'Unbestimmt' : e.produktart!;
      final wert = zeigePreise ? e.preis : 1.0;
      ausgaben[art] = (ausgaben[art] ?? 0) + wert;
    }
    
    return ausgaben;
  }

  // Get purchases grouped by category
  Future<Map<String, double>> getTopKategorien(bool zeigePreise) async {
    final purchases = await _database.getAllPurchases();
    final Map<String, double> ausgaben = {};
    
    for (var e in purchases) {
      final wert = zeigePreise ? e.preis : 1.0;
      ausgaben[e.kategorie] = (ausgaben[e.kategorie] ?? 0) + wert;
    }
    
    // Sort and limit to top 7
    final sortedEntries = ausgaben.entries.toList()
      ..sort((a, b) => b.value.compareTo(a.value));
    
    final Map<String, double> topCategories = {};
    final int maxCategories = ausgaben.length < 7 ? ausgaben.length : 7;
    
    for (int i = 0; i < maxCategories; i++) {
      topCategories[sortedEntries[i].key] = sortedEntries[i].value;
    }
    
    return topCategories;
  }
} 