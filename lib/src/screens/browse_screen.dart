import 'package:flutter/material.dart';

import '../config/app_config.dart';
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
                Text(
                  'Search the catalog by title, publisher, tag, or app ID, then narrow it by domain.',
                  style: Theme.of(context).textTheme.bodyLarge?.copyWith(fontWeight: FontWeight.w500),
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
                return _CategoryFilterChip(
                  label: category,
                  selected: controller.selectedCategory == category,
                  onTap: () => controller.setSelectedCategory(category),
                );
              },
              separatorBuilder: (_, __) => const SizedBox(width: 8),
              itemCount: controller.categories.length,
            ),
          ),
          Padding(
            padding: const EdgeInsets.fromLTRB(16, 10, 16, 12),
            child: Row(
              children: <Widget>[
                Text(
                  '${controller.filteredCatalog.length} apps',
                  style: Theme.of(context).textTheme.bodyMedium?.copyWith(fontWeight: FontWeight.w700),
                ),
                const SizedBox(width: 8),
                if (controller.selectedCategory != AppConfig.allCategoryLabel)
                  Text(
                    'in ${controller.selectedCategory}',
                    style: Theme.of(context).textTheme.bodyMedium,
                  ),
              ],
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

class _CategoryFilterChip extends StatelessWidget {
  const _CategoryFilterChip({
    required this.label,
    required this.selected,
    required this.onTap,
  });

  final String label;
  final bool selected;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return Material(
      color: selected ? const Color(0xFF111827) : Colors.white,
      borderRadius: BorderRadius.circular(999),
      child: InkWell(
        borderRadius: BorderRadius.circular(999),
        onTap: onTap,
        child: Container(
          padding: const EdgeInsets.symmetric(horizontal: 18, vertical: 12),
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(999),
            border: Border.all(
              color: selected ? const Color(0xFF111827) : const Color(0xFFD1D5DB),
            ),
          ),
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: <Widget>[
              if (selected) ...<Widget>[
                const Icon(Icons.check_rounded, size: 16, color: Colors.white),
                const SizedBox(width: 8),
              ],
              Text(
                label,
                style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                      color: selected ? Colors.white : const Color(0xFF374151),
                      fontWeight: FontWeight.w700,
                    ),
              ),
            ],
          ),
        ),
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
