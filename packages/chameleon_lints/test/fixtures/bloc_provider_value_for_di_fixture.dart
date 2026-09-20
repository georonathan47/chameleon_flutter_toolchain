// This fixture exists only to give BlocProviderValueForDi something to
// analyze — the unused constructor parameters are the point (BlocProvider's
// real constructors don't use theirs meaningfully either), not an oversight.
// ignore_for_file: avoid_unused_constructor_parameters

// A minimal stand-in for flutter_bloc's BlocProvider, and for injectable's
// @lazySingleton/@injectable annotations — the rule resolves the getIt<X>()
// type argument's own annotation, via its constant value's type name, so a
// stand-in class named LazySingleton/Injectable (matching injectable's real
// ones) is enough; no real dependency on flutter_bloc or injectable needed.
class Widget {}

class BlocProvider<T> extends Widget {
  BlocProvider({required T Function(Object context) create});
  BlocProvider.value({required T value});
}

class LazySingleton {
  const LazySingleton();
}

const lazySingleton = LazySingleton();

class Injectable {
  const Injectable();
}

const injectable = Injectable();

@lazySingleton
class SingletonBloc {}

@injectable
class FactoryBloc {}

T getIt<T>() => throw UnimplementedError();

Widget badCreate() {
  // triggers chameleon_bloc_provider_value_for_di — SingletonBloc is a
  // @lazySingleton, so getIt<SingletonBloc>() returns the same instance
  // every time; create: would close it out from under the container.
  return BlocProvider<SingletonBloc>(
    create: (context) => getIt<SingletonBloc>(),
  );
}

Widget goodCreateFactory() {
  // An @injectable factory is fine with create: — a fresh instance every
  // call, nothing else holds a reference to dispose out from under.
  return BlocProvider<FactoryBloc>(create: (context) => getIt<FactoryBloc>());
}

Widget goodValue(SingletonBloc bloc) {
  return BlocProvider<SingletonBloc>.value(value: bloc);
}

Widget goodCreateOwnedByWidget() {
  return BlocProvider<SingletonBloc>(create: (context) => SingletonBloc());
}
