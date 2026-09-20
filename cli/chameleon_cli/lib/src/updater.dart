import 'package:pub_semver/pub_semver.dart';

import 'process_runner.dart';

/// Finds the highest tagged `chameleon_cli` release in a git remote, so
/// `chameleon update` can decide whether to reactivate. Pure and unit-testable
/// against a fake [ProcessRunner] — the real end-to-end path (a genuine
/// `git ls-remote` against a disposable local repo) is verified separately,
/// since this toolchain has no real remote yet.
class Updater {
  Updater({required this.runner});

  final ProcessRunner runner;

  /// Returns the highest `<refPrefix>X.Y.Z` tag in [repoUrl] as a [Version],
  /// or null if the remote has none matching. Tags that don't parse as
  /// valid semver once [refPrefix] is stripped are skipped, not fatal —
  /// a git tag namespace can carry other, unrelated tags.
  Future<Version?> latestTag(String repoUrl, String refPrefix) async {
    final result = await runner.run('git', [
      'ls-remote',
      '--tags',
      '--refs',
      repoUrl,
    ]);
    if (result.exitCode != 0) {
      throw UpdaterException(
        'git ls-remote failed for $repoUrl:\n${result.stderr}',
      );
    }

    final output = '${result.stdout}';
    Version? highest;
    for (final line in output.split('\n')) {
      final tabIndex = line.indexOf('\t');
      if (tabIndex == -1) continue;
      final ref = line.substring(tabIndex + 1).trim();
      const tagsPrefix = 'refs/tags/';
      if (!ref.startsWith(tagsPrefix)) continue;
      final tag = ref.substring(tagsPrefix.length);
      if (!tag.startsWith(refPrefix)) continue;

      final versionText = tag.substring(refPrefix.length);
      final Version version;
      try {
        version = Version.parse(versionText);
      } on FormatException {
        continue;
      }
      if (highest == null || version > highest) highest = version;
    }
    return highest;
  }
}

class UpdaterException implements Exception {
  UpdaterException(this.message);
  final String message;

  @override
  String toString() => message;
}
