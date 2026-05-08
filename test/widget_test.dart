import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

import 'package:hedge_expert_mobile/src/theme/app_theme.dart';

void main() {
  test('buildAppTheme enables Material 3', () {
    final theme = buildAppTheme();

    expect(theme.useMaterial3, isTrue);
    expect(theme.colorScheme.primary.toARGB32(), equals(const Color(0xFF10A37F).toARGB32()));
  });
}
