/// Converts a snake_case name to PascalCase, for "next steps" messages that
/// name a generated class (e.g. `beneficiaries` -> `Beneficiaries`).
String pascalCase(String snakeCase) => snakeCase
    .split('_')
    .map(
      (part) => part.isEmpty ? part : part[0].toUpperCase() + part.substring(1),
    )
    .join();
