import 'package:flutter/material.dart';
import 'screens/dashboard_screen.dart';

void main() => runApp(MyApp());

class MyApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      title: 'Einkaufs Dashboard',
      theme: ThemeData.dark(),
      home: DashboardFromCSV(), // jetzt wird dein Dashboard mit echten Daten geladen!
    );
  }
}