import 'package:flutter/material.dart';

import '../models/catalog_app.dart';
import '../state/app_controller.dart';
import 'app_detail_screen.dart';
import 'browse_screen.dart';
import 'discover_screen.dart';
import 'saved_screen.dart';
import 'settings_screen.dart';

class ShellScreen extends StatefulWidget {
  const ShellScreen({super.key, required this.controller});

  final AppController controller;

  @override
  State<ShellScreen> createState() => _ShellScreenState();
}

class _ShellScreenState extends State<ShellScreen> {
  int _index = 0;

  Future<void> _openApp(CatalogApp app) async {
    await Navigator.of(context).push(
      MaterialPageRoute<void>(
        builder: (BuildContext context) => AppDetailScreen(
          app: app,
          saved: widget.controller.isSaved(app.id),
          onToggleSaved: () => widget.controller.toggleSaved(app),
          onAskAboutApp: () async {
            if (mounted) {
              setState(() {
                _index = 0;
              });
            }
            await widget.controller.askAboutApp(app);
          },
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: widget.controller,
      builder: (BuildContext context, Widget? child) {
        final screens = <Widget>[
          DiscoverScreen(controller: widget.controller, onOpenApp: _openApp),
          BrowseScreen(controller: widget.controller, onOpenApp: _openApp),
          SavedScreen(controller: widget.controller, onOpenApp: _openApp),
          SettingsScreen(controller: widget.controller),
        ];

        return Scaffold(
          body: widget.controller.isBootstrapping
              ? const Center(child: CircularProgressIndicator())
              : IndexedStack(index: _index, children: screens),
          bottomNavigationBar: NavigationBar(
            selectedIndex: _index,
            onDestinationSelected: (int value) {
              setState(() {
                _index = value;
              });
            },
            destinations: const <NavigationDestination>[
              NavigationDestination(
                icon: Icon(Icons.auto_awesome_rounded),
                label: 'Discover',
              ),
              NavigationDestination(
                icon: Icon(Icons.grid_view_rounded),
                label: 'Browse',
              ),
              NavigationDestination(
                icon: Icon(Icons.bookmark_rounded),
                label: 'Saved',
              ),
              NavigationDestination(
                icon: Icon(Icons.tune_rounded),
                label: 'Settings',
              ),
            ],
          ),
        );
      },
    );
  }
}