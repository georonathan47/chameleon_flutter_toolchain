import 'package:chameleon_core/chameleon_core.dart';

/// App-specific failures, extending `chameleon_core`'s `Failure`.
///
/// `Failure` is `abstract base class` (not `sealed`) precisely so this file
/// can add to the hierarchy without touching the shared package. Add a
/// failure here whenever it's specific to this app's domain — a liveness
/// SDK's spoof/deepfake detections, a beneficiary-transfer limit, etc.
/// Generic failures (`NetworkFailure`, `ServerFailure`, `UnauthorizedFailure`,
/// `NotFoundFailure`, `UnexpectedFailure`, `UnknownFailure`, `CacheFailure`,
/// `ValidationFailure`) already live in `chameleon_core` — don't redeclare
/// them here.
final class LoginFailure extends Failure {
  const LoginFailure([
    super.message = 'Attempt to login failed. Please try again!',
  ]);
}
