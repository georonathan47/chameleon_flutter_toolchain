## What changed and why

<!-- One or two sentences on the problem or need this addresses — not just
     a restatement of the diff. -->

## Type of change

- [ ] Bug fix
- [ ] New feature
- [ ] Refactor / cleanup (no behavior change)
- [ ] Documentation
- [ ] CI / tooling

## Checklist

- [ ] `melos run analyze` and `melos run test` pass locally (covers `packages/chameleon_ui` and `packages/chameleon_core`)
- [ ] `packages/chameleon_lints`: `dart pub get && dart analyze && dart test` pass — it's outside the melos/pub workspace (a real `cli_util` version conflict with melos), so `melos run` never reaches it
- [ ] `cli/chameleon_cli`: `dart analyze` and `dart test -j 1` pass (use `-j 1` — default concurrency has been seen to silently drop suites in some sandboxes without reporting failure)
- [ ] If `bricks/chameleon_app`/`chameleon_feature`/`chameleon_state` changed: re-ran `mason bundle` for the affected brick(s) into `cli/chameleon_cli/lib/src/bundles/`, and the bundle diff is included in this PR
- [ ] If the brick(s) or CLI changed in a way that could affect a generated app: `bash e2e/run_matrix.sh` passes
- [ ] If `chameleon_ui`/`chameleon_core`/`chameleon_lints` changed in a way consuming apps need: noted below — a new `<package>-vX.Y.Z` tag needs pushing after merge (see the [Contributing wiki page](https://github.com/georonathan47/chameleon_flutter_toolchain/wiki/Contributing))
- [ ] If `chameleon_cli` changed in a way users should update for: noted below — a new `chameleon_cli-vX.Y.Z` tag needs pushing after merge

## Test plan

<!-- Exact commands you ran and their real output — not just "tests pass". -->

## Related issues

Closes #
