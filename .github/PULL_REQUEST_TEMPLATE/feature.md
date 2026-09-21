## What this adds

<!-- The capability, from a user's perspective — e.g.
     "chameleon create --router auto_route". Not an implementation summary. -->

## Why

<!-- What need this addresses. Link a discussion/issue if one exists. -->

## Scope

- [ ] New brick var(s) / CLI flag(s) — list them below, with their defaults
- [ ] New package or dependency added — name it and justify why it's a
      default rather than opt-in (see [Architecture](https://github.com/georonathan47/chameleon_flutter_toolchain/wiki/Architecture)
      on why every vendor integration in this toolchain ships a no-op
      default rather than assuming one)
- [ ] Explicitly out of scope for this PR (deferred, not forgotten):

<!-- New vars/flags and their defaults: -->

## Verification

- [ ] Generated a real app exercising this feature (`chameleon create ... <the-new-flag>`) and confirmed `flutter analyze` + `flutter test` + `dart run custom_lint` all pass — not just that generation completed
- [ ] Regression-checked the *default* path still works unchanged (a new flag shouldn't alter behavior for anyone not using it)
- [ ] Added this flag combination to `e2e/run_matrix.sh` if it's one worth guarding against regression permanently, and confirmed `bash e2e/run_matrix.sh` passes
- [ ] Docs updated: root `README.md`, and the relevant wiki page(s) (likely [CLI Reference](https://github.com/georonathan47/chameleon_flutter_toolchain/wiki/CLI-Reference) and/or [Architecture](https://github.com/georonathan47/chameleon_flutter_toolchain/wiki/Architecture))

## Checklist

- [ ] `melos run analyze` and `melos run test` pass locally
- [ ] `packages/chameleon_lints`: `dart pub get && dart analyze && dart test` pass (outside the melos workspace)
- [ ] `cli/chameleon_cli`: `dart analyze` and `dart test -j 1` pass
- [ ] If `bricks/chameleon_app`/`chameleon_feature`/`chameleon_bloc` changed: re-ran `mason bundle`, bundle diff included
- [ ] If `chameleon_ui`/`chameleon_core`/`chameleon_lints`/`chameleon_cli` need a new tag for this to reach users: noted below

## Related issues

Closes #
