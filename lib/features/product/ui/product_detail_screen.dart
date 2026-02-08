import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import '../../search/data/algolia_search_api.dart';
import '../../search/domain/product.dart';
import '../../../core/http/dio_client.dart';

class ProductDetailScreen extends StatefulWidget {
  const ProductDetailScreen({super.key, required this.objectId});

  final String objectId;

  @override
  State<ProductDetailScreen> createState() => _ProductDetailScreenState();
}

class _ProductDetailScreenState extends State<ProductDetailScreen> {
  final _api = AlgoliaSearchApi(DioClient.create());
  Product? _product;
  bool _loading = true;

  @override
  void initState() {
    super.initState();
    _loadProduct();
  }

  Future<void> _loadProduct() async {
    final json = await _api.getProductById(widget.objectId);
    if (json != null) {
      setState(() => _product = Product.fromJson(json));
    }
    setState(() => _loading = false);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Product Detail')),
      body: _loading
          ? const Center(child: CircularProgressIndicator())
          : _product == null
          ? const Center(child: Text('Product not found'))
          : Center(
              child: Padding(
                padding: const EdgeInsets.all(48.0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.center,
                  children: [
                    Text(
                      _product!.title,
                      style: Theme.of(context).textTheme.headlineSmall,
                    ),
                    const SizedBox(height: 8),
                    Text('${_product!.brand} · ${_product!.marketplace}'),
                    const SizedBox(height: 16),

                    Text('Quality Score: ${_product!.qualityScore}'),

                    const SizedBox(height: 16),
                    if (_product!.missingFields.isNotEmpty) ...[
                      const Text(
                        'Issues detected',
                        style: TextStyle(fontWeight: FontWeight.bold),
                      ),
                      const SizedBox(height: 8),
                      Wrap(
                        spacing: 8,
                        children: _product!.missingFields
                            .map(
                              (f) => Chip(
                                label: Text(f),
                                backgroundColor: Colors.orange.shade100,
                              ),
                            )
                            .toList(),
                      ),
                    ],

                    const Spacer(),

                    ElevatedButton(
                      onPressed: () =>
                          context.go('/copilot?product=${_product!.objectID}'),
                      child: const Text('Ask Copilot about this product'),
                    ),
                  ],
                ),
              ),
            ),
    );
  }
}
