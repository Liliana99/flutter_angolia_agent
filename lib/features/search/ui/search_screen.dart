import 'package:flutter/material.dart';
import 'package:flutter_challenge/core/ui/pill.dart';
import 'package:flutter_challenge/core/ui/score_badge.dart';
import 'package:go_router/go_router.dart';
import '../../../core/http/dio_client.dart';
import '../data/algolia_search_api.dart';
import '../domain/product.dart';

class SearchScreen extends StatefulWidget {
  const SearchScreen({super.key});

  @override
  State<SearchScreen> createState() => _SearchScreenState();
}

class _SearchScreenState extends State<SearchScreen> {
  final _controller = TextEditingController();
  final _api = AlgoliaSearchApi(DioClient.create());

  bool _loading = false;
  List<Product> _results = [];

  Future<void> _search(String query) async {
    if (query.isEmpty) {
      setState(() => _results = []);
      return;
    }

    setState(() => _loading = true);

    try {
      final hits = await _api.search(query: query, hitsPerPage: 20);

      setState(() {
        _results = hits.map(Product.fromJson).toList();
      });
    } catch (e) {
      debugPrint('SEARCH ERROR: $e');
    } finally {
      setState(() => _loading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Catalog Copilot'),
        actions: [
          TextButton(
            onPressed: () => context.go('/copilot'),
            child: const Text('Copilot'),
          ),
        ],
      ),
      body: maxWidthBody(
        Padding(
          padding: const EdgeInsets.all(16),
          child: Column(
            children: [
              Padding(
                padding: const EdgeInsets.all(12),
                child: TextField(
                  controller: _controller,
                  decoration: const InputDecoration(
                    hintText: 'Search products...',
                    prefixIcon: Icon(Icons.search),
                    border: OutlineInputBorder(),
                  ),
                  onChanged: _search,
                ),
              ),

              if (_loading) const LinearProgressIndicator(),

              Expanded(
                child: Builder(
                  builder: (context) {
                    final query = _controller.text.trim();

                    // 1) Emoty state
                    if (query.isEmpty && !_loading) {
                      return _emptyState(
                        'Start typing to search products',
                        'Try: “shoes”, “t-shirt”, “nike”',
                        icon: Icons.search,
                      );
                    }

                    // 2) Loading
                    if (_loading && _results.isEmpty) {
                      return _emptyState(
                        'Searching…',
                        'Fetching results from Algolia',
                        icon: Icons.hourglass_top,
                      );
                    }

                    // 3) Query without results
                    if (!_loading && query.isNotEmpty && _results.isEmpty) {
                      return _emptyState(
                        'No results found',
                        'Try another keyword or check spelling',
                        icon: Icons.search_off,
                      );
                    }

                    // 4) Results
                    return ListView.builder(
                      itemCount: _results.length,
                      itemBuilder: (_, index) {
                        final p = _results[index];

                        return Padding(
                          padding: const EdgeInsets.only(bottom: 10),
                          child: Card(
                            elevation: 0,
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(16),
                            ),
                            child: InkWell(
                              borderRadius: BorderRadius.circular(16),
                              onTap: () => context.go('/product/${p.objectID}'),
                              child: Padding(
                                padding: const EdgeInsets.all(14),
                                child: Row(
                                  children: [
                                    Expanded(
                                      child: Column(
                                        crossAxisAlignment:
                                            CrossAxisAlignment.start,
                                        children: [
                                          Text(
                                            p.title,
                                            style: const TextStyle(
                                              fontSize: 16,
                                              fontWeight: FontWeight.w800,
                                            ),
                                          ),
                                          const SizedBox(height: 8),
                                          Wrap(
                                            spacing: 8,
                                            runSpacing: 8,
                                            children: [
                                              Pill(text: p.brand),
                                              Pill(text: p.marketplace),
                                              Pill(text: p.status),
                                            ],
                                          ),
                                        ],
                                      ),
                                    ),
                                    const SizedBox(width: 10),
                                    ScoreBadge(qs: p.qualityScore),
                                  ],
                                ),
                              ),
                            ),
                          ),
                        );
                      },
                    );
                  },
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _emptyState(
    String title,
    String subtitle, {
    IconData icon = Icons.search,
  }) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(24),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(icon, size: 44, color: Colors.black38),
            const SizedBox(height: 12),
            Text(
              title,
              style: const TextStyle(fontSize: 16, fontWeight: FontWeight.w800),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 6),
            Text(
              subtitle,
              style: const TextStyle(color: Colors.black54),
              textAlign: TextAlign.center,
            ),
          ],
        ),
      ),
    );
  }

  Widget maxWidthBody(Widget child) {
    return Center(
      child: ConstrainedBox(
        constraints: const BoxConstraints(maxWidth: 980),
        child: child,
      ),
    );
  }
}
