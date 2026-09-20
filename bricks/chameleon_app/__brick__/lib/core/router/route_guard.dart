/// Session state a router redirect decides against.
///
/// A plain `bool isAuthenticated` forces "not yet known" to read as "signed
/// out," which bounces a returning user to login for the frames before
/// secure storage is read. This tri-state lets the redirect hold — return
/// `null` from a `GoRouter.redirect` while [AuthUnknown] — instead.
sealed class AuthState {
  const AuthState();
}

/// Secure storage hasn't been read yet. The redirect should return `null`
/// (no redirect) while in this state, not bounce to login.
final class AuthUnknown extends AuthState {
  const AuthUnknown();
}

final class Authenticated extends AuthState {
  const Authenticated();
}

final class Unauthenticated extends AuthState {
  const Unauthenticated();
}

/// Decides whether a navigation to [location] should be redirected, given the
/// current [authState].
///
/// Pure and framework-agnostic on purpose — no `BuildContext`, no
/// `GoRouterState` — so it's unit-testable without booting a router. Returns
/// `null` to allow the navigation through unchanged.
///
/// [signInRoute] and [homeRoute] are the app's own route paths; this function
/// doesn't hard-code them so it has no dependency on the app's route table.
String? authRedirect({
  required AuthState authState,
  required String location,
  required String signInRoute,
  required String homeRoute,
  required bool locationIsPublic,
}) {
  switch (authState) {
    case AuthUnknown():
      // Hold — don't redirect until secure storage has actually been read.
      return null;
    case Unauthenticated():
      if (locationIsPublic || location == signInRoute) return null;
      return signInRoute;
    case Authenticated():
      if (location == signInRoute) return homeRoute;
      return null;
  }
}
