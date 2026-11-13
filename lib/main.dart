import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

import 'open_food_facts_api.dart';
import 'product.dart';

void main() => runApp(FoodTrackerApp(api: OpenFoodFactsApi()));

class FoodTrackerApp extends StatelessWidget {
  const FoodTrackerApp({super.key, required this.api});

  /// Wird von außen übergeben, damit Tests eine Fake-Datenbank nutzen können.
  final OpenFoodFactsApi api;

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Food Tracker',
      debugShowCheckedModeBanner: false,
      theme: ThemeData(colorSchemeSeed: Colors.green),
      darkTheme: ThemeData(
        colorSchemeSeed: Colors.green,
        brightness: Brightness.dark,
      ),
      home: ProductLookupScreen(api: api),
    );
  }
}

/// Bildschirm: Strichcode-Nummer eintippen und Produkt anzeigen.
class ProductLookupScreen extends StatefulWidget {
  const ProductLookupScreen({super.key, required this.api});

  final OpenFoodFactsApi api;

  @override
  State<ProductLookupScreen> createState() => _ProductLookupScreenState();
}

class _ProductLookupScreenState extends State<ProductLookupScreen> {
  final _barcodeController = TextEditingController();

  // Der Bildschirm ist immer in genau einem dieser Zustände:
  // lädt / Fehler / Produkt gefunden / noch nichts gesucht.
  bool _loading = false;
  String? _error;
  Product? _product;

  @override
  void dispose() {
    _barcodeController.dispose();
    super.dispose();
  }

  Future<void> _search() async {
    if (_loading) return; // Nicht doppelt suchen, wenn man zweimal tippt.
    FocusScope.of(context).unfocus(); // Tastatur schließen.

    setState(() {
      _loading = true;
      _error = null;
      _product = null;
    });

    try {
      final product = await widget.api.fetchProduct(_barcodeController.text);
      if (!mounted) return;
      setState(() => _product = product);
    } on ProductLookupException catch (e) {
      if (!mounted) return;
      setState(() => _error = e.message);
    } finally {
      if (mounted) setState(() => _loading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Produkt suchen')),
      body: SafeArea(
        child: ListView(
          padding: const EdgeInsets.all(16),
          children: [
            TextField(
              controller: _barcodeController,
              keyboardType: TextInputType.number,
              inputFormatters: [FilteringTextInputFormatter.digitsOnly],
              textInputAction: TextInputAction.search,
              onSubmitted: (_) => _search(),
              decoration: const InputDecoration(
                labelText: 'Strichcode-Nummer',
                hintText: 'z. B. 3017624010701',
                border: OutlineInputBorder(),
                prefixIcon: Icon(Icons.qr_code),
              ),
            ),
            const SizedBox(height: 12),
            FilledButton.icon(
              onPressed: _loading ? null : _search,
              icon: const Icon(Icons.search),
              label: const Text('Suchen'),
            ),
            const SizedBox(height: 24),
            _buildResult(context),
          ],
        ),
      ),
    );
  }

  Widget _buildResult(BuildContext context) {
    if (_loading) {
      return const Center(child: CircularProgressIndicator());
    }
    final error = _error;
    if (error != null) {
      return _MessageCard(icon: Icons.error_outline, text: error);
    }
    final product = _product;
    if (product != null) {
      return ProductCard(product: product);
    }
    return const _MessageCard(
      icon: Icons.info_outline,
      text:
          'Tippe die Nummer unter dem Strichcode ein, '
          'zum Beispiel von einer Chipstüte.',
    );
  }
}

/// Zeigt Name, Marke, Nutri-Score und Nährwerte eines Produkts.
class ProductCard extends StatelessWidget {
  const ProductCard({super.key, required this.product});

  final Product product;

  @override
  Widget build(BuildContext context) {
    final textTheme = Theme.of(context).textTheme;
    final brand = product.brand;
    final nutriScore = product.nutriScore;

    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(product.name, style: textTheme.titleLarge),
                      if (brand != null)
                        Text(brand, style: textTheme.bodyMedium),
                    ],
                  ),
                ),
                if (nutriScore != null) NutriScoreBadge(grade: nutriScore),
              ],
            ),
            const Divider(height: 32),
            Text('Nährwerte pro 100 g', style: textTheme.titleSmall),
            const SizedBox(height: 8),
            _NutrientRow('Kalorien', product.kcal, 'kcal', decimals: 0),
            _NutrientRow('Fett', product.fat, 'g'),
            _NutrientRow(
              'davon gesättigt',
              product.saturatedFat,
              'g',
              indent: true,
            ),
            _NutrientRow('Zucker', product.sugar, 'g'),
            _NutrientRow('Salz', product.salt, 'g'),
          ],
        ),
      ),
    );
  }
}

class _NutrientRow extends StatelessWidget {
  const _NutrientRow(
    this.label,
    this.value,
    this.unit, {
    this.decimals = 1,
    this.indent = false,
  });

  final String label;
  final double? value;
  final String unit;
  final int decimals;
  final bool indent;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: EdgeInsets.only(left: indent ? 16 : 0, top: 4, bottom: 4),
      child: Row(
        children: [
          Expanded(child: Text(label)),
          Text(formatAmount(value, unit, decimals: decimals)),
        ],
      ),
    );
  }
}

/// Formatiert z. B. 30.9 als "30,9 g". Fehlt der Wert, kommt "–".
String formatAmount(double? value, String unit, {int decimals = 1}) {
  if (value == null) return '–';
  final number = value.toStringAsFixed(decimals).replaceAll('.', ',');
  return '$number $unit';
}

/// Das bekannte farbige Nutri-Score-Kästchen (A = grün bis E = rot).
class NutriScoreBadge extends StatelessWidget {
  const NutriScoreBadge({super.key, required this.grade});

  final String grade;

  static const _colors = {
    'A': Color(0xFF038141),
    'B': Color(0xFF85BB2F),
    'C': Color(0xFFFECB02),
    'D': Color(0xFFEE8100),
    'E': Color(0xFFE63E11),
  };

  @override
  Widget build(BuildContext context) {
    final color = _colors[grade] ?? Colors.grey;
    // excludeSemantics: Ein Screenreader liest nur "Nutri-Score E" vor,
    // nicht zusätzlich noch die beiden Texte im Kästchen.
    return Semantics(
      label: 'Nutri-Score $grade',
      excludeSemantics: true,
      child: Container(
        width: 56,
        padding: const EdgeInsets.symmetric(vertical: 6),
        decoration: BoxDecoration(
          color: color,
          borderRadius: BorderRadius.circular(8),
        ),
        child: Column(
          children: [
            Text(
              'Nutri-Score',
              style: TextStyle(fontSize: 8, color: _textColor(grade)),
            ),
            Text(
              grade,
              style: TextStyle(
                fontSize: 24,
                fontWeight: FontWeight.bold,
                color: _textColor(grade),
              ),
            ),
          ],
        ),
      ),
    );
  }

  /// Auf Gelb (C) ist weiße Schrift schlecht lesbar.
  static Color _textColor(String grade) =>
      grade == 'C' ? Colors.black87 : Colors.white;
}

class _MessageCard extends StatelessWidget {
  const _MessageCard({required this.icon, required this.text});

  final IconData icon;
  final String text;

  @override
  Widget build(BuildContext context) {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Row(
          children: [
            Icon(icon),
            const SizedBox(width: 12),
            Expanded(child: Text(text)),
          ],
        ),
      ),
    );
  }
}
