import 'package:flutter/material.dart';

import 'pages/home.dart';

void main() {
  runApp(KardsApp());
}

class KardsApp extends StatelessWidget {
  const KardsApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Kards',
      theme: ThemeData(
        colorScheme: ColorScheme.fromSeed(
          seedColor: Color.fromRGBO(245, 154, 154, 1),
        ),
        useMaterial3: true,
        visualDensity: VisualDensity.adaptivePlatformDensity,
      ),
      home: HomePage(),
    );
  }
}
