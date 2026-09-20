import 'package:flutter_test/flutter_test.dart';

import 'package:{{project_name.snakeCase()}}/core/router/route_guard.dart';

void main() {
  const signIn = '/sign-in';
  const home = '/';

  test('AuthUnknown never redirects — the router holds until resolved', () {
    final result = authRedirect(
      authState: const AuthUnknown(),
      location: '/anything',
      signInRoute: signIn,
      homeRoute: home,
      locationIsPublic: false,
    );
    expect(result, isNull);
  });

  test('Unauthenticated redirects a private route to sign-in', () {
    final result = authRedirect(
      authState: const Unauthenticated(),
      location: '/accounts',
      signInRoute: signIn,
      homeRoute: home,
      locationIsPublic: false,
    );
    expect(result, signIn);
  });

  test('Unauthenticated does not redirect a public route', () {
    final result = authRedirect(
      authState: const Unauthenticated(),
      location: '/onboarding',
      signInRoute: signIn,
      homeRoute: home,
      locationIsPublic: true,
    );
    expect(result, isNull);
  });

  test('Authenticated redirects away from sign-in', () {
    final result = authRedirect(
      authState: const Authenticated(),
      location: signIn,
      signInRoute: signIn,
      homeRoute: home,
      locationIsPublic: false,
    );
    expect(result, home);
  });

  test('Authenticated does not redirect an ordinary private route', () {
    final result = authRedirect(
      authState: const Authenticated(),
      location: '/accounts',
      signInRoute: signIn,
      homeRoute: home,
      locationIsPublic: false,
    );
    expect(result, isNull);
  });
}
