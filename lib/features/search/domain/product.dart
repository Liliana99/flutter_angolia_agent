import 'package:freezed_annotation/freezed_annotation.dart';

part 'product.freezed.dart';
part 'product.g.dart';

@freezed
class Product with _$Product {
  const factory Product({
    required String objectID,
    required String title,
    required String brand,
    required String category,
    required String marketplace,
    required String status,
    required int qualityScore,
    @Default(<String>[]) List<String> missingFields,
    String? description,
    String? sku,
  }) = _Product;

  factory Product.fromJson(Map<String, dynamic> json) =>
      _$ProductFromJson(json);
}
