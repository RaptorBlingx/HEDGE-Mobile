import 'package:flutter/material.dart';

import '../state/app_controller.dart';

class SettingsScreen extends StatefulWidget {
  const SettingsScreen({super.key, required this.controller});

  final AppController controller;

  @override
  State<SettingsScreen> createState() => _SettingsScreenState();
}

class _SettingsScreenState extends State<SettingsScreen> {
  late final TextEditingController _baseUrlController;

  @override
  void initState() {
    super.initState();
    _baseUrlController = TextEditingController(text: widget.controller.apiBaseUrl);
  }

  @override
  void didUpdateWidget(covariant SettingsScreen oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.controller.apiBaseUrl != widget.controller.apiBaseUrl &&
        _baseUrlController.text != widget.controller.apiBaseUrl) {
      _baseUrlController.text = widget.controller.apiBaseUrl;
    }
  }

  @override
  void dispose() {
    _baseUrlController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final controller = widget.controller;
    return SafeArea(
      child: ListView(
        padding: const EdgeInsets.fromLTRB(16, 12, 16, 24),
        children: <Widget>[
          Text(
            'Point the app at a HEDGE gateway and reset the demo state when needed.',
            style: Theme.of(context).textTheme.bodyLarge?.copyWith(fontWeight: FontWeight.w500),
          ),
          const SizedBox(height: 24),
          TextField(
            controller: _baseUrlController,
            keyboardType: TextInputType.url,
            decoration: const InputDecoration(
              labelText: 'Gateway base URL',
              hintText: 'http://10.0.2.2:8080',
            ),
          ),
          const SizedBox(height: 12),
          FilledButton.icon(
            onPressed: () => controller.updateBaseUrl(_baseUrlController.text),
            icon: const Icon(Icons.cloud_done_rounded),
            label: const Text('Apply gateway URL'),
          ),
          const SizedBox(height: 24),
          _MetricTile(label: 'Current session', value: controller.sessionId ?? 'No active session'),
          _MetricTile(label: 'Catalog entries loaded', value: controller.catalog.length.toString()),
          _MetricTile(label: 'Saved apps', value: controller.savedApps.length.toString()),
          const SizedBox(height: 24),
          OutlinedButton.icon(
            onPressed: controller.loadCatalog,
            icon: const Icon(Icons.refresh_rounded),
            label: const Text('Refresh catalog'),
          ),
          const SizedBox(height: 12),
          OutlinedButton.icon(
            onPressed: controller.clearConversation,
            icon: const Icon(Icons.auto_delete_rounded),
            label: const Text('Clear conversation'),
          ),
        ],
      ),
    );
  }
}

class _MetricTile extends StatelessWidget {
  const _MetricTile({required this.label, required this.value});

  final String label;
  final String value;

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(20),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: <Widget>[
          Text(label, style: Theme.of(context).textTheme.bodyMedium),
          const SizedBox(height: 6),
          Text(value, style: Theme.of(context).textTheme.titleMedium),
        ],
      ),
    );
  }
}
