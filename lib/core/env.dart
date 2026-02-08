class Env {
  static const algoliaAppId = String.fromEnvironment('ALGOLIA_APP_ID');
  static const algoliaSearchKey = String.fromEnvironment(
    'ALGOLIA_SEARCH_API_KEY',
  );
  static const algoliaIndexName = String.fromEnvironment('ALGOLIA_INDEX_NAME');
}
