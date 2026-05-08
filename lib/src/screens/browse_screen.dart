import 'package:flutter/material.dart';

import '../models/catalog_app.dart';
import '../state/app_controller.dart';
import '../widgets/app_summary_card.dart';

class BrowseScreen extends StatelessWidget {
  const BrowseScreen({
    super.key,
    required this.controller,
    required this.onOpenApp,
  });

  final AppController controller;
  final ValueChanged<CatalogApp> onOpenApp;

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      child: Column(
        children: <Widget>[
          Padding(
            padding: const EdgeInsets.fromLTRB(16, 12, 16, 10),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: <Widget>[
                Text('Browse apps', style: Theme.of(context).textTheme.headlineMedium),
                const SizedBox(height: 8),
                Text(
                  'Filter the catalog by domain, then open an app or hand it back to the AI assistant.',
                  style: Theme.of(context).textTheme.bodyLarge,
                ),
                const SizedBox(height: 16),
                TextField(
                  onChanged: controller.setBrowseQuery,
                  decoration: const InputDecoration(
                    prefixIcon: Icon(Icons.search_rounded),
                    hintText: 'Search titles, tags, publishers, or app IDs',
                  ),
                ),
              ],
            ),
          ),
          SizedBox(
            height: 48,
            child: ListView.separated(
              padding: const EdgeInsets.symmetric(horizontal: 16),
              scrollDirection: Axis.horizontal,
              itemBuilder: (BuildContext context, int index) {
                final category = controller.categories[index];
                return ChoiceChip(
                  label: Text(category),
                  selected: controller.selectedCategory == category,
                  onSelected: (_) => controller.setSelectedCategory(category),
                );
              },
              separatorBuilder: (_, __) => const SizedBox(width: 8),
              itemCount: controller.categories.length,
            ),
          ),
          const SizedBox(height: 12),
          Expanded(
            child: Builder(
              builder: (BuildContext context) {
                if (controller.isCatalogLoading) {
                  return const Center(child: CircularProgressIndicator());
                }
                if (controller.catalogError != null) {
                  return _CatalogError(
                    message: controller.catalogError!,
                    onRetry: controller.loadCatalog,
                  );
                }
                if (controller.filteredCatalog.isEmpty) {
                  return const _CatalogEmpty();
                }

                return ListView.separated(
                  padding: const EdgeInsets.fromLTRB(16, 0, 16, 16),
                  itemBuilder: (BuildContext context, int index) {
                    final app = controller.filteredCatalog[index];
                    return AppSummaryCard(
                      app: app,
                      saved: controller.isSaved(app.id),
                      onTap: () => onOpenApp(app),
                      onToggleSaved: () => controller.toggleSaved(app),
                    );
                  },
                  separatorBuilder: (_, __) => const SizedBox(height: 12),
                  itemCount: controller.filteredCatalog.length,
                );
              },
            ),
          ),
        ],
      ),
    );
  }
}

class _CatalogError extends StatelessWidget {
  const _CatalogError({required this.message, required this.onRetry});

  final String message;
  final Future<void> Function() onRetry;

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(24),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: <Widget>[
            const Icon(Icons.wifi_off_rounded, size: 48),
            const SizedBox(height: 16),
            Text(message, textAlign: TextAlign.center, style: Theme.of(context).textTheme.bodyLarge),
            const SizedBox(height: 16),
            FilledButton.icon(
              onPressed: onRetry,
              icon: const Icon(Icons.refresh_rounded),
              label: const Text('Retry catalog'),
            ),
          ],
        ),
      ),
    );
  }
}

class _CatalogEmpty extends StatelessWidget {
  const _CatalogEmpty();

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(24),
        child: Text(
          'No apps match this filter yet. Clear the search or switch categories.',
          textAlign: TextAlign.center,
          style: Theme.of(context).textTheme.bodyLarge,
        ),
      ),
    );
  }
}
