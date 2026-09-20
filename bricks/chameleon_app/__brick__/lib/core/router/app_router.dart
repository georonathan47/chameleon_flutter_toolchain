import 'package:chameleon_core/chameleon_core.dart';
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

abstract final class AppRoutes {
  static const home = '/';
}

/// The app's router.
///
/// TODO(chameleon): once a real auth feature exists, wire `redirect` to
/// `authRedirect` from `route_guard.dart`, driven by that feature's
/// `AuthState` stream (see `route_guard.dart`'s doc comment for the tri-state
/// rationale, and `tasks/lessons.md` #5). Left unwired for now — there is no
/// session state to guard yet.
///
/// TODO(chameleon): deep links (password reset, magic link, etc.) need no
/// special handling here beyond declaring the real `GoRoute` — this app
/// already uses `MaterialApp.router` (see `lib/app/view/app.dart`), so
/// Flutter's own `PlatformRouteInformationProvider` hands GoRouter both the
/// cold-start link and every subsequent one automatically. What's still
/// missing is the native registration that lets the OS ever hand the app a
/// link in the first place: `CFBundleURLTypes` in `ios/Runner/Info.plist`
/// and an `autoVerify` intent-filter in `AndroidManifest.xml` —
/// `tool/checks.sh` fails until both exist. Once a deep-linked route needs
/// to be auth-gated, route it through the `redirect` above rather than a
/// one-off check.
final GoRouter appRouter = GoRouter(
  initialLocation: AppRoutes.home,
  routes: [
    GoRoute(
      path: AppRoutes.home,
      builder: (context, state) => const _PlaceholderHomePage(),
    ),
  ],
  onException: (context, state, router) {
    ChameleonLogger.warning('Router exception for ${state.uri}');
    router.go(AppRoutes.home);
  },
);

/// Stands in for a real home page until one exists. Replace once the first
/// feature ships.
class _PlaceholderHomePage extends StatelessWidget {
  const _PlaceholderHomePage();

  @override
  Widget build(BuildContext context) {
    return const Scaffold(
      body: Center(child: Text('chameleon_app')),
    );
  }
}
