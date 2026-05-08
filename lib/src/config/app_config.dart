import 'dart:io';

class AppConfig {
  static const String appName = 'HEDGE ExpertAI Mobile';
  static const String allCategoryLabel = 'All';

  static String get defaultBaseUrl {
    const override = String.fromEnvironment('HEDGE_API_BASE_URL', defaultValue: '');
    if (override.isNotEmpty) {
      return override;
    }

    if (Platform.isAndroid) {
      // Development builds use adb reverse so the phone can reach the host backend
      // without depending on LAN routing or trusting the self-signed HTTPS cert.
      return 'http://127.0.0.1:8080';
    }

    return 'http://localhost';
  }

  static const List<String> suggestedPrompts = <String>[
    'Monitor energy consumption across buildings',
    'Find HVAC optimization for smart buildings',
    'Recommend precision irrigation apps',
  ];

  static const String welcomeMessage =
      'Tell me the outcome you want, the domain, and any constraints. '
      'I will rank the strongest HEDGE apps and explain why they fit.';
}
