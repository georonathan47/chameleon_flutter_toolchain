{{#use_go_router}}
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
{{/use_go_router}}
{{^use_go_router}}
import 'package:auto_route/auto_route.dart';
import 'package:flutter/material.dart';

part 'app_router.gr.dart';

abstract final class AppRoutes {
  static const home = '/';
}

/// The app's router.
///
/// TODO(chameleon): once a real auth feature exists, wire a
/// `AutoRouteGuard` (or an `AutoRedirectGuard`) driven by `authRedirect`
/// from `route_guard.dart` and that feature's `AuthState` stream (see
/// `route_guard.dart`'s doc comment for the tri-state rationale, and
/// `tasks/lessons.md` #5). Left unwired for now — there is no session state
/// to guard yet.
///
/// TODO(chameleon): deep links (password reset, magic link, etc.) need no
/// special handling here beyond declaring the real `AutoRoute` — this app
/// already uses `MaterialApp.router` (see `lib/app/view/app.dart`), so
/// Flutter's own `PlatformRouteInformationProvider` hands auto_route both
/// the cold-start link and every subsequent one automatically. What's still
/// missing is the native registration that lets the OS ever hand the app a
/// link in the first place: `CFBundleURLTypes` in `ios/Runner/Info.plist`
/// and an `autoVerify` intent-filter in `AndroidManifest.xml` —
/// `tool/checks.sh` fails until both exist. Once a deep-linked route needs
/// to be auth-gated, route it through a guard rather than a one-off check.
@AutoRouterConfig()
class AppRouter extends RootStackRouter {
  @override
  List<AutoRoute> get routes => [
    AutoRoute(page: HomeRoute.page, path: AppRoutes.home, initial: true),
    // Fallback-only substitute for go_router's `onException` handler:
    // auto_route has no directly equivalent "log then redirect" hook, so
    // this isn't faked here — an unmatched path just redirects to home,
    // with no `ChameleonLogger`-based exception logging. That logging gap
    // is real; wire it (e.g. via a custom `RouteFactory` / navigator
    // observer, or a dedicated not-found page that logs the failed path
    // before redirecting) if it's needed before this TODO is otherwise
    // resolved. `AutoRoute(page: HomeRoute.page, path: '*')` was
    // considered instead but rejected: auto_route keys routes by page
    // name, so reusing `HomeRoute.page` for a second entry throws
    // `ArgumentError: Route name must be unique` at runtime —
    // `RedirectRoute` (which derives its own unique name from
    // path + redirectTo) is the correct primitive for this.
    RedirectRoute(path: '*', redirectTo: AppRoutes.home),
  ];
}

/// The app's router.
final AppRouter appRouter = AppRouter();

/// Stands in for a real home page until one exists. Replace once the first
/// feature ships.
@RoutePage(name: 'HomeRoute')
class _PlaceholderHomePage extends StatelessWidget {
  const _PlaceholderHomePage();

  @override
  Widget build(BuildContext context) {
    return const Scaffold(
      body: Center(child: Text('chameleon_app')),
    );
  }
}
{{/use_go_router}}
