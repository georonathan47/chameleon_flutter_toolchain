import 'package:chameleon_core/chameleon_core.dart';
import 'package:chameleon_ui/chameleon_ui.dart';
import 'package:flutter/material.dart';
{{#is_bloc}}
import 'package:flutter_bloc/flutter_bloc.dart';
{{/is_bloc}}
{{#is_provider}}
import 'package:provider/provider.dart';
{{/is_provider}}

import '../../core/di/injection_container.dart';
import '../../core/router/app_router.dart';

class App extends StatelessWidget {
  const App({super.key});

  @override
  Widget build(BuildContext context) {
    final app = MaterialApp.router(
      debugShowCheckedModeBanner: FlavorConfig.instance.isDev,
      theme: ChameleonTheme.light,
      // No explicit themeMode: MaterialApp's own default is already
      // ThemeMode.system — `dart fix --apply` (part of `chameleon
      // create`'s own pipeline) strips it as a redundant argument every
      // time regardless, so writing it here just churns.
      darkTheme: ChameleonTheme.dark,
      routerConfig: {{#use_go_router}}appRouter{{/use_go_router}}{{^use_go_router}}appRouter.config(){{/use_go_router}},
      // ChameleonToastHost's Overlay (and FlavorBanner) need a
      // Directionality ancestor, which MaterialApp itself provides — they
      // must be built *inside* this builder, not wrapped around
      // MaterialApp.router.
      builder: (context, child) {
        final banded = FlavorBanner(
          shown: FlavorConfig.instance.isNotProd,
          label: FlavorConfig.instance.name,
          color: Color(FlavorConfig.instance.bannerColor),
          location: FlavorConfig.instance.isDev
              ? BannerLocation.bottomStart
              : BannerLocation.bottomEnd,
          child: child ?? const SizedBox.shrink(),
        );

        return DismissKeyboard(
          child: ChameleonToastHost(child: banded),
        );
      },
    );

    {{#is_bloc}}
    return MultiBlocProvider(
      providers: [
        BlocProvider.value(value: getIt<ConnectivityBloc>()),
      ],
      child: app,
    );
    {{/is_bloc}}
    {{#is_provider}}
    return MultiProvider(
      providers: [
        StreamProvider<ConnectivityState>.value(
          value: getIt<ConnectivityBloc>().stream,
          initialData: getIt<ConnectivityBloc>().state,
        ),
      ],
      child: app,
    );
    {{/is_provider}}
    {{#is_riverpod}}
    // ProviderScope already wraps everything above this (see
    // bootstrap.dart) — nothing extra needed here. Reach for
    // connectivityProvider (core/providers/connectivity_provider.dart)
    // via ref.watch wherever a feature needs it.
    return app;
    {{/is_riverpod}}
  }
}
