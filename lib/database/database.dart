import 'dart:io';

import 'package:drift/drift.dart';
import 'package:drift/native.dart';
import 'package:path_provider/path_provider.dart';
import 'package:path/path.dart' as p;

part 'database.g.dart';

class Purchases extends Table {
  IntColumn get id => integer().autoIncrement()();
  TextColumn get nr => text().nullable()();
  TextColumn get datum => text()();
  TextColumn get artikel => text()();
  TextColumn get beschreibung => text().nullable()();
  TextColumn get kategorie => text()();
  TextColumn get produktart => text().nullable()();
  RealColumn get menge => real()();
  TextColumn get einheit => text().nullable()();
  RealColumn get preis => real()();
  TextColumn get supermarkt => text().nullable()();
  TextColumn get kommentar => text().nullable()();
  TextColumn get wer => text().nullable()();
}

LazyDatabase _openConnection() {
  return LazyDatabase(() async {
    final dbFolder = await getApplicationDocumentsDirectory();
    final file = File(p.join(dbFolder.path, 'einkaufsdaten.sqlite'));
    return NativeDatabase(file);
  });
}

@DriftDatabase(tables: [Purchases])
class AppDatabase extends _$AppDatabase {
  AppDatabase() : super(_openConnection());

  @override
  int get schemaVersion => 1;

  // Get all purchases
  Future<List<Purchase>> getAllPurchases() => select(purchases).get();

  // Add a new purchase
  Future<int> addPurchase(PurchasesCompanion purchase) => 
      into(purchases).insert(purchase);

  // Add multiple purchases
  Future<void> addMultiplePurchases(List<PurchasesCompanion> items) async {
    await batch((batch) {
      batch.insertAll(purchases, items);
    });
  }

  // Update a purchase
  Future<bool> updatePurchase(Purchase purchase) => 
      update(purchases).replace(purchase);

  // Delete a purchase
  Future<int> deletePurchase(int id) => 
      (delete(purchases)..where((p) => p.id.equals(id))).go();

  // Delete all purchases
  Future<int> deleteAllPurchases() => delete(purchases).go();
} 