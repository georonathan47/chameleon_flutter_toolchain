import 'package:chameleon_ui/chameleon_ui.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  test(
    'every ChameleonSemanticColors value resolves to a ChameleonColors '
    'primitive',
    () {
      // Guards against someone inlining a raw hex into ChameleonSemanticColors
      // instead of aliasing an existing primitive.
      //
      // Color overrides `==`, so it cannot be a const Set element — the
      // language requires const collection elements to use identity equality.
      final primitives = <Color>{
        ChameleonColors.white,
        ChameleonColors.black,
        ChameleonColors.yellow50,
        ChameleonColors.yellow100,
        ChameleonColors.yellow200,
        ChameleonColors.yellow300,
        ChameleonColors.yellow400,
        ChameleonColors.yellow500,
        ChameleonColors.yellow600,
        ChameleonColors.yellow700,
        ChameleonColors.yellow800,
        ChameleonColors.yellow900,
        ChameleonColors.yellow1000,
        ChameleonColors.orange500,
        ChameleonColors.orange900,
        ChameleonColors.orange200,
        // grey50 and grey100 share the same literal (0xFFF8F9FA) in the
        // token file, so only one needs to appear here as a set element.
        ChameleonColors.grey100,
        ChameleonColors.grey200,
        ChameleonColors.grey300,
        ChameleonColors.grey400,
        ChameleonColors.grey500,
        ChameleonColors.grey550,
        ChameleonColors.grey600,
        ChameleonColors.grey700,
        ChameleonColors.grey800,
        ChameleonColors.grey850Alpha20,
        ChameleonColors.grey860,
        ChameleonColors.grey900,
        ChameleonColors.red200,
        ChameleonColors.red600,
        ChameleonColors.red900,
        ChameleonColors.green300,
        ChameleonColors.green600,
        ChameleonColors.green900,
        ChameleonColors.blue200,
        ChameleonColors.blue600,
      };

      final semantics = <Color>[
        ChameleonSemanticColors.primary,
        ChameleonSemanticColors.primaryHover,
        ChameleonSemanticColors.onPrimary,
        ChameleonSemanticColors.primaryContainer,
        ChameleonSemanticColors.onPrimaryContainer,
        ChameleonSemanticColors.secondary,
        ChameleonSemanticColors.onSecondary,
        ChameleonSemanticColors.surface,
        ChameleonSemanticColors.surfaceBright,
        ChameleonSemanticColors.surfaceContainer,
        ChameleonSemanticColors.surfaceDim,
        ChameleonSemanticColors.scrim,
        ChameleonSemanticColors.surfaceInverse,
        ChameleonSemanticColors.textPrimary,
        ChameleonSemanticColors.textPrimaryInverse,
        ChameleonSemanticColors.textSecondary,
        ChameleonSemanticColors.textHelper,
        ChameleonSemanticColors.textDisabled,
        ChameleonSemanticColors.textStepIndicator,
        ChameleonSemanticColors.textLink,
        ChameleonSemanticColors.textBrandBold,
        ChameleonSemanticColors.outline,
        ChameleonSemanticColors.outlineVariant,
        ChameleonSemanticColors.success,
        ChameleonSemanticColors.onSuccessContainer,
        ChameleonSemanticColors.successContainer,
        ChameleonSemanticColors.error,
        ChameleonSemanticColors.onErrorContainer,
        ChameleonSemanticColors.errorContainer,
        ChameleonSemanticColors.warning,
        ChameleonSemanticColors.onWarningContainer,
        ChameleonSemanticColors.warningContainer,
        ChameleonSemanticColors.info,
        ChameleonSemanticColors.infoContainer,
        ChameleonSemanticColors.amountPositive,
        ChameleonSemanticColors.amountNegative,
        ChameleonSemanticColors.inputBorderDefault,
        ChameleonSemanticColors.inputBorderFocus,
        ChameleonSemanticColors.inputContainer,
        ChameleonSemanticColors.inputLabel,
        ChameleonSemanticColors.navBarIconActive,
        ChameleonSemanticColors.navBarIconInactive,
        ChameleonSemanticColors.navBarContainer,
        ChameleonSemanticColors.tabIndicatorActive,
        ChameleonSemanticColors.iconDefault,
        ChameleonSemanticColors.iconAction,
        ChameleonSemanticColors.iconDisabled,
      ];

      for (final color in semantics) {
        expect(
          primitives.contains(color),
          isTrue,
          reason:
              '$color is not a known ChameleonColors primitive — a semantic '
              'alias must point at a token, not a raw hex value.',
        );
      }
    },
  );
}
