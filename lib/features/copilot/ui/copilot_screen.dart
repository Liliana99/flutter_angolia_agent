import 'package:flutter/material.dart';
import 'package:flutter_challenge/core/ui/pill.dart';
import 'package:flutter_challenge/core/ui/score_badge.dart';
import 'package:flutter_challenge/core/ui/section_card.dart';
import '../../search/data/algolia_search_api.dart';
import '../../search/domain/product.dart';
import '../../../core/http/dio_client.dart';
import 'package:go_router/go_router.dart';

class CopilotScreen extends StatefulWidget {
  const CopilotScreen({super.key});

  @override
  State<CopilotScreen> createState() => _CopilotScreenState();
}

class _CopilotScreenState extends State<CopilotScreen> {
  final _api = AlgoliaSearchApi(DioClient.create());
  late final String? _productId;
  Product? _productContext;

  bool _loading = false;
  String _summary = 'Choose an action to generate insights.';
  List<Product> _items = [];

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    _productId = GoRouterState.of(context).uri.queryParameters['product'];
    if (_productId != null) {
      _loadProductContext(_productId!);
    }
  }

  Future<void> _loadProductContext(String productId) async {
    setState(() {
      _loading = true;
      _summary = 'Analyzing product...';
      _items = [];
    });

    final json = await _api.getProductById(productId);

    if (json != null) {
      final product = Product.fromJson(json);

      setState(() {
        _productContext = product;
        _loading = false;
        _summary = _buildProductSummary(product);
      });
    } else {
      setState(() {
        _loading = false;
        _summary = 'Product not found.';
      });
    }
  }

  String _buildProductSummary(Product p) {
    if (p.qualityScore >= 80) {
      return '✅ ${p.title} has a high quality score (${p.qualityScore}). No critical issues detected.';
    }

    if (p.missingFields.isNotEmpty) {
      return '⚠️ ${p.title} has a low quality score (${p.qualityScore}) because it is missing: '
          '${p.missingFields.join(', ')}.';
    }

    return 'ℹ️ ${p.title} has a quality score of ${p.qualityScore}. Consider improving its content.';
  }

  Future<void> _runMissingCritical() async {
    setState(() {
      _loading = true;
      _summary = 'Scanning catalog for missing critical attributes...';
      _items = [];
    });

    final hits = await _api.searchProducts(
      query: '',
      hitsPerPage: 20,
      filters: 'status:active',
      numericFilters: ['qualityScore<80'],
    );

    final products = hits.map(Product.fromJson).toList();

    final withMissing = products
        .where((p) => p.missingFields.isNotEmpty)
        .toList();

    setState(() {
      _loading = false;
      _items = withMissing;
      _summary =
          'Found ${withMissing.length} active products with missing attributes. Prioritize those with lower Quality Score.';
    });
  }

  Future<void> _runLowQuality() async {
    setState(() {
      _loading = true;
      _summary = 'Finding low quality product pages (qualityScore < 60)...';
      _items = [];
    });

    final hits = await _api.searchProducts(
      query: '',
      hitsPerPage: 20,
      numericFilters: ['qualityScore<60'],
    );

    final products = hits.map(Product.fromJson).toList();

    setState(() {
      _loading = false;
      _items = products;
      _summary = 'Found ${products.length} products with low quality pages.';
    });
  }

  Future<void> _runDraftBlocked() async {
    setState(() {
      _loading = true;
      _summary =
          'Listing products not ready for publication (draft/blocked)...';
      _items = [];
    });

    final hits = await _api.searchProducts(
      query: '',
      hitsPerPage: 20,
      filters: '(status:draft OR status:blocked)',
    );

    final products = hits.map(Product.fromJson).toList();

    setState(() {
      _loading = false;
      _items = products;
      _summary = 'Found ${products.length} products that are not active.';
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Copilot Insights')),
      body: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            if (_productContext == null)
              Wrap(
                spacing: 10,
                runSpacing: 10,
                children: [
                  ElevatedButton(
                    onPressed: _loading ? null : _runMissingCritical,
                    child: const Text('Missing critical attributes'),
                  ),
                  ElevatedButton(
                    onPressed: _loading ? null : _runLowQuality,
                    child: const Text('Low quality pages'),
                  ),
                  ElevatedButton(
                    onPressed: _loading ? null : _runDraftBlocked,
                    child: const Text('Draft / blocked'),
                  ),
                ],
              ),
            const SizedBox(height: 16),
            if (_loading) const LinearProgressIndicator(),
            if (_productContext != null) ...[
              SectionCard(
                title: 'Product',
                trailing: ScoreBadge(qs: _productContext!.qualityScore),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      _productContext!.title,
                      style: const TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.w800,
                      ),
                    ),
                    const SizedBox(height: 6),
                    Wrap(
                      spacing: 8,
                      runSpacing: 8,
                      children: [
                        Pill(text: _productContext!.brand),
                        Pill(text: _productContext!.marketplace),
                        Pill(text: _productContext!.status),
                      ],
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 12),

              SectionCard(
                title: 'Copilot explanation',
                child: Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Icon(Icons.auto_awesome, size: 18),
                    const SizedBox(width: 10),
                    Expanded(child: Text(_summary)),
                  ],
                ),
              ),

              const SizedBox(height: 12),

              if (_productContext!.missingFields.isNotEmpty)
                SectionCard(
                  title: 'Missing attributes',
                  child: Wrap(
                    spacing: 8,
                    runSpacing: 8,
                    children: _productContext!.missingFields
                        .map((f) => Chip(label: Text(f)))
                        .toList(),
                  ),
                ),
            ] else ...[
              Text(_summary),
            ],
            const SizedBox(height: 16),
            Expanded(
              child: ListView.separated(
                itemCount: _items.length,
                separatorBuilder: (_, __) => const Divider(height: 1),
                itemBuilder: (_, i) {
                  final p = _items[i];
                  return ListTile(
                    title: Text(p.title),
                    subtitle: Text('${p.brand} · ${p.marketplace}'),
                    trailing: Text('QS ${p.qualityScore}'),
                    onTap: () => context.go('/product/${p.objectID}'),
                  );
                },
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _scoreBadge(int qs) {
    final Color bg = qs < 60
        ? Colors.red.shade100
        : (qs < 80 ? Colors.orange.shade100 : Colors.green.shade100);
    final Color fg = qs < 60
        ? Colors.red.shade800
        : (qs < 80 ? Colors.orange.shade800 : Colors.green.shade800);

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
      decoration: BoxDecoration(
        color: bg,
        borderRadius: BorderRadius.circular(999),
      ),
      child: Text(
        'QS $qs',
        style: TextStyle(color: fg, fontWeight: FontWeight.w600),
      ),
    );
  }

  Widget _productContextCard(Product p) {
    return Card(
      elevation: 0,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      child: Padding(
        padding: const EdgeInsets.all(14),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Expanded(
                  child: Text(
                    p.title,
                    style: const TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.w700,
                    ),
                  ),
                ),
                _scoreBadge(p.qualityScore),
              ],
            ),
            const SizedBox(height: 6),
            Text('${p.brand} · ${p.marketplace}'),
            const SizedBox(height: 12),

            if (p.missingFields.isNotEmpty) ...[
              const Text(
                'Missing attributes',
                style: TextStyle(fontWeight: FontWeight.w600),
              ),
              const SizedBox(height: 8),
              Wrap(
                spacing: 8,
                runSpacing: 8,
                children: p.missingFields
                    .map((f) => Chip(label: Text(f)))
                    .toList(),
              ),
            ] else ...[
              const Text('No missing attributes detected. ✅'),
            ],
          ],
        ),
      ),
    );
  }
}
