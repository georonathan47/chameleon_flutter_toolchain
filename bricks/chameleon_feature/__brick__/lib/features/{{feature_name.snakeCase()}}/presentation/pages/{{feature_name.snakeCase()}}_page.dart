import 'package:flutter/material.dart';
{{#is_bloc}}
import 'package:flutter_bloc/flutter_bloc.dart';
{{/is_bloc}}
{{#is_provider}}
import 'package:provider/provider.dart';
{{/is_provider}}
{{#is_riverpod}}
import 'package:flutter_riverpod/flutter_riverpod.dart';
{{/is_riverpod}}

{{^is_riverpod}}
import '../../../../core/di/injection_container.dart';
{{/is_riverpod}}
{{#is_bloc}}
import '../state/{{feature_name.snakeCase()}}_bloc.dart';
import '../state/{{feature_name.snakeCase()}}_event.dart';
import '../state/{{feature_name.snakeCase()}}_state.dart';
{{/is_bloc}}
{{#is_provider}}
import '../state/{{feature_name.snakeCase()}}_controller.dart';
import '../state/{{feature_name.snakeCase()}}_state.dart';
{{/is_provider}}
{{#is_riverpod}}
import '../state/{{feature_name.snakeCase()}}_provider.dart';
{{/is_riverpod}}

class {{feature_name.pascalCase()}}Page extends {{^is_riverpod}}StatelessWidget{{/is_riverpod}}{{#is_riverpod}}ConsumerWidget{{/is_riverpod}} {
  const {{feature_name.pascalCase()}}Page({super.key});

  @override
  Widget build(BuildContext context{{#is_riverpod}}, WidgetRef ref{{/is_riverpod}}) {
    {{#is_bloc}}
    return BlocProvider(
      create: (_) =>
          getIt<{{feature_name.pascalCase()}}Bloc>()
            ..add(const {{feature_name.pascalCase()}}Requested()),
      child: const _{{feature_name.pascalCase()}}View(),
    );
    {{/is_bloc}}
    {{#is_provider}}
    return ChangeNotifierProvider(
      create: (_) => getIt<{{feature_name.pascalCase()}}Controller>()..load(),
      child: const _{{feature_name.pascalCase()}}View(),
    );
    {{/is_provider}}
    {{#is_riverpod}}
    final asyncItems = ref.watch({{feature_name.camelCase()}}Provider);
    return Scaffold(
      appBar: AppBar(title: const Text('{{feature_name.pascalCase()}}')),
      body: asyncItems.when(
        data: (items) => ListView.builder(
          itemCount: items.length,
          itemBuilder: (context, index) =>
              ListTile(title: Text(items[index].name)),
        ),
        loading: () => const Center(child: CircularProgressIndicator()),
        error: (error, stackTrace) => Center(
          child: Text(
            (error as {{feature_name.pascalCase()}}FailureException).failure.message,
          ),
        ),
      ),
    );
    {{/is_riverpod}}
  }
}

{{^is_riverpod}}
class _{{feature_name.pascalCase()}}View extends StatelessWidget {
  const _{{feature_name.pascalCase()}}View();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('{{feature_name.pascalCase()}}')),
      {{#is_bloc}}
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
      {{/is_bloc}}
      {{#is_provider}}
      body: switch (context.watch<{{feature_name.pascalCase()}}Controller>().state) {
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
      {{/is_provider}}
    );
  }
}
{{/is_riverpod}}
