/// This CLI's own version — kept in sync with pubspec.yaml's `version:` by
/// hand, the same pattern `package:mason` itself uses for `packageVersion`.
/// Avoids fragile runtime probing (parsing `dart pub global list` output,
/// `Platform.script`) to find "my own version" once globally activated.
const packageVersion = '0.4.0';
