## 0.1.0

- Initial release, forked from a private `calbank_core` package.
- Errors/failures, chopper-based networking (auth, retry, idempotency,
  logging interceptors), biometrics, secure storage, DI (injectable
  micro-package), connectivity bloc, and a pluggable logging service with
  Noop-by-default crash/analytics reporters.
- Feature flags: vendor-neutral `FeatureFlags` interface with a
  `NoopFeatureFlags` default. No Firebase dependency — see the README for
  how to wire a real backend from a consuming app.
