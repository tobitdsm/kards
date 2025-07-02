import 'dart:convert';

import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:kards/pages/scanner.dart';
import 'package:shared_preferences/shared_preferences.dart';

import 'card_display.dart';
import '../loyalty_card.dart';

class HomePage extends StatefulWidget {
  const HomePage({super.key});

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  List<LoyaltyCard> cards = [];

  @override
  void initState() {
    super.initState();
    _loadCards();
  }

  Future<void> _loadCards() async {
    final prefs = await SharedPreferences.getInstance();
    final cardsJson = prefs.getStringList('loyalty_cards') ?? [];
    setState(() {
      cards =
          cardsJson
              .map((cardJson) => LoyaltyCard.fromJson(json.decode(cardJson)))
              .toList();
    });
  }

  Future<void> _saveCards() async {
    final prefs = await SharedPreferences.getInstance();
    final cardsJson = cards.map((card) => json.encode(card.toJson())).toList();
    await prefs.setStringList('loyalty_cards', cardsJson);
  }

  Future<void> _deleteCard(String cardId) async {
    setState(() {
      cards.removeWhere((card) => card.id == cardId);
    });
    await _saveCards();
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;

    return Scaffold(
      appBar: AppBar(
        title: Text('Kards'),
        backgroundColor: colorScheme.primary,
        foregroundColor: colorScheme.onPrimary,
      ),
      body:
          cards.isEmpty
              ? Center(
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Icon(
                      Icons.credit_card,
                      size: 80,
                      color: colorScheme.outline,
                    ),
                    SizedBox(height: 16),
                    Text(
                      'No loyalty cards yet',
                      style: TextStyle(
                        fontSize: 18,
                        color: colorScheme.onSurfaceVariant,
                      ),
                    ),
                    SizedBox(height: 8),
                    Text(
                      'Tap the + button to scan your first card',
                      style: TextStyle(
                        fontSize: 14,
                        color: colorScheme.onSurfaceVariant,
                      ),
                    ),
                  ],
                ),
              )
              : ListView.builder(
                padding: EdgeInsets.all(16),
                itemCount: cards.length,
                itemBuilder: (context, index) {
                  final card = cards[index];
                  return Card(
                    elevation: 4,
                    margin: EdgeInsets.only(bottom: 12),
                    child: ListTile(
                      contentPadding: EdgeInsets.all(16),
                      leading: Container(
                        width: 48,
                        height: 48,
                        decoration: BoxDecoration(
                          color: colorScheme.primaryContainer,
                          borderRadius: BorderRadius.circular(8),
                        ),
                        child: Icon(
                          card.cardType == 'QR'
                              ? Icons.qr_code
                              : CupertinoIcons.barcode,
                          color: colorScheme.onPrimaryContainer,
                        ),
                      ),
                      title: Text(
                        card.storeName,
                        style: TextStyle(
                          fontWeight: FontWeight.bold,
                          fontSize: 16,
                          color: colorScheme.onSurface,
                        ),
                      ),
                      subtitle: Text(
                        card.cardType,
                        style: TextStyle(color: colorScheme.onSurfaceVariant),
                      ),
                      trailing: PopupMenuButton(
                        onSelected: (value) {
                          if (value == 'delete') {
                            _showDeleteDialog(card);
                          }
                        },
                        itemBuilder:
                            (context) => [
                              PopupMenuItem(
                                value: 'delete',
                                child: Row(
                                  children: [
                                    Icon(
                                      Icons.delete,
                                      color: colorScheme.error,
                                    ),
                                    SizedBox(width: 8),
                                    Text('Delete'),
                                  ],
                                ),
                              ),
                            ],
                      ),
                      onTap: () {
                        Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (context) => CardDisplayPage(card: card),
                          ),
                        );
                      },
                    ),
                  );
                },
              ),
      floatingActionButton: FloatingActionButton(
        onPressed: () async {
          final result = await Navigator.push(
            context,
            MaterialPageRoute(builder: (context) => ScannerPage()),
          );
          if (result != null) {
            setState(() {
              cards.add(result);
            });
            await _saveCards();
          }
        },
        backgroundColor: colorScheme.primary,
        foregroundColor: colorScheme.onPrimary,
        child: Icon(Icons.add),
      ),
    );
  }

  void _showDeleteDialog(LoyaltyCard card) {
    final colorScheme = Theme.of(context).colorScheme;

    showDialog(
      context: context,
      builder:
          (context) => AlertDialog(
            title: Text('Delete Card'),
            content: Text(
              'Are you sure you want to delete the ${card.storeName} loyalty card?',
            ),
            actions: [
              TextButton(
                onPressed: () => Navigator.pop(context),
                child: Text('Cancel'),
              ),
              TextButton(
                onPressed: () {
                  Navigator.pop(context);
                  _deleteCard(card.id);
                },
                child: Text(
                  'Delete',
                  style: TextStyle(color: colorScheme.error),
                ),
              ),
            ],
          ),
    );
  }
}
