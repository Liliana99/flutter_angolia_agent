// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'product.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

_$ProductImpl _$$ProductImplFromJson(Map<String, dynamic> json) =>
    _$ProductImpl(
      objectID: json['objectID'] as String,
      title: json['title'] as String,
      brand: json['brand'] as String,
      category: json['category'] as String,
      marketplace: json['marketplace'] as String,
      status: json['status'] as String,
      qualityScore: (json['qualityScore'] as num).toInt(),
      missingFields:
          (json['missingFields'] as List<dynamic>?)
              ?.map((e) => e as String)
              .toList() ??
          const <String>[],
      description: json['description'] as String?,
      sku: json['sku'] as String?,
    );

Map<String, dynamic> _$$ProductImplToJson(_$ProductImpl instance) =>
    <String, dynamic>{
      'objectID': instance.objectID,
      'title': instance.title,
      'brand': instance.brand,
      'category': instance.category,
      'marketplace': instance.marketplace,
      'status': instance.status,
      'qualityScore': instance.qualityScore,
      'missingFields': instance.missingFields,
      'description': instance.description,
      'sku': instance.sku,
    };
