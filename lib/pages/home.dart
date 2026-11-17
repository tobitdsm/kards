import 'dart:convert';

import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:kards/pages/scanner.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../loyalty_card.dart';
import '../l10n/generated/app_localizations.dart';
import 'card_display.dart';

enum SortOption { name, dateAdded, cardType }

class HomePage extends StatefulWidget {
  const HomePage({super.key, required this.onLocaleChanged});

  final ValueChanged<Locale> onLocaleChanged;

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  List<LoyaltyCard> cards = [];
  List<LoyaltyCard> filteredCards = [];
  final TextEditingController _searchController = TextEditingController();
  final FocusNode _searchFocusNode = FocusNode(); // Add FocusNode
  SortOption currentSortOption = SortOption.name;
  bool sortAscending = true;

  @override
  void initState() {
    super.initState();
    _loadCards();
    _searchController.addListener(_filterCards);
  }

  @override
  void dispose() {
    _searchController.dispose();
    _searchFocusNode.dispose(); // Dispose FocusNode
    super.dispose();
  }

  Future<void> _loadCards() async {
    final prefs = await SharedPreferences.getInstance();
    final cardsJson = prefs.getStringList('loyalty_cards') ?? [];
    setState(() {
      cards =
          cardsJson
              .map((cardJson) => LoyaltyCard.fromJson(json.decode(cardJson)))
              .toList();
      _sortAndFilterCards();
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
      _sortAndFilterCards();
    });
    await _saveCards();
  }

  void _filterCards() {
    final query = _searchController.text.toLowerCase();
    setState(() {
      if (query.isEmpty) {
        filteredCards = List.from(cards);
      } else {
        filteredCards =
            cards.where((card) {
              return card.storeName.toLowerCase().contains(query) ||
                  card.cardType.toLowerCase().contains(query);
            }).toList();
      }
      _sortCards();
    });
  }

  void _sortCards() {
    filteredCards.sort((a, b) {
      int comparison;
      switch (currentSortOption) {
        case SortOption.name:
          comparison = a.storeName.compareTo(b.storeName);
          break;
        case SortOption.dateAdded:
          comparison = a.dateAdded.compareTo(b.dateAdded);
          break;
        case SortOption.cardType:
          comparison = a.cardType.compareTo(b.cardType);
          break;
      }
      return sortAscending ? comparison : -comparison;
    });
  }

  void _sortAndFilterCards() {
    _filterCards();
  }

  void _showSortDialog() {
    final l10n = AppLocalizations.of(context)!;
    showDialog(
      context: context,
      builder:
          (context) => AlertDialog(
            title: Text(l10n.sortCards),
            content: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                RadioListTile<SortOption>(
                  title: Text(l10n.storeName),
                  value: SortOption.name,
                  groupValue: currentSortOption,
                  onChanged: (value) {
                    setState(() {
                      currentSortOption = value!;
                      _sortAndFilterCards();
                    });
                    Navigator.pop(context);
                  },
                ),
                RadioListTile<SortOption>(
                  title: Text(l10n.dateAdded),
                  value: SortOption.dateAdded,
                  groupValue: currentSortOption,
                  onChanged: (value) {
                    setState(() {
                      currentSortOption = value!;
                      _sortAndFilterCards();
                    });
                    Navigator.pop(context);
                  },
                ),
                RadioListTile<SortOption>(
                  title: Text(l10n.cardType),
                  value: SortOption.cardType,
                  groupValue: currentSortOption,
                  onChanged: (value) {
                    setState(() {
                      currentSortOption = value!;
                      _sortAndFilterCards();
                    });
                    Navigator.pop(context);
                  },
                ),
                Divider(),
                SwitchListTile(
                  title: Text(l10n.ascendingOrder),
                  value: sortAscending,
                  onChanged: (value) {
                    setState(() {
                      sortAscending = value;
                      _sortAndFilterCards();
                    });
                    Navigator.pop(context);
                  },
                ),
              ],
            ),
            actions: [
              TextButton(
                onPressed: () => Navigator.pop(context),
                child: Text(l10n.done),
              ),
            ],
          ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;
    final l10n = AppLocalizations.of(context)!;

    return GestureDetector(
      // Add GestureDetector to dismiss keyboard when tapping outside
      onTap: () => FocusScope.of(context).unfocus(),
      child: Scaffold(
        appBar: AppBar(
          title: Text(l10n.appTitle),
          backgroundColor: colorScheme.inversePrimary,
          foregroundColor: colorScheme.inverseSurface,
          actions: [
            IconButton(
              icon: const Icon(Icons.language),
              tooltip: l10n.switchLanguage,
              onPressed: () {
                final nextLocale =
                    l10n.localeName.startsWith('nl')
                        ? const Locale('en')
                        : const Locale('nl');
                widget.onLocaleChanged(nextLocale);
              },
            ),
          ],
        ),
        body: Column(
          children: [
            if (cards.isNotEmpty)
              ListTile(
                title: TextField(
                  controller: _searchController,
                  focusNode: _searchFocusNode, // Add FocusNode
                  decoration: InputDecoration(
                    hintText: l10n.searchCards,
                    prefixIcon: Icon(Icons.search),
                    suffixIcon:
                        _searchController.text.isNotEmpty
                            ? IconButton(
                              icon: Icon(Icons.clear),
                              tooltip: l10n.clearSearch,
                              onPressed: () {
                                _searchController.clear();
                                _searchFocusNode
                                    .unfocus(); // Unfocus when clearing
                              },
                            )
                            : null,
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                    filled: true,
                    fillColor: colorScheme.surfaceContainerHighest,
                  ),
                ),
                trailing: IconButton(
                  icon: Icon(Icons.sort),
                  onPressed: _showSortDialog,
                  tooltip: l10n.sortCardsTooltip,
                ),
              ),
            Expanded(
              child:
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
                              l10n.noLoyaltyCards,
                              style: TextStyle(
                                fontSize: 18,
                                color: colorScheme.onSurfaceVariant,
                              ),
                            ),
                            SizedBox(height: 8),
                            Text(
                              l10n.scanFirstCard,
                              style: TextStyle(
                                fontSize: 14,
                                color: colorScheme.onSurfaceVariant,
                              ),
                            ),
                          ],
                        ),
                      )
                      : filteredCards.isEmpty
                      ? Center(
                        child: Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Icon(
                              Icons.search_off,
                              size: 80,
                              color: colorScheme.outline,
                            ),
                            SizedBox(height: 16),
                            Text(
                              l10n.noCardsFound,
                              style: TextStyle(
                                fontSize: 18,
                                color: colorScheme.onSurfaceVariant,
                              ),
                            ),
                            SizedBox(height: 8),
                            Text(
                              l10n.adjustSearch,
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
                        itemCount: filteredCards.length,
                        itemBuilder: (context, index) {
                          final card = filteredCards[index];
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
                              subtitle: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text(
                                    card.cardType == 'QR'
                                        ? l10n.qrCode
                                        : l10n.barcode,
                                    style: TextStyle(
                                      color: colorScheme.onSurfaceVariant,
                                    ),
                                  ),
                                  Text(
                                    l10n.addedDate(
                                      DateFormat.yMd(
                                        l10n.localeName,
                                      ).format(card.dateAdded),
                                    ),
                                    style: TextStyle(
                                      color: colorScheme.onSurfaceVariant,
                                      fontSize: 12,
                                    ),
                                  ),
                                ],
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
                                            Text(l10n.delete),
                                          ],
                                        ),
                                      ),
                                    ],
                              ),
                              onTap: () async {
                                // Unfocus before navigation
                                _searchFocusNode.unfocus();
                                await Navigator.push(
                                  context,
                                  MaterialPageRoute(
                                    builder:
                                        (context) =>
                                            CardDisplayPage(card: card),
                                  ),
                                );
                              },
                            ),
                          );
                        },
                      ),
            ),
          ],
        ),
        floatingActionButton: FloatingActionButton(
          onPressed: () async {
            // Unfocus before navigation
            _searchFocusNode.unfocus();
            final result = await Navigator.push(
              context,
              MaterialPageRoute(builder: (context) => ScannerPage()),
            );
            if (result != null) {
              setState(() {
                cards.add(result);
                _sortAndFilterCards();
              });
              await _saveCards();
            }
          },
          backgroundColor: colorScheme.inversePrimary,
          foregroundColor: colorScheme.inverseSurface,
          child: Icon(Icons.add),
        ),
      ),
    );
  }

  void _showDeleteDialog(LoyaltyCard card) {
    final colorScheme = Theme.of(context).colorScheme;
    final l10n = AppLocalizations.of(context)!;

    showDialog(
      context: context,
      builder:
          (context) => AlertDialog(
            title: Text(l10n.deleteCard),
            content: Text(l10n.confirmDeleteCard(card.storeName)),
            actions: [
              TextButton(
                onPressed: () => Navigator.pop(context),
                child: Text(l10n.cancel),
              ),
              TextButton(
                onPressed: () {
                  Navigator.pop(context);
                  _deleteCard(card.id);
                },
                child: Text(
                  l10n.delete,
                  style: TextStyle(color: colorScheme.error),
                ),
              ),
            ],
          ),
    );
  }
}
