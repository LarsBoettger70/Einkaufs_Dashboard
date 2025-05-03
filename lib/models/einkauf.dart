class Einkauf {
  final DateTime datum;
  final String artikel;
  final String kategorie;
  final int menge;
  final String einheit;
  final double preis;
  final String supermarkt;
  final String kommentar;
  final String artikelAusfuehrlich;
  final String wer;

  Einkauf({
    required this.datum,
    required this.artikel,
    required this.kategorie,
    required this.menge,
    required this.einheit,
    required this.preis,
    required this.supermarkt,
    required this.kommentar,
    required this.artikelAusfuehrlich,
    required this.wer,
  });

  factory Einkauf.fromCSV(List<String> row) {
    return Einkauf(
      datum: DateTime.parse(row[0]),
      artikel: row[1],
      kategorie: row[2],
      menge: int.tryParse(row[3]) ?? 1,
      einheit: row[4],
      preis: double.tryParse(row[5].replaceAll(',', '.')) ?? 0,
      supermarkt: row[6],
      kommentar: row[7],
      artikelAusfuehrlich: row[8],
      wer: row[9],
    );
  }
}