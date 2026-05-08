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
    'I need an app for monitoring energy consumption',
    'Find me a smart building HVAC solution',
    'Precision irrigation for farming',
  ];

  static const String welcomeMessage =
      'Tell me what you want to achieve and I will narrow the HEDGE catalog to '
      'the apps that fit best.';
}
