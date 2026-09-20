import 'dart:io';

import 'package:chameleon_cli/src/updater.dart';
import 'package:pub_semver/pub_semver.dart';
import 'package:test/test.dart';

import 'support/fake_process_runner.dart';

ProcessResult _lsRemote(String body) => ProcessResult(0, 0, body, '');

void main() {
  group('Updater.latestTag', () {
    test('returns null when the remote has no matching tags', () async {
      final runner = FakeProcessRunner(
        onRun: (_, _) => _lsRemote(
          'abc123\trefs/tags/some-other-thing-v1.0.0\n',
        ),
      );
      final updater = Updater(runner: runner);

      final latest = await updater.latestTag(
        'https://example.com/repo.git',
        'chameleon_cli-v',
      );

      expect(latest, isNull);
    });

    test('returns the single matching tag', () async {
      final runner = FakeProcessRunner(
        onRun: (_, _) => _lsRemote('abc123\trefs/tags/chameleon_cli-v1.2.3\n'),
      );
      final updater = Updater(runner: runner);

      final latest = await updater.latestTag(
        'https://example.com/repo.git',
        'chameleon_cli-v',
      );

      expect(latest, Version(1, 2, 3));
    });

    test('returns the highest of multiple matching tags', () async {
      final runner = FakeProcessRunner(
        onRun: (_, _) => _lsRemote(
          'a\trefs/tags/chameleon_cli-v1.0.0\n'
          'b\trefs/tags/chameleon_cli-v1.2.0\n'
          'c\trefs/tags/chameleon_cli-v1.1.5\n',
        ),
      );
      final updater = Updater(runner: runner);

      final latest = await updater.latestTag(
        'https://example.com/repo.git',
        'chameleon_cli-v',
      );

      expect(latest, Version(1, 2, 0));
    });

    test(
      'ignores tags with a different prefix and malformed versions',
      () async {
        final runner = FakeProcessRunner(
          onRun: (_, _) => _lsRemote(
            'a\trefs/tags/chameleon_ui-v9.9.9\n'
            'b\trefs/tags/chameleon_cli-vNOT-A-VERSION\n'
            'c\trefs/tags/chameleon_cli-v2.0.0\n',
          ),
        );
        final updater = Updater(runner: runner);

        final latest = await updater.latestTag(
          'https://example.com/repo.git',
          'chameleon_cli-v',
        );

        expect(latest, Version(2, 0, 0));
      },
    );

    test('throws UpdaterException when git ls-remote fails', () async {
      final runner = FakeProcessRunner(
        onRun: (_, _) => ProcessResult(0, 1, '', 'fatal: could not read'),
      );
      final updater = Updater(runner: runner);

      expect(
        () => updater.latestTag(
          'https://example.com/repo.git',
          'chameleon_cli-v',
        ),
        throwsA(isA<UpdaterException>()),
      );
    });
  });
}
