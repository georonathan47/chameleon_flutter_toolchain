// This fixture exists only to give DatasourceRequiresIsolate something to
// analyze — it lives under data/datasources/ so the rule's path scope
// matches.

class BadDataSource {
  // Runs its work on the calling (UI) isolate.
  Future<int> fetch() async =>
      1; // triggers chameleon_datasource_requires_isolate
}
