// This fixture exists only to give ChopperRequiresErrorCheck something to
// analyze.

import 'package:chopper/chopper.dart';

// Bad: uses .body and never looks at isSuccessful/error.
int? unchecked(Response<int> response) {
  return response.body; // triggers chameleon_chopper_requires_error_check
}

// Bad: no variable to tie a check to.
Future<int?> uncheckedInline(Future<Response<int>> call) async {
  return (await call).body; // triggers chameleon_chopper_requires_error_check
}

// Good: isSuccessful is checked.
int checkedIsSuccessful(Response<int> response) {
  if (!response.isSuccessful) throw StateError('failed');
  return response.body!;
}

// Good: error is checked.
int? checkedError(Response<int> response) {
  if (response.error != null) throw StateError('failed');
  return response.body;
}

// Good: chameleon_feature's generated shape — .body is read *before* the
// isSuccessful check, in the same function. Must not be flagged.
int generatedShape(Response<int> response) {
  final value = response.body;
  if (!response.isSuccessful || value == null) {
    throw StateError('failed');
  }
  return value;
}

// Good: a different type's .body is unrelated to chopper.
class Envelope {
  int? get body => 1;
}

int? unrelated(Envelope envelope) => envelope.body;
