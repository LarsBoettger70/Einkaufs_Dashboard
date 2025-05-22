// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'database.dart';

// ignore_for_file: type=lint
class $PurchasesTable extends Purchases
    with TableInfo<$PurchasesTable, Purchase> {
  @override
  final GeneratedDatabase attachedDatabase;
  final String? _alias;
  $PurchasesTable(this.attachedDatabase, [this._alias]);
  static const VerificationMeta _idMeta = const VerificationMeta('id');
  @override
  late final GeneratedColumn<int> id = GeneratedColumn<int>(
    'id',
    aliasedName,
    false,
    hasAutoIncrement: true,
    type: DriftSqlType.int,
    requiredDuringInsert: false,
    defaultConstraints: GeneratedColumn.constraintIsAlways(
      'PRIMARY KEY AUTOINCREMENT',
    ),
  );
  static const VerificationMeta _nrMeta = const VerificationMeta('nr');
  @override
  late final GeneratedColumn<String> nr = GeneratedColumn<String>(
    'nr',
    aliasedName,
    true,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _datumMeta = const VerificationMeta('datum');
  @override
  late final GeneratedColumn<String> datum = GeneratedColumn<String>(
    'datum',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _artikelMeta = const VerificationMeta(
    'artikel',
  );
  @override
  late final GeneratedColumn<String> artikel = GeneratedColumn<String>(
    'artikel',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _beschreibungMeta = const VerificationMeta(
    'beschreibung',
  );
  @override
  late final GeneratedColumn<String> beschreibung = GeneratedColumn<String>(
    'beschreibung',
    aliasedName,
    true,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _kategorieMeta = const VerificationMeta(
    'kategorie',
  );
  @override
  late final GeneratedColumn<String> kategorie = GeneratedColumn<String>(
    'kategorie',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _produktartMeta = const VerificationMeta(
    'produktart',
  );
  @override
  late final GeneratedColumn<String> produktart = GeneratedColumn<String>(
    'produktart',
    aliasedName,
    true,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _mengeMeta = const VerificationMeta('menge');
  @override
  late final GeneratedColumn<double> menge = GeneratedColumn<double>(
    'menge',
    aliasedName,
    false,
    type: DriftSqlType.double,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _einheitMeta = const VerificationMeta(
    'einheit',
  );
  @override
  late final GeneratedColumn<String> einheit = GeneratedColumn<String>(
    'einheit',
    aliasedName,
    true,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _preisMeta = const VerificationMeta('preis');
  @override
  late final GeneratedColumn<double> preis = GeneratedColumn<double>(
    'preis',
    aliasedName,
    false,
    type: DriftSqlType.double,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _supermarktMeta = const VerificationMeta(
    'supermarkt',
  );
  @override
  late final GeneratedColumn<String> supermarkt = GeneratedColumn<String>(
    'supermarkt',
    aliasedName,
    true,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _kommentarMeta = const VerificationMeta(
    'kommentar',
  );
  @override
  late final GeneratedColumn<String> kommentar = GeneratedColumn<String>(
    'kommentar',
    aliasedName,
    true,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _werMeta = const VerificationMeta('wer');
  @override
  late final GeneratedColumn<String> wer = GeneratedColumn<String>(
    'wer',
    aliasedName,
    true,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
  );
  @override
  List<GeneratedColumn> get $columns => [
    id,
    nr,
    datum,
    artikel,
    beschreibung,
    kategorie,
    produktart,
    menge,
    einheit,
    preis,
    supermarkt,
    kommentar,
    wer,
  ];
  @override
  String get aliasedName => _alias ?? actualTableName;
  @override
  String get actualTableName => $name;
  static const String $name = 'purchases';
  @override
  VerificationContext validateIntegrity(
    Insertable<Purchase> instance, {
    bool isInserting = false,
  }) {
    final context = VerificationContext();
    final data = instance.toColumns(true);
    if (data.containsKey('id')) {
      context.handle(_idMeta, id.isAcceptableOrUnknown(data['id']!, _idMeta));
    }
    if (data.containsKey('nr')) {
      context.handle(_nrMeta, nr.isAcceptableOrUnknown(data['nr']!, _nrMeta));
    }
    if (data.containsKey('datum')) {
      context.handle(
        _datumMeta,
        datum.isAcceptableOrUnknown(data['datum']!, _datumMeta),
      );
    } else if (isInserting) {
      context.missing(_datumMeta);
    }
    if (data.containsKey('artikel')) {
      context.handle(
        _artikelMeta,
        artikel.isAcceptableOrUnknown(data['artikel']!, _artikelMeta),
      );
    } else if (isInserting) {
      context.missing(_artikelMeta);
    }
    if (data.containsKey('beschreibung')) {
      context.handle(
        _beschreibungMeta,
        beschreibung.isAcceptableOrUnknown(
          data['beschreibung']!,
          _beschreibungMeta,
        ),
      );
    }
    if (data.containsKey('kategorie')) {
      context.handle(
        _kategorieMeta,
        kategorie.isAcceptableOrUnknown(data['kategorie']!, _kategorieMeta),
      );
    } else if (isInserting) {
      context.missing(_kategorieMeta);
    }
    if (data.containsKey('produktart')) {
      context.handle(
        _produktartMeta,
        produktart.isAcceptableOrUnknown(data['produktart']!, _produktartMeta),
      );
    }
    if (data.containsKey('menge')) {
      context.handle(
        _mengeMeta,
        menge.isAcceptableOrUnknown(data['menge']!, _mengeMeta),
      );
    } else if (isInserting) {
      context.missing(_mengeMeta);
    }
    if (data.containsKey('einheit')) {
      context.handle(
        _einheitMeta,
        einheit.isAcceptableOrUnknown(data['einheit']!, _einheitMeta),
      );
    }
    if (data.containsKey('preis')) {
      context.handle(
        _preisMeta,
        preis.isAcceptableOrUnknown(data['preis']!, _preisMeta),
      );
    } else if (isInserting) {
      context.missing(_preisMeta);
    }
    if (data.containsKey('supermarkt')) {
      context.handle(
        _supermarktMeta,
        supermarkt.isAcceptableOrUnknown(data['supermarkt']!, _supermarktMeta),
      );
    }
    if (data.containsKey('kommentar')) {
      context.handle(
        _kommentarMeta,
        kommentar.isAcceptableOrUnknown(data['kommentar']!, _kommentarMeta),
      );
    }
    if (data.containsKey('wer')) {
      context.handle(
        _werMeta,
        wer.isAcceptableOrUnknown(data['wer']!, _werMeta),
      );
    }
    return context;
  }

  @override
  Set<GeneratedColumn> get $primaryKey => {id};
  @override
  Purchase map(Map<String, dynamic> data, {String? tablePrefix}) {
    final effectivePrefix = tablePrefix != null ? '$tablePrefix.' : '';
    return Purchase(
      id:
          attachedDatabase.typeMapping.read(
            DriftSqlType.int,
            data['${effectivePrefix}id'],
          )!,
      nr: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}nr'],
      ),
      datum:
          attachedDatabase.typeMapping.read(
            DriftSqlType.string,
            data['${effectivePrefix}datum'],
          )!,
      artikel:
          attachedDatabase.typeMapping.read(
            DriftSqlType.string,
            data['${effectivePrefix}artikel'],
          )!,
      beschreibung: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}beschreibung'],
      ),
      kategorie:
          attachedDatabase.typeMapping.read(
            DriftSqlType.string,
            data['${effectivePrefix}kategorie'],
          )!,
      produktart: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}produktart'],
      ),
      menge:
          attachedDatabase.typeMapping.read(
            DriftSqlType.double,
            data['${effectivePrefix}menge'],
          )!,
      einheit: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}einheit'],
      ),
      preis:
          attachedDatabase.typeMapping.read(
            DriftSqlType.double,
            data['${effectivePrefix}preis'],
          )!,
      supermarkt: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}supermarkt'],
      ),
      kommentar: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}kommentar'],
      ),
      wer: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}wer'],
      ),
    );
  }

  @override
  $PurchasesTable createAlias(String alias) {
    return $PurchasesTable(attachedDatabase, alias);
  }
}

class Purchase extends DataClass implements Insertable<Purchase> {
  final int id;
  final String? nr;
  final String datum;
  final String artikel;
  final String? beschreibung;
  final String kategorie;
  final String? produktart;
  final double menge;
  final String? einheit;
  final double preis;
  final String? supermarkt;
  final String? kommentar;
  final String? wer;
  const Purchase({
    required this.id,
    this.nr,
    required this.datum,
    required this.artikel,
    this.beschreibung,
    required this.kategorie,
    this.produktart,
    required this.menge,
    this.einheit,
    required this.preis,
    this.supermarkt,
    this.kommentar,
    this.wer,
  });
  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    map['id'] = Variable<int>(id);
    if (!nullToAbsent || nr != null) {
      map['nr'] = Variable<String>(nr);
    }
    map['datum'] = Variable<String>(datum);
    map['artikel'] = Variable<String>(artikel);
    if (!nullToAbsent || beschreibung != null) {
      map['beschreibung'] = Variable<String>(beschreibung);
    }
    map['kategorie'] = Variable<String>(kategorie);
    if (!nullToAbsent || produktart != null) {
      map['produktart'] = Variable<String>(produktart);
    }
    map['menge'] = Variable<double>(menge);
    if (!nullToAbsent || einheit != null) {
      map['einheit'] = Variable<String>(einheit);
    }
    map['preis'] = Variable<double>(preis);
    if (!nullToAbsent || supermarkt != null) {
      map['supermarkt'] = Variable<String>(supermarkt);
    }
    if (!nullToAbsent || kommentar != null) {
      map['kommentar'] = Variable<String>(kommentar);
    }
    if (!nullToAbsent || wer != null) {
      map['wer'] = Variable<String>(wer);
    }
    return map;
  }

  PurchasesCompanion toCompanion(bool nullToAbsent) {
    return PurchasesCompanion(
      id: Value(id),
      nr: nr == null && nullToAbsent ? const Value.absent() : Value(nr),
      datum: Value(datum),
      artikel: Value(artikel),
      beschreibung:
          beschreibung == null && nullToAbsent
              ? const Value.absent()
              : Value(beschreibung),
      kategorie: Value(kategorie),
      produktart:
          produktart == null && nullToAbsent
              ? const Value.absent()
              : Value(produktart),
      menge: Value(menge),
      einheit:
          einheit == null && nullToAbsent
              ? const Value.absent()
              : Value(einheit),
      preis: Value(preis),
      supermarkt:
          supermarkt == null && nullToAbsent
              ? const Value.absent()
              : Value(supermarkt),
      kommentar:
          kommentar == null && nullToAbsent
              ? const Value.absent()
              : Value(kommentar),
      wer: wer == null && nullToAbsent ? const Value.absent() : Value(wer),
    );
  }

  factory Purchase.fromJson(
    Map<String, dynamic> json, {
    ValueSerializer? serializer,
  }) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return Purchase(
      id: serializer.fromJson<int>(json['id']),
      nr: serializer.fromJson<String?>(json['nr']),
      datum: serializer.fromJson<String>(json['datum']),
      artikel: serializer.fromJson<String>(json['artikel']),
      beschreibung: serializer.fromJson<String?>(json['beschreibung']),
      kategorie: serializer.fromJson<String>(json['kategorie']),
      produktart: serializer.fromJson<String?>(json['produktart']),
      menge: serializer.fromJson<double>(json['menge']),
      einheit: serializer.fromJson<String?>(json['einheit']),
      preis: serializer.fromJson<double>(json['preis']),
      supermarkt: serializer.fromJson<String?>(json['supermarkt']),
      kommentar: serializer.fromJson<String?>(json['kommentar']),
      wer: serializer.fromJson<String?>(json['wer']),
    );
  }
  @override
  Map<String, dynamic> toJson({ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return <String, dynamic>{
      'id': serializer.toJson<int>(id),
      'nr': serializer.toJson<String?>(nr),
      'datum': serializer.toJson<String>(datum),
      'artikel': serializer.toJson<String>(artikel),
      'beschreibung': serializer.toJson<String?>(beschreibung),
      'kategorie': serializer.toJson<String>(kategorie),
      'produktart': serializer.toJson<String?>(produktart),
      'menge': serializer.toJson<double>(menge),
      'einheit': serializer.toJson<String?>(einheit),
      'preis': serializer.toJson<double>(preis),
      'supermarkt': serializer.toJson<String?>(supermarkt),
      'kommentar': serializer.toJson<String?>(kommentar),
      'wer': serializer.toJson<String?>(wer),
    };
  }

  Purchase copyWith({
    int? id,
    Value<String?> nr = const Value.absent(),
    String? datum,
    String? artikel,
    Value<String?> beschreibung = const Value.absent(),
    String? kategorie,
    Value<String?> produktart = const Value.absent(),
    double? menge,
    Value<String?> einheit = const Value.absent(),
    double? preis,
    Value<String?> supermarkt = const Value.absent(),
    Value<String?> kommentar = const Value.absent(),
    Value<String?> wer = const Value.absent(),
  }) => Purchase(
    id: id ?? this.id,
    nr: nr.present ? nr.value : this.nr,
    datum: datum ?? this.datum,
    artikel: artikel ?? this.artikel,
    beschreibung: beschreibung.present ? beschreibung.value : this.beschreibung,
    kategorie: kategorie ?? this.kategorie,
    produktart: produktart.present ? produktart.value : this.produktart,
    menge: menge ?? this.menge,
    einheit: einheit.present ? einheit.value : this.einheit,
    preis: preis ?? this.preis,
    supermarkt: supermarkt.present ? supermarkt.value : this.supermarkt,
    kommentar: kommentar.present ? kommentar.value : this.kommentar,
    wer: wer.present ? wer.value : this.wer,
  );
  Purchase copyWithCompanion(PurchasesCompanion data) {
    return Purchase(
      id: data.id.present ? data.id.value : this.id,
      nr: data.nr.present ? data.nr.value : this.nr,
      datum: data.datum.present ? data.datum.value : this.datum,
      artikel: data.artikel.present ? data.artikel.value : this.artikel,
      beschreibung:
          data.beschreibung.present
              ? data.beschreibung.value
              : this.beschreibung,
      kategorie: data.kategorie.present ? data.kategorie.value : this.kategorie,
      produktart:
          data.produktart.present ? data.produktart.value : this.produktart,
      menge: data.menge.present ? data.menge.value : this.menge,
      einheit: data.einheit.present ? data.einheit.value : this.einheit,
      preis: data.preis.present ? data.preis.value : this.preis,
      supermarkt:
          data.supermarkt.present ? data.supermarkt.value : this.supermarkt,
      kommentar: data.kommentar.present ? data.kommentar.value : this.kommentar,
      wer: data.wer.present ? data.wer.value : this.wer,
    );
  }

  @override
  String toString() {
    return (StringBuffer('Purchase(')
          ..write('id: $id, ')
          ..write('nr: $nr, ')
          ..write('datum: $datum, ')
          ..write('artikel: $artikel, ')
          ..write('beschreibung: $beschreibung, ')
          ..write('kategorie: $kategorie, ')
          ..write('produktart: $produktart, ')
          ..write('menge: $menge, ')
          ..write('einheit: $einheit, ')
          ..write('preis: $preis, ')
          ..write('supermarkt: $supermarkt, ')
          ..write('kommentar: $kommentar, ')
          ..write('wer: $wer')
          ..write(')'))
        .toString();
  }

  @override
  int get hashCode => Object.hash(
    id,
    nr,
    datum,
    artikel,
    beschreibung,
    kategorie,
    produktart,
    menge,
    einheit,
    preis,
    supermarkt,
    kommentar,
    wer,
  );
  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      (other is Purchase &&
          other.id == this.id &&
          other.nr == this.nr &&
          other.datum == this.datum &&
          other.artikel == this.artikel &&
          other.beschreibung == this.beschreibung &&
          other.kategorie == this.kategorie &&
          other.produktart == this.produktart &&
          other.menge == this.menge &&
          other.einheit == this.einheit &&
          other.preis == this.preis &&
          other.supermarkt == this.supermarkt &&
          other.kommentar == this.kommentar &&
          other.wer == this.wer);
}

class PurchasesCompanion extends UpdateCompanion<Purchase> {
  final Value<int> id;
  final Value<String?> nr;
  final Value<String> datum;
  final Value<String> artikel;
  final Value<String?> beschreibung;
  final Value<String> kategorie;
  final Value<String?> produktart;
  final Value<double> menge;
  final Value<String?> einheit;
  final Value<double> preis;
  final Value<String?> supermarkt;
  final Value<String?> kommentar;
  final Value<String?> wer;
  const PurchasesCompanion({
    this.id = const Value.absent(),
    this.nr = const Value.absent(),
    this.datum = const Value.absent(),
    this.artikel = const Value.absent(),
    this.beschreibung = const Value.absent(),
    this.kategorie = const Value.absent(),
    this.produktart = const Value.absent(),
    this.menge = const Value.absent(),
    this.einheit = const Value.absent(),
    this.preis = const Value.absent(),
    this.supermarkt = const Value.absent(),
    this.kommentar = const Value.absent(),
    this.wer = const Value.absent(),
  });
  PurchasesCompanion.insert({
    this.id = const Value.absent(),
    this.nr = const Value.absent(),
    required String datum,
    required String artikel,
    this.beschreibung = const Value.absent(),
    required String kategorie,
    this.produktart = const Value.absent(),
    required double menge,
    this.einheit = const Value.absent(),
    required double preis,
    this.supermarkt = const Value.absent(),
    this.kommentar = const Value.absent(),
    this.wer = const Value.absent(),
  }) : datum = Value(datum),
       artikel = Value(artikel),
       kategorie = Value(kategorie),
       menge = Value(menge),
       preis = Value(preis);
  static Insertable<Purchase> custom({
    Expression<int>? id,
    Expression<String>? nr,
    Expression<String>? datum,
    Expression<String>? artikel,
    Expression<String>? beschreibung,
    Expression<String>? kategorie,
    Expression<String>? produktart,
    Expression<double>? menge,
    Expression<String>? einheit,
    Expression<double>? preis,
    Expression<String>? supermarkt,
    Expression<String>? kommentar,
    Expression<String>? wer,
  }) {
    return RawValuesInsertable({
      if (id != null) 'id': id,
      if (nr != null) 'nr': nr,
      if (datum != null) 'datum': datum,
      if (artikel != null) 'artikel': artikel,
      if (beschreibung != null) 'beschreibung': beschreibung,
      if (kategorie != null) 'kategorie': kategorie,
      if (produktart != null) 'produktart': produktart,
      if (menge != null) 'menge': menge,
      if (einheit != null) 'einheit': einheit,
      if (preis != null) 'preis': preis,
      if (supermarkt != null) 'supermarkt': supermarkt,
      if (kommentar != null) 'kommentar': kommentar,
      if (wer != null) 'wer': wer,
    });
  }

  PurchasesCompanion copyWith({
    Value<int>? id,
    Value<String?>? nr,
    Value<String>? datum,
    Value<String>? artikel,
    Value<String?>? beschreibung,
    Value<String>? kategorie,
    Value<String?>? produktart,
    Value<double>? menge,
    Value<String?>? einheit,
    Value<double>? preis,
    Value<String?>? supermarkt,
    Value<String?>? kommentar,
    Value<String?>? wer,
  }) {
    return PurchasesCompanion(
      id: id ?? this.id,
      nr: nr ?? this.nr,
      datum: datum ?? this.datum,
      artikel: artikel ?? this.artikel,
      beschreibung: beschreibung ?? this.beschreibung,
      kategorie: kategorie ?? this.kategorie,
      produktart: produktart ?? this.produktart,
      menge: menge ?? this.menge,
      einheit: einheit ?? this.einheit,
      preis: preis ?? this.preis,
      supermarkt: supermarkt ?? this.supermarkt,
      kommentar: kommentar ?? this.kommentar,
      wer: wer ?? this.wer,
    );
  }

  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    if (id.present) {
      map['id'] = Variable<int>(id.value);
    }
    if (nr.present) {
      map['nr'] = Variable<String>(nr.value);
    }
    if (datum.present) {
      map['datum'] = Variable<String>(datum.value);
    }
    if (artikel.present) {
      map['artikel'] = Variable<String>(artikel.value);
    }
    if (beschreibung.present) {
      map['beschreibung'] = Variable<String>(beschreibung.value);
    }
    if (kategorie.present) {
      map['kategorie'] = Variable<String>(kategorie.value);
    }
    if (produktart.present) {
      map['produktart'] = Variable<String>(produktart.value);
    }
    if (menge.present) {
      map['menge'] = Variable<double>(menge.value);
    }
    if (einheit.present) {
      map['einheit'] = Variable<String>(einheit.value);
    }
    if (preis.present) {
      map['preis'] = Variable<double>(preis.value);
    }
    if (supermarkt.present) {
      map['supermarkt'] = Variable<String>(supermarkt.value);
    }
    if (kommentar.present) {
      map['kommentar'] = Variable<String>(kommentar.value);
    }
    if (wer.present) {
      map['wer'] = Variable<String>(wer.value);
    }
    return map;
  }

  @override
  String toString() {
    return (StringBuffer('PurchasesCompanion(')
          ..write('id: $id, ')
          ..write('nr: $nr, ')
          ..write('datum: $datum, ')
          ..write('artikel: $artikel, ')
          ..write('beschreibung: $beschreibung, ')
          ..write('kategorie: $kategorie, ')
          ..write('produktart: $produktart, ')
          ..write('menge: $menge, ')
          ..write('einheit: $einheit, ')
          ..write('preis: $preis, ')
          ..write('supermarkt: $supermarkt, ')
          ..write('kommentar: $kommentar, ')
          ..write('wer: $wer')
          ..write(')'))
        .toString();
  }
}

abstract class _$AppDatabase extends GeneratedDatabase {
  _$AppDatabase(QueryExecutor e) : super(e);
  $AppDatabaseManager get managers => $AppDatabaseManager(this);
  late final $PurchasesTable purchases = $PurchasesTable(this);
  @override
  Iterable<TableInfo<Table, Object?>> get allTables =>
      allSchemaEntities.whereType<TableInfo<Table, Object?>>();
  @override
  List<DatabaseSchemaEntity> get allSchemaEntities => [purchases];
}

typedef $$PurchasesTableCreateCompanionBuilder =
    PurchasesCompanion Function({
      Value<int> id,
      Value<String?> nr,
      required String datum,
      required String artikel,
      Value<String?> beschreibung,
      required String kategorie,
      Value<String?> produktart,
      required double menge,
      Value<String?> einheit,
      required double preis,
      Value<String?> supermarkt,
      Value<String?> kommentar,
      Value<String?> wer,
    });
typedef $$PurchasesTableUpdateCompanionBuilder =
    PurchasesCompanion Function({
      Value<int> id,
      Value<String?> nr,
      Value<String> datum,
      Value<String> artikel,
      Value<String?> beschreibung,
      Value<String> kategorie,
      Value<String?> produktart,
      Value<double> menge,
      Value<String?> einheit,
      Value<double> preis,
      Value<String?> supermarkt,
      Value<String?> kommentar,
      Value<String?> wer,
    });

class $$PurchasesTableFilterComposer
    extends Composer<_$AppDatabase, $PurchasesTable> {
  $$PurchasesTableFilterComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnFilters<int> get id => $composableBuilder(
    column: $table.id,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get nr => $composableBuilder(
    column: $table.nr,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get datum => $composableBuilder(
    column: $table.datum,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get artikel => $composableBuilder(
    column: $table.artikel,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get beschreibung => $composableBuilder(
    column: $table.beschreibung,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get kategorie => $composableBuilder(
    column: $table.kategorie,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get produktart => $composableBuilder(
    column: $table.produktart,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<double> get menge => $composableBuilder(
    column: $table.menge,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get einheit => $composableBuilder(
    column: $table.einheit,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<double> get preis => $composableBuilder(
    column: $table.preis,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get supermarkt => $composableBuilder(
    column: $table.supermarkt,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get kommentar => $composableBuilder(
    column: $table.kommentar,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get wer => $composableBuilder(
    column: $table.wer,
    builder: (column) => ColumnFilters(column),
  );
}

class $$PurchasesTableOrderingComposer
    extends Composer<_$AppDatabase, $PurchasesTable> {
  $$PurchasesTableOrderingComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnOrderings<int> get id => $composableBuilder(
    column: $table.id,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get nr => $composableBuilder(
    column: $table.nr,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get datum => $composableBuilder(
    column: $table.datum,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get artikel => $composableBuilder(
    column: $table.artikel,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get beschreibung => $composableBuilder(
    column: $table.beschreibung,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get kategorie => $composableBuilder(
    column: $table.kategorie,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get produktart => $composableBuilder(
    column: $table.produktart,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<double> get menge => $composableBuilder(
    column: $table.menge,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get einheit => $composableBuilder(
    column: $table.einheit,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<double> get preis => $composableBuilder(
    column: $table.preis,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get supermarkt => $composableBuilder(
    column: $table.supermarkt,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get kommentar => $composableBuilder(
    column: $table.kommentar,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get wer => $composableBuilder(
    column: $table.wer,
    builder: (column) => ColumnOrderings(column),
  );
}

class $$PurchasesTableAnnotationComposer
    extends Composer<_$AppDatabase, $PurchasesTable> {
  $$PurchasesTableAnnotationComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  GeneratedColumn<int> get id =>
      $composableBuilder(column: $table.id, builder: (column) => column);

  GeneratedColumn<String> get nr =>
      $composableBuilder(column: $table.nr, builder: (column) => column);

  GeneratedColumn<String> get datum =>
      $composableBuilder(column: $table.datum, builder: (column) => column);

  GeneratedColumn<String> get artikel =>
      $composableBuilder(column: $table.artikel, builder: (column) => column);

  GeneratedColumn<String> get beschreibung => $composableBuilder(
    column: $table.beschreibung,
    builder: (column) => column,
  );

  GeneratedColumn<String> get kategorie =>
      $composableBuilder(column: $table.kategorie, builder: (column) => column);

  GeneratedColumn<String> get produktart => $composableBuilder(
    column: $table.produktart,
    builder: (column) => column,
  );

  GeneratedColumn<double> get menge =>
      $composableBuilder(column: $table.menge, builder: (column) => column);

  GeneratedColumn<String> get einheit =>
      $composableBuilder(column: $table.einheit, builder: (column) => column);

  GeneratedColumn<double> get preis =>
      $composableBuilder(column: $table.preis, builder: (column) => column);

  GeneratedColumn<String> get supermarkt => $composableBuilder(
    column: $table.supermarkt,
    builder: (column) => column,
  );

  GeneratedColumn<String> get kommentar =>
      $composableBuilder(column: $table.kommentar, builder: (column) => column);

  GeneratedColumn<String> get wer =>
      $composableBuilder(column: $table.wer, builder: (column) => column);
}

class $$PurchasesTableTableManager
    extends
        RootTableManager<
          _$AppDatabase,
          $PurchasesTable,
          Purchase,
          $$PurchasesTableFilterComposer,
          $$PurchasesTableOrderingComposer,
          $$PurchasesTableAnnotationComposer,
          $$PurchasesTableCreateCompanionBuilder,
          $$PurchasesTableUpdateCompanionBuilder,
          (Purchase, BaseReferences<_$AppDatabase, $PurchasesTable, Purchase>),
          Purchase,
          PrefetchHooks Function()
        > {
  $$PurchasesTableTableManager(_$AppDatabase db, $PurchasesTable table)
    : super(
        TableManagerState(
          db: db,
          table: table,
          createFilteringComposer:
              () => $$PurchasesTableFilterComposer($db: db, $table: table),
          createOrderingComposer:
              () => $$PurchasesTableOrderingComposer($db: db, $table: table),
          createComputedFieldComposer:
              () => $$PurchasesTableAnnotationComposer($db: db, $table: table),
          updateCompanionCallback:
              ({
                Value<int> id = const Value.absent(),
                Value<String?> nr = const Value.absent(),
                Value<String> datum = const Value.absent(),
                Value<String> artikel = const Value.absent(),
                Value<String?> beschreibung = const Value.absent(),
                Value<String> kategorie = const Value.absent(),
                Value<String?> produktart = const Value.absent(),
                Value<double> menge = const Value.absent(),
                Value<String?> einheit = const Value.absent(),
                Value<double> preis = const Value.absent(),
                Value<String?> supermarkt = const Value.absent(),
                Value<String?> kommentar = const Value.absent(),
                Value<String?> wer = const Value.absent(),
              }) => PurchasesCompanion(
                id: id,
                nr: nr,
                datum: datum,
                artikel: artikel,
                beschreibung: beschreibung,
                kategorie: kategorie,
                produktart: produktart,
                menge: menge,
                einheit: einheit,
                preis: preis,
                supermarkt: supermarkt,
                kommentar: kommentar,
                wer: wer,
              ),
          createCompanionCallback:
              ({
                Value<int> id = const Value.absent(),
                Value<String?> nr = const Value.absent(),
                required String datum,
                required String artikel,
                Value<String?> beschreibung = const Value.absent(),
                required String kategorie,
                Value<String?> produktart = const Value.absent(),
                required double menge,
                Value<String?> einheit = const Value.absent(),
                required double preis,
                Value<String?> supermarkt = const Value.absent(),
                Value<String?> kommentar = const Value.absent(),
                Value<String?> wer = const Value.absent(),
              }) => PurchasesCompanion.insert(
                id: id,
                nr: nr,
                datum: datum,
                artikel: artikel,
                beschreibung: beschreibung,
                kategorie: kategorie,
                produktart: produktart,
                menge: menge,
                einheit: einheit,
                preis: preis,
                supermarkt: supermarkt,
                kommentar: kommentar,
                wer: wer,
              ),
          withReferenceMapper:
              (p0) =>
                  p0
                      .map(
                        (e) => (
                          e.readTable(table),
                          BaseReferences(db, table, e),
                        ),
                      )
                      .toList(),
          prefetchHooksCallback: null,
        ),
      );
}

typedef $$PurchasesTableProcessedTableManager =
    ProcessedTableManager<
      _$AppDatabase,
      $PurchasesTable,
      Purchase,
      $$PurchasesTableFilterComposer,
      $$PurchasesTableOrderingComposer,
      $$PurchasesTableAnnotationComposer,
      $$PurchasesTableCreateCompanionBuilder,
      $$PurchasesTableUpdateCompanionBuilder,
      (Purchase, BaseReferences<_$AppDatabase, $PurchasesTable, Purchase>),
      Purchase,
      PrefetchHooks Function()
    >;

class $AppDatabaseManager {
  final _$AppDatabase _db;
  $AppDatabaseManager(this._db);
  $$PurchasesTableTableManager get purchases =>
      $$PurchasesTableTableManager(_db, _db.purchases);
}
