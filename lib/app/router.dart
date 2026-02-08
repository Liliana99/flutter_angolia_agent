import 'package:flutter_challenge/features/search/ui/search_screen.dart';
import 'package:go_router/go_router.dart';

import '../features/product/ui/product_detail_screen.dart';
import '../features/copilot/ui/copilot_screen.dart';

final appRouter = GoRouter(
  initialLocation: '/search',
  routes: [
    GoRoute(path: '/search', builder: (_, __) => const SearchScreen()),
    GoRoute(
      path: '/product/:id',
      builder: (_, state) =>
          ProductDetailScreen(objectId: state.pathParameters['id']!),
    ),
    GoRoute(path: '/copilot', builder: (_, __) => const CopilotScreen()),
  ],
);
