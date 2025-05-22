import 'dart:convert';
import 'dart:io';
import 'dart:typed_data';
import 'package:flutter/material.dart';
import 'package:google_ml_kit/google_ml_kit.dart';
import 'package:http/http.dart' as http;
import 'package:drift/drift.dart' as drift;
import 'package:image_picker/image_picker.dart';
import 'package:flutter_image_compress/flutter_image_compress.dart';
import 'package:path/path.dart' as p;
import 'package:path_provider/path_provider.dart';
import '../database/database.dart';

class AIReceiptService {
  static final AIReceiptService _instance = AIReceiptService._internal();

  factory AIReceiptService() {
    return _instance;
  }

  AIReceiptService._internal();

  // Process receipt image with local OCR
  Future<String> recognizeText(String imagePath) async {
    try {
      debugPrint("Starting OCR on image: $imagePath");
      
      // Extra Prüfung, ob die Datei existiert und lesbar ist
      final File imageFile = File(imagePath);
      if (!await imageFile.exists()) {
        debugPrint("OCR Error: Bilddatei existiert nicht: $imagePath");
        return ""; // Keine Beispieldaten, einfach leeren String zurückgeben
      }
      
      try {
        // Bei Problemen mit der Datei, Kopie erstellen an bekanntem Ort
        final Directory tempDir = await getTemporaryDirectory();
        final String targetPath = p.join(tempDir.path, 'receipt_image_${DateTime.now().millisecondsSinceEpoch}.jpg');
        await imageFile.copy(targetPath);
        
        debugPrint("Kopierte Datei erstellt: $targetPath");
        final inputImage = InputImage.fromFilePath(targetPath);
        final textRecognizer = TextRecognizer();
        
        try {
          final RecognizedText recognizedText = await textRecognizer.processImage(inputImage);
          final String text = recognizedText.text;
          
          debugPrint("OCR completed. Text blocks found: ${recognizedText.blocks.length}");
          
          // Output recognized text for debugging
          if (text.isNotEmpty) {
            debugPrint("=== START OCR TEXT ===");
            debugPrint(text);
            debugPrint("=== END OCR TEXT ===");
            
            return text;
          } else {
            debugPrint("No text recognized in image");
            return ""; // Keine Beispieldaten, einfach leeren String zurückgeben
          }
        } finally {
          textRecognizer.close();
        }
      } catch (e) {
        debugPrint("OCR processing error: $e");
        return ""; // Keine Beispieldaten, einfach leeren String zurückgeben
      }
    } catch (e) {
      debugPrint("OCR Error: $e");
      return ""; // Keine Beispieldaten, einfach leeren String zurückgeben
    }
  }
  
  // Testdaten für die Entwicklung/Tests zurückgeben - wird nicht mehr verwendet
  String _getMockReceiptText() {
    debugPrint("Verwende Testdaten für Kassenbon");
    return '''
REWE
Datum: 15.05.2023

Milch 3,5%               1,19 €
Butter                   2,49 €
Eier Freilandhaltung     2,29 €
Brot Vollkorn            2,99 €
Käse Gouda 200g          2,49 €
Joghurt                  0,89 €
Bananen 1kg              1,99 €
Äpfel 2kg                3,98 €

SUMME                   18,31 €
''';
  }

  // Enhance receipt data with AI (mock implementation)
  // In a real app, you would replace this with an actual API call to an LLM
  Future<List<PurchasesCompanion>> enhanceReceiptWithAI(String receiptText, {String supermarkt = ''}) async {
    // In a real implementation, you'd send the text to an API like OpenAI
    // For now, we'll use a simpler approach with regular expressions
    
    List<PurchasesCompanion> results = [];
    int counter = 1;
    String currentDate = DateTime.now().toString().split(' ')[0];
    
    // Split text into lines
    List<String> lines = receiptText.split('\n');
    
    // Look for date formats in the receipt
    RegExp datePattern = RegExp(r'(\d{2}[\/\.-]\d{2}[\/\.-]\d{2,4})');
    for (String line in lines) {
      final dateMatch = datePattern.firstMatch(line);
      if (dateMatch != null) {
        currentDate = dateMatch.group(0)!;
        break;
      }
    }
    
    // Look for store name patterns
    if (supermarkt.isEmpty) {
      for (String line in lines) {
        if (line.toUpperCase().contains('REWE')) {
          supermarkt = 'REWE';
          break;
        } else if (line.toUpperCase().contains('ALDI')) {
          supermarkt = 'ALDI';
          break;
        } else if (line.toUpperCase().contains('LIDL')) {
          supermarkt = 'LIDL';
          break;
        } else if (line.toUpperCase().contains('EDEKA')) {
          supermarkt = 'EDEKA';
          break;
        } else if (line.toUpperCase().contains('PENNY')) {
          supermarkt = 'PENNY';
          break;
        } else if (line.toUpperCase().contains('NETTO')) {
          supermarkt = 'NETTO';
          break;
        }
      }
    }

    // Print recognized text for debugging
    debugPrint("OCR Result: $receiptText");
    
    // Various patterns to match items in receipts
    List<RegExp> itemPatterns = [
      // Pattern: Product followed by price (e.g. "Bread 3,45 €" or "Milk 1.99€")
      RegExp(r'([A-Za-zÀ-ÿ\s\-\d\.]+([\d,]+\s*x)?\s+)([\d.,]+)\s*[€$]'),
      
      // Pattern: Product with quantity followed by price (e.g. "2 x Milk 3,90 €")
      RegExp(r'(\d+\s*[xX]\s*[A-Za-zÀ-ÿ\s\-\.]+)(\d+,\d+|\d+\.\d+)\s*[€$]'),
      
      // Pattern: Product, then price and currency together (e.g. "Milk 3,90€")
      RegExp(r'([A-Za-zÀ-ÿ\s\-]+)\s+([\d.,]+)€'),
      
      // Pattern: Digit at beginning, product name, then price (e.g. "1 Milk 3,90€")
      RegExp(r'\d+\s+([A-Za-zÀ-ÿ\s\-]+)\s+([\d.,]+)[€$]'),
    ];
    
    for (String line in lines) {
      bool matched = false;
      
      // Skip lines that are likely totals or not product items
      if (line.toUpperCase().contains('SUMME') || 
          line.toUpperCase().contains('GESAMT') ||
          line.toUpperCase().contains('TOTAL')) {
        continue;
      }
      
      for (var pattern in itemPatterns) {
        final matches = pattern.allMatches(line);
        for (var match in matches) {
          String artikel = '';
          String preisStr = '';
          
          if (pattern.pattern.startsWith(r'([A-Za-zÀ-ÿ\s\-\d\.]+([\d,]+\s*x)?\s+)')) {
            artikel = match.group(1)?.trim() ?? '';
            preisStr = match.group(3)?.replaceAll(',', '.') ?? '0.0';
          } else if (pattern.pattern.startsWith(r'(\d+\s*[xX]\s*')) {
            artikel = match.group(1)?.trim() ?? '';
            preisStr = match.group(2)?.replaceAll(',', '.') ?? '0.0';
          } else if (pattern.pattern.startsWith(r'([A-Za-zÀ-ÿ\s\-]+)\s+')) {
            artikel = match.group(1)?.trim() ?? '';
            preisStr = match.group(2)?.replaceAll(',', '.') ?? '0.0';
          } else if (pattern.pattern.startsWith(r'\d+\s+')) {
            artikel = match.group(1)?.trim() ?? '';
            preisStr = match.group(2)?.replaceAll(',', '.') ?? '0.0';
          }
            
          // Clean up article name
          artikel = artikel.replaceAll(RegExp(r'\d+\s*x\s*'), '');
          
          double preis = double.tryParse(preisStr) ?? 0.0;
          double menge = 1.0;
          
          // Try to extract quantity
          RegExp quantityPattern = RegExp(r'(\d+,?\d*)\s*x');
          final quantityMatch = quantityPattern.firstMatch(line);
          if (quantityMatch != null) {
            String quantityStr = quantityMatch.group(1)?.replaceAll(',', '.') ?? '1.0';
            menge = double.tryParse(quantityStr) ?? 1.0;
          }
          
          if (artikel.isNotEmpty && preis > 0) {
            // Skip very short article names that might be mismatches
            if (artikel.length < 2) continue;
            
            debugPrint("Found item: $artikel, price: $preis");
            
            results.add(PurchasesCompanion(
              nr: drift.Value('${counter++}'),
              datum: drift.Value(currentDate),
              artikel: drift.Value(artikel),
              beschreibung: drift.Value(artikel),
              kategorie: drift.Value('Unbestimmt'), // We'd need AI to categorize these
              produktart: drift.Value('Unbestimmt'),
              menge: drift.Value(menge),
              einheit: drift.Value('Stk'),
              preis: drift.Value(preis),
              supermarkt: drift.Value(supermarkt),
              kommentar: drift.Value('Auto-erkannt'),
              wer: drift.Value(''),
            ));
            matched = true;
            break;
          }
        }
        if (matched) break;
      }
    }
    
    return results;
  }

  // Check if a file is HEIC format based on content, not just extension
  Future<bool> isHeicFormat(String filePath) async {
    try {
      final File file = File(filePath);
      if (!await file.exists()) {
        return false;
      }
      
      // Read the first bytes to identify file type
      final RandomAccessFile raf = await file.open(mode: FileMode.read);
      final Uint8List header = await raf.read(12);
      await raf.close();
      
      // Check for HEIC format signature
      // HEIC files typically start with 'ftyp' at position 4
      if (header.length > 8 && 
          header[4] == 0x66 && // f
          header[5] == 0x74 && // t
          header[6] == 0x79 && // y
          header[7] == 0x70) { // p
        
        // Check for specific HEIC brand types
        if (header.length > 11 && 
            (header[8] == 0x68 && header[9] == 0x65 && header[10] == 0x69 && header[11] == 0x63) || // heic
            (header[8] == 0x68 && header[9] == 0x65 && header[10] == 0x69 && header[11] == 0x78) || // heix
            (header[8] == 0x6D && header[9] == 0x69 && header[10] == 0x66) || // mif (HEIC brand)
            (header[8] == 0x68 && header[9] == 0x65 && header[10] == 0x76 && header[11] == 0x63)) { // hevc
          return true;
        }
      }
      
      return false;
    } catch (e) {
      debugPrint("Error checking HEIC format: $e");
      // Fall back to extension check if binary check fails
      final String ext = p.extension(filePath).toLowerCase();
      return ext == '.heic' || ext == '.heif';
    }
  }

  // Convert HEIC to JPEG
  Future<String?> convertHeicToJpeg(String heicPath) async {
    try {
      // Get temp directory
      final dir = await getTemporaryDirectory();
      final targetPath = p.join(dir.path, '${DateTime.now().millisecondsSinceEpoch}.jpg');
      
      // Try FlutterImageCompress first
      try {
        final result = await FlutterImageCompress.compressAndGetFile(
          heicPath,
          targetPath,
          format: CompressFormat.jpeg,
          quality: 90,
        );
        
        if (result != null) {
          return result.path;
        }
      } catch (e) {
        debugPrint("First conversion method failed: $e");
      }
      
      // If that fails, try a direct copy for devices that might auto-convert
      try {
        final File originalFile = File(heicPath);
        final File jpegFile = File(targetPath);
        await originalFile.copy(targetPath);
        
        if (await jpegFile.exists() && await jpegFile.length() > 0) {
          return targetPath;
        }
      } catch (e) {
        debugPrint("Second conversion method failed: $e");
      }
      
      // If all methods fail, return null
      return null;
    } catch (e) {
      debugPrint("Error in HEIC conversion: $e");
      return null;
    }
  }

  // Full receipt scanning workflow
  Future<List<PurchasesCompanion>?> scanReceiptImage({ImageSource source = ImageSource.camera}) async {
    try {
      final ImagePicker picker = ImagePicker();
      // Try to request a JPEG directly when picking
      final XFile? image = await picker.pickImage(
        source: source,
        imageQuality: 85, // Compress slightly
      );
      
      if (image == null) {
        debugPrint("No image selected");
        return null;
      }
      
      debugPrint("Image picked: ${image.path}");
      
      // Check if the file exists
      final File imageFile = File(image.path);
      if (!await imageFile.exists()) {
        debugPrint("Image file does not exist");
        return null;
      }
      
      String imagePath = image.path;
      
      // Handle HEIC images
      final bool isHeic = await isHeicFormat(imagePath);
      if (isHeic) {
        debugPrint("HEIC format detected: $imagePath");
        final String? convertedPath = await convertHeicToJpeg(imagePath);
        
        if (convertedPath != null) {
          imagePath = convertedPath;
          debugPrint("HEIC conversion successful: $imagePath");
        } else {
          debugPrint("HEIC conversion failed, continuing with original");
        }
      } else {
        debugPrint("Not a HEIC image: $imagePath");
      }
      
      // Process receipt with OCR
      debugPrint("Starting OCR processing on: $imagePath");
      final String recognizedText = await recognizeText(imagePath);
      
      if (recognizedText.isEmpty) {
        debugPrint("No text recognized in the image");
        return null;
      } else {
        debugPrint("Text recognized. Length: ${recognizedText.length} chars");
      }
      
      // Process the recognized text with AI enhancement
      return await enhanceReceiptWithAI(recognizedText);
    } catch (e) {
      debugPrint("Receipt scanning error: $e");
      return null;
    }
  }

  // Call to a real LLM API (commented out since it requires API keys)
  /*
  Future<List<PurchasesCompanion>> processWithLLM(String receiptText) async {
    try {
      final response = await http.post(
        Uri.parse('https://api.openai.com/v1/chat/completions'),
        headers: {
          'Content-Type': 'application/json',
          'Authorization': 'Bearer YOUR_API_KEY', // Replace with actual API key
        },
        body: jsonEncode({
          'model': 'gpt-4',
          'messages': [
            {
              'role': 'system',
              'content': 'Extract purchase items from this receipt into JSON format with fields: artikel, beschreibung, menge, preis, einheit. Kategorize items if possible.'
            },
            {
              'role': 'user',
              'content': receiptText
            }
          ],
          'temperature': 0.7,
        }),
      );

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        final content = data['choices'][0]['message']['content'];
        
        // Parse JSON from LLM response
        final extractedData = jsonDecode(content);
        List<PurchasesCompanion> results = [];
        
        // Convert JSON to PurchasesCompanion objects
        int counter = 1;
        for (var item in extractedData) {
          results.add(PurchasesCompanion(
            nr: drift.Value('${counter++}'),
            datum: drift.Value(DateTime.now().toString().split(' ')[0]),
            artikel: drift.Value(item['artikel'] ?? ''),
            beschreibung: drift.Value(item['beschreibung'] ?? ''),
            kategorie: drift.Value(item['kategorie'] ?? 'Unbestimmt'),
            produktart: drift.Value(item['produktart'] ?? 'Unbestimmt'),
            menge: drift.Value(double.tryParse(item['menge'].toString()) ?? 1.0),
            einheit: drift.Value(item['einheit'] ?? 'Stk'),
            preis: drift.Value(double.tryParse(item['preis'].toString()) ?? 0.0),
            supermarkt: drift.Value(item['supermarkt'] ?? ''),
            kommentar: drift.Value('AI erkannt'),
            wer: drift.Value(''),
          ));
        }
        
        return results;
      } else {
        throw Exception('Failed to process with LLM: ${response.statusCode}');
      }
    } catch (e) {
      debugPrint('LLM processing error: $e');
      return [];
    }
  }
  */
} 