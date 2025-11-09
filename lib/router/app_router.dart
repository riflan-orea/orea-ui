import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../providers/auth_provider.dart';
import '../pages/login_page.dart';
import '../pages/dashboard_page.dart';
import '../pages/reactive_form_page.dart';
import '../pages/users_page.dart';
import '../widgets/app_layout.dart';

// Router provider
final routerProvider = Provider<GoRouter>((ref) {
  final authState = ref.watch(authProvider);

  return GoRouter(
    initialLocation: '/',
    debugLogDiagnostics: true,
    refreshListenable: GoRouterRefreshStream(ref),
    redirect: (context, state) {
      // If auth is still loading, show nothing (or a loading screen)
      if (authState.isLoading) {
        return null;
      }

      final isAuthenticated = authState.isAuthenticated;
      final isGoingToLogin = state.matchedLocation == '/login';

      // If not authenticated and not going to login, redirect to login
      if (!isAuthenticated && !isGoingToLogin) {
        return '/login';
      }

      // If authenticated and going to login, redirect to dashboard
      if (isAuthenticated && isGoingToLogin) {
        return '/';
      }

      // No redirect needed
      return null;
    },
    routes: [
      // Login route (no layout)
      GoRoute(
        path: '/login',
        name: 'login',
        builder: (context, state) => const LoginPage(),
      ),
      // Protected routes with layout (using ShellRoute)
      ShellRoute(
        builder: (context, state, child) {
          return AppLayout(
            title: _getPageTitle(state.matchedLocation),
            child: child,
          );
        },
        routes: [
          GoRoute(
            path: '/',
            name: 'dashboard',
            pageBuilder: (context, state) => const NoTransitionPage(
              child: DashboardPage(),
            ),
          ),
          GoRoute(
            path: '/reactive-form',
            name: 'reactive-form',
            pageBuilder: (context, state) => const NoTransitionPage(
              child: ReactiveFormPage(),
            ),
          ),
          GoRoute(
            path: '/users',
            name: 'users',
            pageBuilder: (context, state) => const NoTransitionPage(
              child: UsersPage(),
            ),
          ),
        ],
      ),
    ],
  );
});

// Helper class to refresh router when auth state changes
class GoRouterRefreshStream extends ChangeNotifier {
  GoRouterRefreshStream(this.ref) {
    ref.listen<AuthState>(
      authProvider,
      (previous, next) {
        if (previous?.isAuthenticated != next.isAuthenticated) {
          notifyListeners();
        }
      },
    );
  }

  final Ref ref;
}

// Helper function to get page title based on route
String _getPageTitle(String location) {
  switch (location) {
    case '/':
      return 'Dashboard';
    case '/reactive-form':
      return 'Reactive Form Demo';
    case '/users':
      return 'Users Management';
    case '/settings':
      return 'Settings';
    case '/help':
      return 'Help';
    default:
      return 'Orea UI';
  }
}
