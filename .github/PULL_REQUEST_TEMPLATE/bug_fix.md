## Bug

<!-- What's broken, and for whom — e.g. "chameleon create --router auto_route
     fails build_runner with a duplicate route name". Link an issue if one
     exists. -->

## Root cause

<!-- What was actually wrong, not just where the symptom showed up. If this
     took real digging, say what you tried first that turned out not to be
     it — saves the next person from the same dead end. -->

## Fix

<!-- What changed, and why this is the actual fix rather than a workaround
     for the symptom. -->

## Regression test

- [ ] Added or updated a test that fails on `main` without this fix and passes with it
- [ ] If this was only caught by generating a real app (not a unit test): note exactly which `chameleon create`/`feature`/`bloc` flags reproduce it, so it can be added to `e2e/run_matrix.sh` if it's worth guarding permanently

## Checklist

- [ ] `melos run analyze` and `melos run test` pass locally (covers `packages/chameleon_ui` and `packages/chameleon_core`)
- [ ] `packages/chameleon_lints`: `dart pub get && dart analyze && dart test` pass (outside the melos workspace — see the [Contributing wiki page](https://github.com/georonathan47/chameleon_flutter_toolchain/wiki/Contributing))
- [ ] `cli/chameleon_cli`: `dart analyze` and `dart test -j 1` pass
- [ ] If `bricks/chameleon_app`/`chameleon_feature`/`chameleon_bloc` changed: re-ran `mason bundle` for the affected brick(s), bundle diff included
- [ ] If the brick(s) or CLI changed: `bash e2e/run_matrix.sh` passes
- [ ] If this fix needs a new tag for consuming apps/CLI users to actually get it: noted below

## Related issues

Fixes #
