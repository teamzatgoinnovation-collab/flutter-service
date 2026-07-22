import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import 'features/connection/connection_page.dart';
import 'features/login/login_page.dart';
import 'features/schedule/schedule_page.dart';
import 'features/shell/app_shell.dart';
import 'features/signoff/signoff_page.dart';
import 'features/tickets/ticket_detail_page.dart';
import 'features/tickets/tickets_page.dart';
import 'features/today/today_page.dart';
import 'services/session.dart';
import 'theme.dart';

final _routerProvider = Provider<GoRouter>((ref) {
  final session = ref.watch(serviceSessionProvider);

  return GoRouter(
    initialLocation: '/today',
    refreshListenable: session,
    redirect: (context, state) {
      final loggingIn = state.matchedLocation == '/login';
      if (!session.canEnterApp && !loggingIn) return '/login';
      if (session.canEnterApp && loggingIn) return '/today';
      return null;
    },
    routes: [
      GoRoute(path: '/login', builder: (context, state) => const LoginPage()),
      StatefulShellRoute.indexedStack(
        builder: (context, state, navigationShell) {
          return AppShell(navigationShell: navigationShell);
        },
        branches: [
          StatefulShellBranch(
            routes: [
              GoRoute(
                path: '/today',
                builder: (context, state) => const TodayPage(),
              ),
            ],
          ),
          StatefulShellBranch(
            routes: [
              GoRoute(
                path: '/tickets',
                builder: (context, state) => const TicketsPage(),
                routes: [
                  GoRoute(
                    path: ':id',
                    builder: (context, state) {
                      final id = state.pathParameters['id']!;
                      return TicketDetailPage(ticketId: id);
                    },
                  ),
                ],
              ),
            ],
          ),
          StatefulShellBranch(
            routes: [
              GoRoute(
                path: '/schedule',
                builder: (context, state) => const SchedulePage(),
              ),
            ],
          ),
          StatefulShellBranch(
            routes: [
              GoRoute(
                path: '/signoff',
                builder: (context, state) => const SignOffPage(),
              ),
            ],
          ),
          StatefulShellBranch(
            routes: [
              GoRoute(
                path: '/connection',
                builder: (context, state) => const ConnectionPage(),
              ),
            ],
          ),
        ],
      ),
    ],
  );
});

class FieldServiceApp extends ConsumerWidget {
  const FieldServiceApp({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final router = ref.watch(_routerProvider);
    return MaterialApp.router(
      title: 'ZatGo Field Service',
      theme: buildFieldServiceTheme(brightness: Brightness.light),
      darkTheme: buildFieldServiceTheme(brightness: Brightness.dark),
      themeMode: ThemeMode.system,
      routerConfig: router,
      debugShowCheckedModeBanner: false,
    );
  }
}
