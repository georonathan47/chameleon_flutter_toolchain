import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../../../core/di/injection_container.dart';
import '../bloc/{{feature_name.snakeCase()}}_bloc.dart';
import '../bloc/{{feature_name.snakeCase()}}_event.dart';
import '../bloc/{{feature_name.snakeCase()}}_state.dart';

class {{feature_name.pascalCase()}}Page extends StatelessWidget {
  const {{feature_name.pascalCase()}}Page({super.key});

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (_) =>
          getIt<{{feature_name.pascalCase()}}Bloc>()
            ..add(const {{feature_name.pascalCase()}}Requested()),
      child: const _{{feature_name.pascalCase()}}View(),
    );
  }
}

class _{{feature_name.pascalCase()}}View extends StatelessWidget {
  const _{{feature_name.pascalCase()}}View();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('{{feature_name.pascalCase()}}')),
      body: BlocBuilder<{{feature_name.pascalCase()}}Bloc, {{feature_name.pascalCase()}}State>(
        builder: (context, state) => switch (state) {
          {{feature_name.pascalCase()}}Initial() ||
          {{feature_name.pascalCase()}}Loading() => const Center(
            child: CircularProgressIndicator(),
          ),
          {{feature_name.pascalCase()}}Loaded(:final items) => ListView.builder(
            itemCount: items.length,
            itemBuilder: (context, index) =>
                ListTile(title: Text(items[index].name)),
          ),
          {{feature_name.pascalCase()}}LoadError(:final failure) => Center(
            child: Text(failure.message),
          ),
        },
      ),
    );
  }
}
