import 'package:go_router/go_router.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import '../../features/auth/presentation/pages/login_page.dart';
import '../../features/boards/presentation/pages/board_selector_page.dart';
import '../../features/boards/presentation/pages/board_view_page.dart';

final appRouter = GoRouter(
  initialLocation: '/',
  redirect: (context, state) {
    final session = Supabase.instance.client.auth.currentSession;
    final isLoggingIn = state.matchedLocation == '/login';

    if (session == null) {
      return isLoggingIn ? null : '/login';
    }

    if (isLoggingIn) {
      return '/';
    }

    return null;
  },
  routes: [
    GoRoute(path: '/login', builder: (context, state) => const LoginPage()),
    GoRoute(path: '/', builder: (context, state) => const BoardSelectorPage()),
    GoRoute(
      path: '/board/:id',
      builder: (context, state) {
        final boardId = state.pathParameters['id']!;
        return BoardViewPage(boardId: boardId);
      },
    ),
  ],
);
