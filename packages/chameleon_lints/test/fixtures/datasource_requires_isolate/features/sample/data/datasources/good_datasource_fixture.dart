// The shapes DatasourceRequiresIsolate must NOT flag, including the exact
// shape chameleon_feature's generated remote datasource uses today.

import 'dart:isolate';

// Stand-ins for chameleon_core's isolate helpers (the rule matches by name).
Future<R> runApiCall<R>(int call, Future<R> Function(int call) endpoint) =>
    endpoint(call);
Future<R> runInIsolate<R>(R Function() callback) async => callback();

// A top-level worker is the isolate body itself — not checked.
Future<int> fetchThing(int call) async => call;

// Mirrors the generated interface, one method and all.
// ignore: one_member_abstracts
abstract interface class ThingRemoteDataSource {
  Future<int> getThing(); // abstract: no body
}

class ThingRemoteDataSourceImpl implements ThingRemoteDataSource {
  // The generated brick's exact shape.
  @override
  Future<int> getThing() => runApiCall(1, fetchThing);

  Future<int> viaRunInIsolate() => runInIsolate(() => 1);

  Future<int> viaIsolateRun() => Isolate.run(() => 1);

  // Deliberately unreferenced: only its being private matters to the rule.
  // ignore: unused_element
  Future<int> _privateHelper() async => 1; // private: not an entry point

  static Future<int> staticWorker() async => 1; // static: a worker

  int get cached => 1; // getter: not checked
}
