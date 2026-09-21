import 'package:chameleon_core/chameleon_core.dart';
import 'package:chameleon_ui/chameleon_ui.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../core/di/injection_container.dart';
import '../../core/router/app_router.dart';

class App extends StatelessWidget {
  const App({super.key});

  @override
  Widget build(BuildContext context) {
    return MultiBlocProvider(
      providers: [
        BlocProvider.value(value: getIt<ConnectivityBloc>()),
      ],
      child: MaterialApp.router(
        debugShowCheckedModeBanner: FlavorConfig.instance.isDev,
        theme: ChameleonTheme.light,
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
      ),
    );
  }
}
