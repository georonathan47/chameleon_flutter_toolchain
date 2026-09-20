import 'package:chameleon_core/chameleon_core.dart';
import 'package:get_it/get_it.dart';
import 'package:injectable/injectable.dart';

import 'injection_container.config.dart';

final GetIt getIt = GetIt.instance;

// injectable's "automatic" microPackage discovery (the `includeMicroPackages`
// default) does a plain filesystem glob rooted at this app's own directory —
// it never reaches chameleon_core's generated module once chameleon_core is
// a normal pub/git dependency rather than a physical sibling folder, which is
// how this app's local path: dependency happens to be laid out today.
// Listing it explicitly here works regardless of where the package
// physically lives.
@InjectableInit(
  preferRelativeImports: true,
  externalPackageModulesBefore: [ExternalModule(ChameleonCorePackageModule)],
)
Future<void> configureDependencies() async => getIt.init();
