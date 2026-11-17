import 'package:flutter/material.dart';
import 'package:flutter_localizations/flutter_localizations.dart';

import 'l10n/generated/app_localizations.dart';
import 'pages/home.dart';

void main() {
  runApp(KardsApp());
}

class KardsApp extends StatefulWidget {
  const KardsApp({super.key});

  @override
  State<KardsApp> createState() => _KardsAppState();
}

class _KardsAppState extends State<KardsApp> {
  Locale? _locale;

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      locale: _locale,
      onGenerateTitle: (context) => AppLocalizations.of(context)!.appTitle,
      localizationsDelegates: const [
        AppLocalizations.delegate,
        GlobalMaterialLocalizations.delegate,
        GlobalWidgetsLocalizations.delegate,
        GlobalCupertinoLocalizations.delegate,
      ],
      supportedLocales: AppLocalizations.supportedLocales,
      theme: ThemeData(
        colorScheme: ColorScheme.fromSeed(
          seedColor: Color.fromRGBO(245, 154, 154, 1),
        ),
        useMaterial3: true,
        visualDensity: VisualDensity.adaptivePlatformDensity,
      ),
      home: HomePage(
        onLocaleChanged: (locale) {
          setState(() {
            _locale = locale;
          });
        },
      ),
    );
  }
}
