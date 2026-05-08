import 'package:flutter/material.dart';

import '../models/catalog_app.dart';
import '../state/app_controller.dart';
import '../widgets/app_summary_card.dart';

class SavedScreen extends StatelessWidget {
  const SavedScreen({
    super.key,
    required this.controller,
    required this.onOpenApp,
  });

  final AppController controller;
  final ValueChanged<CatalogApp> onOpenApp;

  @override
  Widget build(BuildContext context) {
    final apps = controller.savedApps;
    return SafeArea(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: <Widget>[
          Padding(
            padding: const EdgeInsets.fromLTRB(16, 12, 16, 16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: <Widget>[
                Text('Saved apps', style: Theme.of(context).textTheme.headlineMedium),
                const SizedBox(height: 8),
                Text(
                  'Keep a shortlist of promising apps while you compare recommendations.',
                  style: Theme.of(context).textTheme.bodyLarge,
                ),
              ],
            ),
          ),
          Expanded(
            child: apps.isEmpty
                ? const _SavedEmptyState()
                : ListView.separated(
                    padding: const EdgeInsets.fromLTRB(16, 0, 16, 16),
                    itemBuilder: (BuildContext context, int index) {
                      final app = apps[index];
                      return AppSummaryCard(
                        app: app,
                        saved: true,
                        onTap: () => onOpenApp(app),
                        onToggleSaved: () => controller.toggleSaved(app),
                      );
                    },
                    separatorBuilder: (_, __) => const SizedBox(height: 12),
                    itemCount: apps.length,
                  ),
          ),
        ],
      ),
    );
  }
}

class _SavedEmptyState extends StatelessWidget {
  const _SavedEmptyState();

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(24),
        child: Text(
          'Nothing saved yet. Bookmark an app from Browse or Discover to keep it here.',
          textAlign: TextAlign.center,
          style: Theme.of(context).textTheme.bodyLarge,
        ),
      ),
    );
  }
}
