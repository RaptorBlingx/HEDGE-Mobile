import 'package:flutter/material.dart';

import '../config/app_config.dart';
import '../models/catalog_app.dart';
import '../models/chat_models.dart';
import '../models/recommended_app.dart';
import '../state/app_controller.dart';
import '../widgets/app_summary_card.dart';

class DiscoverScreen extends StatefulWidget {
  const DiscoverScreen({
    super.key,
    required this.controller,
    required this.onOpenApp,
  });

  final AppController controller;
  final ValueChanged<CatalogApp> onOpenApp;

  @override
  State<DiscoverScreen> createState() => _DiscoverScreenState();
}

class _DiscoverScreenState extends State<DiscoverScreen> {
  final TextEditingController _composerController = TextEditingController();

  @override
  void dispose() {
    _composerController.dispose();
    super.dispose();
  }

  Future<void> _submitMessage(String value) async {
    final trimmed = value.trim();
    if (trimmed.isEmpty) {
      return;
    }
    _composerController.clear();
    await widget.controller.sendMessage(trimmed);
  }

  @override
  Widget build(BuildContext context) {
    final controller = widget.controller;
    return SafeArea(
      child: Column(
        children: <Widget>[
          Container(
            width: double.infinity,
            margin: const EdgeInsets.fromLTRB(16, 12, 16, 12),
            padding: const EdgeInsets.all(20),
            decoration: BoxDecoration(
              gradient: const LinearGradient(
                colors: <Color>[Color(0xFF0F766E), Color(0xFF164E63)],
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
              ),
              borderRadius: BorderRadius.circular(28),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: <Widget>[
                Text(
                  'Discover with AI',
                  style: Theme.of(context).textTheme.headlineMedium?.copyWith(color: Colors.white),
                ),
                const SizedBox(height: 8),
                Text(
                  'Ask in plain language and compare the best-fitting HEDGE apps.',
                  style: Theme.of(context).textTheme.bodyLarge?.copyWith(color: const Color(0xFFD8F3EF)),
                ),
                const SizedBox(height: 16),
                Wrap(
                  spacing: 10,
                  runSpacing: 10,
                  children: AppConfig.suggestedPrompts
                      .map(
                        (String prompt) => ActionChip(
                          label: Text(prompt),
                          onPressed: () => _submitMessage(prompt),
                        ),
                      )
                      .toList(),
                ),
              ],
            ),
          ),
          Expanded(
            child: ListView.separated(
              padding: const EdgeInsets.fromLTRB(16, 0, 16, 16),
              itemCount: controller.conversation.length + (controller.isChatLoading ? 1 : 0),
              separatorBuilder: (_, __) => const SizedBox(height: 14),
              itemBuilder: (BuildContext context, int index) {
                if (index >= controller.conversation.length) {
                  return _PendingAssistantCard(errorText: controller.chatError);
                }

                final item = controller.conversation[index];
                return _ConversationCard(
                  message: item,
                  isSaved: controller.isSaved,
                  onOpenApp: widget.onOpenApp,
                  onToggleSaved: controller.toggleSaved,
                  onFeedback: controller.submitFeedback,
                );
              },
            ),
          ),
          Padding(
            padding: const EdgeInsets.fromLTRB(16, 4, 16, 16),
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.end,
              children: <Widget>[
                Expanded(
                  child: TextField(
                    controller: _composerController,
                    minLines: 1,
                    maxLines: 4,
                    textInputAction: TextInputAction.send,
                    onSubmitted: _submitMessage,
                    decoration: const InputDecoration(
                      hintText: 'Describe what you need...',
                    ),
                  ),
                ),
                const SizedBox(width: 12),
                FilledButton(
                  onPressed: controller.isChatLoading ? null : () => _submitMessage(_composerController.text),
                  child: const Icon(Icons.send_rounded),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class _ConversationCard extends StatelessWidget {
  const _ConversationCard({
    required this.message,
    required this.isSaved,
    required this.onOpenApp,
    required this.onToggleSaved,
    required this.onFeedback,
  });

  final ConversationMessage message;
  final bool Function(String appId) isSaved;
  final ValueChanged<CatalogApp> onOpenApp;
  final Future<void> Function(CatalogApp app) onToggleSaved;
  final Future<void> Function(String appId, String action) onFeedback;

  @override
  Widget build(BuildContext context) {
    final isUser = message.author == MessageAuthor.user;
    final bubbleColor = isUser
        ? const Color(0xFF132238)
        : message.isError
            ? const Color(0xFFFCE2E2)
            : Colors.white;
    final textColor = isUser
        ? Colors.white
        : message.isError
            ? const Color(0xFF9F1239)
            : const Color(0xFF132238);

    return Column(
      crossAxisAlignment: isUser ? CrossAxisAlignment.end : CrossAxisAlignment.start,
      children: <Widget>[
        Container(
          constraints: const BoxConstraints(maxWidth: 520),
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            color: bubbleColor,
            borderRadius: BorderRadius.circular(24),
          ),
          child: Text(
            message.text,
            style: Theme.of(context).textTheme.bodyLarge?.copyWith(color: textColor),
          ),
        ),
        if (message.apps.isNotEmpty) ...<Widget>[
          const SizedBox(height: 12),
          ...message.apps.map(
            (RecommendedApp app) => Padding(
              padding: const EdgeInsets.only(bottom: 12),
              child: AppSummaryCard(
                app: app.app,
                saved: isSaved(app.app.id),
                score: app.score,
                onTap: () => onOpenApp(app.app),
                onToggleSaved: () => onToggleSaved(app.app),
                footer: Row(
                  children: <Widget>[
                    TextButton.icon(
                      onPressed: () => onFeedback(app.app.id, 'accept'),
                      icon: const Icon(Icons.thumb_up_alt_outlined),
                      label: const Text('Helpful'),
                    ),
                    TextButton.icon(
                      onPressed: () => onFeedback(app.app.id, 'dismiss'),
                      icon: const Icon(Icons.thumb_down_alt_outlined),
                      label: const Text('Not now'),
                    ),
                  ],
                ),
              ),
            ),
          ),
        ],
      ],
    );
  }
}

class _PendingAssistantCard extends StatelessWidget {
  const _PendingAssistantCard({this.errorText});

  final String? errorText;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(24),
      ),
      child: Row(
        children: <Widget>[
          const SizedBox(
            width: 24,
            height: 24,
            child: CircularProgressIndicator(strokeWidth: 2.4),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Text(
              errorText == null
                  ? 'Scanning the HEDGE catalog and drafting a shortlist...'
                  : 'Last response failed. The assistant is ready when the gateway is reachable again.',
              style: Theme.of(context).textTheme.bodyLarge,
            ),
          ),
        ],
      ),
    );
  }
}
