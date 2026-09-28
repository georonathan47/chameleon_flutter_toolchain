// Outside data/datasources/ — the rule's path scope must skip this file.

class NotADataSource {
  Future<int> fetch() async => 1;
}
