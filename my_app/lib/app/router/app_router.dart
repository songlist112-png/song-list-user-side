import 'package:go_router/go_router.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import '../../features/auth/presentation/pages/login_page.dart';
import '../../features/boards/presentation/pages/board_selector_page.dart';
import '../../features/boards/presentation/pages/board_view_page.dart';
import '../../features/legal/presentation/pages/legal_policy_page.dart';
import '../../features/support/presentation/pages/create_ticket_page.dart';
import '../../features/support/presentation/pages/help_feedback_page.dart';
import '../../features/support/presentation/pages/my_tickets_page.dart';
import '../../features/support/presentation/pages/ticket_details_page.dart';
import '../../features/subscription/presentation/widgets/subscription_gate.dart';
import '../../features/sync/presentation/widgets/initial_sync_gate.dart';

final appRouter = GoRouter(
  initialLocation: '/',
  redirect: (context, state) {
    final session = Supabase.instance.client.auth.currentSession;
    final location = state.matchedLocation;
    final isPublicRoute =
        location == '/login' || location == '/terms' || location == '/privacy';

    if (session == null) {
      return isPublicRoute ? null : '/login';
    }

    if (location == '/login') {
      return '/';
    }

    return null;
  },
  routes: [
    GoRoute(path: '/login', builder: (context, state) => const LoginPage()),
    GoRoute(
      path: '/terms',
      builder: (context, state) => LegalPolicyPage(
        title: 'Terms of Service',
        sections: termsOfServiceSections(),
      ),
    ),
    GoRoute(
      path: '/privacy',
      builder: (context, state) => LegalPolicyPage(
        title: 'Privacy Policy',
        sections: privacyPolicySections(),
      ),
    ),
    ShellRoute(
      builder: (context, state, child) =>
          InitialSyncGate(child: SubscriptionGate(child: child)),
      routes: [
        GoRoute(
          path: '/',
          builder: (context, state) => const BoardSelectorPage(),
        ),
        GoRoute(
          path: '/board/:id',
          builder: (context, state) {
            final boardId = state.pathParameters['id']!;
            return BoardViewPage(boardId: boardId);
          },
        ),
      ],
    ),
    GoRoute(
      path: '/support',
      builder: (context, state) => const HelpFeedbackPage(),
      routes: [
        GoRoute(
          path: 'new',
          builder: (context, state) => const CreateTicketPage(),
        ),
        GoRoute(
          path: 'tickets',
          builder: (context, state) => const MyTicketsPage(),
          routes: [
            GoRoute(
              path: ':id',
              builder: (context, state) =>
                  TicketDetailsPage(ticketId: state.pathParameters['id']!),
            ),
          ],
        ),
      ],
    ),
  ],
);
