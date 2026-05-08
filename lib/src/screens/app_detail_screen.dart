import 'package:flutter/material.dart';

import '../models/catalog_app.dart';
import '../widgets/saref_tag.dart';

class AppDetailScreen extends StatelessWidget {
  const AppDetailScreen({
    super.key,
    required this.app,
    required this.saved,
    required this.onToggleSaved,
    required this.onAskAboutApp,
  });

  final CatalogApp app;
  final bool saved;
  final Future<void> Function() onToggleSaved;
  final Future<void> Function() onAskAboutApp;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('App details'),
      ),
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.fromLTRB(20, 8, 20, 32),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: <Widget>[
              Text(app.title, style: Theme.of(context).textTheme.headlineMedium),
              const SizedBox(height: 10),
              Wrap(
                spacing: 10,
                runSpacing: 10,
                children: <Widget>[
                  SarefTag(label: app.sarefType),
                  _MetaPill(label: app.id),
                  _MetaPill(label: 'v${app.version}'),
                ],
              ),
              const SizedBox(height: 20),
              Text(app.description, style: Theme.of(context).textTheme.bodyLarge),
              const SizedBox(height: 24),
              _Section(
                title: 'Publisher',
                child: Text(app.publisher, style: Theme.of(context).textTheme.bodyLarge),
              ),
              _Section(
                title: 'Tags',
                child: app.tags.isEmpty
                    ? const Text('No tags published for this app.')
                    : Wrap(
                        spacing: 8,
                        runSpacing: 8,
                        children: app.tags.map((String tag) => _MetaPill(label: tag)).toList(),
                      ),
              ),
              _Section(
                title: 'Input datasets',
                child: _DatasetList(items: app.inputDatasets, emptyLabel: 'No input datasets published.'),
              ),
              _Section(
                title: 'Output datasets',
                child: _DatasetList(items: app.outputDatasets, emptyLabel: 'No output datasets published.'),
              ),
              const SizedBox(height: 28),
              Row(
                children: <Widget>[
                  Expanded(
                    child: OutlinedButton.icon(
                      onPressed: onToggleSaved,
                      icon: Icon(saved ? Icons.bookmark_remove_rounded : Icons.bookmark_add_rounded),
                      label: Text(saved ? 'Remove saved' : 'Save app'),
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: FilledButton.icon(
                      onPressed: () async {
                        Navigator.of(context).pop();
                        await onAskAboutApp();
                      },
                      icon: const Icon(Icons.auto_awesome),
                      label: const Text('Ask AI'),
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _Section extends StatelessWidget {
  const _Section({required this.title, required this.child});

  final String title;
  final Widget child;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 20),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: <Widget>[
          Text(title, style: Theme.of(context).textTheme.titleMedium),
          const SizedBox(height: 10),
          child,
        ],
      ),
    );
  }
}

class _MetaPill extends StatelessWidget {
  const _MetaPill({required this.label});

  final String label;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(999),
      ),
      child: Text(label, style: Theme.of(context).textTheme.bodyMedium),
    );
  }
}

class _DatasetList extends StatelessWidget {
  const _DatasetList({required this.items, required this.emptyLabel});

  final List<String> items;
  final String emptyLabel;

  @override
  Widget build(BuildContext context) {
    if (items.isEmpty) {
      return Text(emptyLabel, style: Theme.of(context).textTheme.bodyMedium);
    }
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: items
          .map(
            (String item) => Padding(
              padding: const EdgeInsets.only(bottom: 8),
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: <Widget>[
                  const Padding(
                    padding: EdgeInsets.only(top: 4),
                    child: Icon(Icons.circle, size: 8),
                  ),
                  const SizedBox(width: 8),
                  Expanded(
                    child: Text(item, style: Theme.of(context).textTheme.bodyLarge),
                  ),
                ],
              ),
            ),
          )
          .toList(),
    );
  }
}
