import 'package:flutter/material.dart';

import 'src/screens/shell_screen.dart';
import 'src/state/app_controller.dart';
import 'src/theme/app_theme.dart';

class HedgeExpertMobileApp extends StatefulWidget {
  const HedgeExpertMobileApp({super.key});

  @override
  State<HedgeExpertMobileApp> createState() => _HedgeExpertMobileAppState();
}

class _HedgeExpertMobileAppState extends State<HedgeExpertMobileApp> {
  late final AppController _controller;

  @override
  void initState() {
    super.initState();
    _controller = AppController()..bootstrap();
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      title: 'HEDGE ExpertAI Mobile',
      theme: buildAppTheme(),
      home: ShellScreen(controller: _controller),
    );
  }
}
