import 'dart:async';

import 'package:bloc_test/bloc_test.dart';
import 'package:chameleon_core/chameleon_core.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';

class _MockNetworkInfo extends Mock implements NetworkInfo {}

void main() {
  late _MockNetworkInfo networkInfo;
  late StreamController<bool> connectivityChanges;

  void stubIsConnected({required bool value}) {
    when(() => networkInfo.isConnected).thenAnswer((_) async => value);
  }

  setUp(() {
    networkInfo = _MockNetworkInfo();
    connectivityChanges = StreamController<bool>.broadcast();
    when(
      () => networkInfo.onConnectivityChanged,
    ).thenAnswer((_) => connectivityChanges.stream);
  });

  tearDown(() => connectivityChanges.close());

  blocTest<ConnectivityBloc, ConnectivityState>(
    'starts at ConnectivityInitial',
    setUp: () => stubIsConnected(value: true),
    build: () => ConnectivityBloc(networkInfo),
    verify: (bloc) => expect(bloc.state, const ConnectivityInitial()),
  );

  blocTest<ConnectivityBloc, ConnectivityState>(
    'ConnectivityCheckRequested re-checks isConnected rather than trusting '
    'a cached value',
    setUp: () => stubIsConnected(value: true),
    build: () => ConnectivityBloc(networkInfo),
    act: (bloc) => bloc.add(const ConnectivityCheckRequested()),
    expect: () => [const ConnectivityOnline()],
  );

  blocTest<ConnectivityBloc, ConnectivityState>(
    'a stream event reporting offline still re-verifies via isConnected',
    setUp: () => stubIsConnected(value: true),
    build: () => ConnectivityBloc(networkInfo),
    act: (bloc) => connectivityChanges.add(false),
    // isConnected says true even though the stream said false — the bloc
    // trusts the re-check, not the raw stream event (guards against
    // connectivity_plus's offline-without-online flap on a transport change).
    expect: () => [const ConnectivityOnline()],
  );

  blocTest<ConnectivityBloc, ConnectivityState>(
    'a stream event confirmed by isConnected reports offline',
    setUp: () => stubIsConnected(value: false),
    build: () => ConnectivityBloc(networkInfo),
    act: (bloc) => connectivityChanges.add(false),
    expect: () => [const ConnectivityOffline()],
  );
}
