import 'package:dio/dio.dart';
import 'package:flutter/material.dart';
import '../../../core/env.dart';

class AlgoliaSearchApi {
  AlgoliaSearchApi(this._dio);

  final Dio _dio;

  Future<List<Map<String, dynamic>>> search({
    required String query,
    int hitsPerPage = 20,
    String? filters,
  }) async {
    final url =
        'https://${Env.algoliaAppId}-dsn.algolia.net/1/indexes/${Env.algoliaIndexName}/query';

    debugPrint('ALGOLIA url: $url');
    debugPrint('ALGOLIA appId: ${Env.algoliaAppId}');
    debugPrint('ALGOLIA index: ${Env.algoliaIndexName}');

    try {
      final response = await _dio.post(
        url,
        data: {
          'query': query,
          'params': _encodeParams({
            'hitsPerPage': hitsPerPage,
            'filters': filters,
          }),
        },
        options: Options(
          headers: {
            'X-Algolia-API-Key': Env.algoliaSearchKey,
            'X-Algolia-Application-Id': Env.algoliaAppId,
          },
        ),
      );

      final hits = response.data['hits'] as List<dynamic>;
      return hits.cast<Map<String, dynamic>>();
    } on DioException catch (e) {
      debugPrint('ALGOLIA ERROR STATUS: ${e.response?.statusCode}');
      debugPrint('ALGOLIA ERROR DATA: ${e.response?.data}');
      rethrow;
    }
  }

  String _encodeParams(Map<String, dynamic> params) {
    final entries = <String>[];
    params.forEach((k, v) {
      if (v == null || v.toString().isEmpty) return;
      entries.add(
        '${Uri.encodeQueryComponent(k)}=${Uri.encodeQueryComponent('$v')}',
      );
    });
    return entries.join('&');
  }

  Future<Map<String, dynamic>?> getProductById(String objectId) async {
    final url =
        'https://${Env.algoliaAppId}-dsn.algolia.net/1/indexes/${Env.algoliaIndexName}/$objectId';

    try {
      final response = await _dio.get(
        url,
        options: Options(
          headers: {
            'X-Algolia-API-Key': Env.algoliaSearchKey,
            'X-Algolia-Application-Id': Env.algoliaAppId,
          },
        ),
      );

      return response.data as Map<String, dynamic>;
    } on DioException catch (e) {
      debugPrint('GET PRODUCT ERROR: ${e.response?.data}');
      return null;
    }
  }

  Future<List<Map<String, dynamic>>> searchProducts({
    required String query,
    int hitsPerPage = 20,
    String? filters,
    List<String>? numericFilters,
  }) async {
    final url =
        'https://${Env.algoliaAppId}-dsn.algolia.net/1/indexes/${Env.algoliaIndexName}/query';

    final params = <String, dynamic>{
      'hitsPerPage': hitsPerPage,
      'filters': filters,
    };

    // Algolia espera numericFilters como array (en JSON), no querystring
    final response = await _dio.post(
      url,
      data: {
        'query': query,
        'params': _encodeParams(params),
        if (numericFilters != null) 'numericFilters': numericFilters,
      },
      options: Options(
        headers: {
          'X-Algolia-API-Key': Env.algoliaSearchKey,
          'X-Algolia-Application-Id': Env.algoliaAppId,
        },
      ),
    );

    final hits = response.data['hits'] as List<dynamic>;
    return hits.cast<Map<String, dynamic>>();
  }
}
