import 'package:flutter/material.dart';

import '../models/catalog_app.dart';
import '../state/app_controller.dart';
import 'app_detail_screen.dart';
import 'browse_screen.dart';
import 'discover_screen.dart';
import 'saved_screen.dart';
import 'settings_screen.dart';

enum _ShellSection {
  discover('Discover', 'AI-guided app search'),
  browse('Browse', 'Catalog and filters'),
  saved('Saved', 'Shortlisted apps'),
  settings('Settings', 'Gateway and session');

  const _ShellSection(this.label, this.subtitle);

  final String label;
  final String subtitle;
}

class ShellScreen extends StatefulWidget {
  const ShellScreen({super.key, required this.controller});

  final AppController controller;

  @override
  State<ShellScreen> createState() => _ShellScreenState();
}

class _ShellScreenState extends State<ShellScreen> {
  _ShellSection _section = _ShellSection.discover;

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
                _section = _ShellSection.discover;
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
        final screens = <_ShellSection, Widget>{
          _ShellSection.discover: DiscoverScreen(controller: widget.controller, onOpenApp: _openApp),
          _ShellSection.browse: BrowseScreen(controller: widget.controller, onOpenApp: _openApp),
          _ShellSection.saved: SavedScreen(controller: widget.controller, onOpenApp: _openApp),
          _ShellSection.settings: SettingsScreen(controller: widget.controller),
        };

        return Scaffold(
          appBar: AppBar(
            leading: Builder(
              builder: (BuildContext context) {
                return IconButton(
                  onPressed: () => Scaffold.of(context).openDrawer(),
                  icon: const Icon(Icons.menu_rounded),
                );
              },
            ),
            titleSpacing: 0,
            title: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: <Widget>[
                Text(
                  _section.label,
                  style: Theme.of(context).textTheme.titleLarge,
                ),
                Text(
                  _section.subtitle,
                  style: Theme.of(context).textTheme.bodyMedium,
                ),
              ],
            ),
          ),
          drawer: Drawer(
            child: SafeArea(
              child: Padding(
                padding: const EdgeInsets.fromLTRB(12, 12, 12, 20),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: <Widget>[
                    Padding(
                      padding: const EdgeInsets.fromLTRB(12, 8, 12, 20),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: <Widget>[
                          Text(
                            'HEDGE ExpertAI',
                            style: Theme.of(context).textTheme.headlineMedium?.copyWith(fontSize: 24),
                          ),
                          const SizedBox(height: 6),
                          Text(
                            'Mobile workspace for AI-assisted app discovery.',
                            style: Theme.of(context).textTheme.bodyMedium,
                          ),
                        ],
                      ),
                    ),
                    ..._ShellSection.values.map(
                      (_ShellSection item) => Padding(
                        padding: const EdgeInsets.only(bottom: 4),
                        child: ListTile(
                          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(18)),
                          selected: item == _section,
                          selectedTileColor: Theme.of(context).colorScheme.primary.withValues(alpha: 0.12),
                          leading: Icon(_iconForSection(item)),
                          title: Text(item.label),
                          subtitle: Text(item.subtitle),
                          onTap: () {
                            Navigator.of(context).pop();
                            setState(() {
                              _section = item;
                            });
                          },
                        ),
                      ),
                    ),
                    const Spacer(),
                    Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 12),
                      child: Text(
                        'Gateway: ${widget.controller.apiBaseUrl}',
                        style: Theme.of(context).textTheme.bodyMedium,
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
          body: widget.controller.isBootstrapping
              ? const Center(child: CircularProgressIndicator())
              : IndexedStack(
                  index: _ShellSection.values.indexOf(_section),
                  children: _ShellSection.values.map((item) => screens[item]!).toList(),
                ),
        );
      },
    );
  }

  IconData _iconForSection(_ShellSection section) {
    return switch (section) {
      _ShellSection.discover => Icons.chat_bubble_outline_rounded,
      _ShellSection.browse => Icons.travel_explore_rounded,
      _ShellSection.saved => Icons.bookmark_outline_rounded,
      _ShellSection.settings => Icons.tune_rounded,
    };
  }
}