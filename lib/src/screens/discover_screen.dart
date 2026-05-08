import 'dart:async';
import 'dart:math' as math;

import 'package:flutter/material.dart';
import 'package:flutter_markdown/flutter_markdown.dart';

import '../config/app_config.dart';
import '../models/catalog_app.dart';
import '../models/chat_models.dart';
import '../models/recommended_app.dart';
import '../state/app_controller.dart';
import '../widgets/saref_tag.dart';

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
  final ScrollController _scrollController = ScrollController();
  int _lastMessageCount = 0;
  bool _lastLoadingState = false;

  @override
  void initState() {
    super.initState();
    _lastMessageCount = widget.controller.conversation.length;
    _lastLoadingState = widget.controller.isChatLoading;
    widget.controller.addListener(_handleControllerChanged);
  }

  @override
  void didUpdateWidget(covariant DiscoverScreen oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.controller != widget.controller) {
      oldWidget.controller.removeListener(_handleControllerChanged);
      _lastMessageCount = widget.controller.conversation.length;
      _lastLoadingState = widget.controller.isChatLoading;
      widget.controller.addListener(_handleControllerChanged);
    }
  }

  @override
  void dispose() {
    widget.controller.removeListener(_handleControllerChanged);
    _composerController.dispose();
    _scrollController.dispose();
    super.dispose();
  }

  void _handleControllerChanged() {
    final messageCount = widget.controller.conversation.length;
    final loadingState = widget.controller.isChatLoading;
    if (messageCount != _lastMessageCount || loadingState != _lastLoadingState) {
      _lastMessageCount = messageCount;
      _lastLoadingState = loadingState;
      WidgetsBinding.instance.addPostFrameCallback((_) => _scrollToBottom());
    }
  }

  void _scrollToBottom() {
    if (!_scrollController.hasClients) {
      return;
    }
    _scrollController.animateTo(
      _scrollController.position.maxScrollExtent,
      duration: const Duration(milliseconds: 260),
      curve: Curves.easeOutCubic,
    );
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
    final showPromptSuggestions =
        controller.conversation.where((ConversationMessage item) => item.author == MessageAuthor.user).isEmpty;

    return SafeArea(
      child: Column(
        children: <Widget>[
          if (showPromptSuggestions)
            Padding(
              padding: const EdgeInsets.fromLTRB(16, 12, 16, 12),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: <Widget>[
                  Text(
                    'Ask for the outcome you want. I will surface the strongest HEDGE matches.',
                    style: Theme.of(context).textTheme.bodyLarge?.copyWith(
                          fontWeight: FontWeight.w600,
                          color: const Color(0xFF111827),
                        ),
                  ),
                  const SizedBox(height: 12),
                  SizedBox(
                    height: 104,
                    child: ListView.separated(
                      scrollDirection: Axis.horizontal,
                      itemCount: AppConfig.suggestedPrompts.length,
                      separatorBuilder: (_, __) => const SizedBox(width: 12),
                      itemBuilder: (BuildContext context, int index) {
                        final prompt = AppConfig.suggestedPrompts[index];
                        return _PromptSuggestionCard(
                          prompt: prompt,
                          onTap: () => _submitMessage(prompt),
                        );
                      },
                    ),
                  ),
                ],
              ),
            ),
          Expanded(
            child: ListView.separated(
              controller: _scrollController,
              padding: const EdgeInsets.fromLTRB(16, 0, 16, 16),
              itemCount: controller.conversation.length + (controller.isChatLoading ? 1 : 0),
              separatorBuilder: (_, __) => const SizedBox(height: 14),
              itemBuilder: (BuildContext context, int index) {
                if (index >= controller.conversation.length) {
                  return _PendingAssistantCard(
                    startedAt: controller.activeRequestStartedAt,
                    errorText: controller.chatError,
                  );
                }

                final item = controller.conversation[index];
                return _ConversationCard(
                  key: ValueKey<String>(item.id),
                  message: item,
                  isSaved: controller.isSaved,
                  onOpenApp: widget.onOpenApp,
                  onToggleSaved: controller.toggleSaved,
                  onFeedback: controller.submitFeedback,
                  animateText: item.author == MessageAuthor.assistant &&
                      !item.isError &&
                      index == controller.conversation.length - 1,
                  onContentProgress: _scrollToBottom,
                );
              },
            ),
          ),
          Container(
            margin: const EdgeInsets.fromLTRB(12, 4, 12, 16),
            padding: const EdgeInsets.fromLTRB(14, 10, 10, 10),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(28),
              border: Border.all(color: const Color(0xFFE5E7EB)),
              boxShadow: const <BoxShadow>[
                BoxShadow(
                  color: Color(0x0F111827),
                  blurRadius: 20,
                  offset: Offset(0, 8),
                ),
              ],
            ),
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.end,
              children: <Widget>[
                Expanded(
                  child: TextField(
                    controller: _composerController,
                    minLines: 1,
                    maxLines: 6,
                    textInputAction: TextInputAction.send,
                    onSubmitted: _submitMessage,
                    decoration: const InputDecoration.collapsed(
                      hintText: 'Message HEDGE ExpertAI',
                    ),
                  ),
                ),
                const SizedBox(width: 10),
                FilledButton(
                  style: FilledButton.styleFrom(
                    padding: const EdgeInsets.all(16),
                    shape: const CircleBorder(),
                  ),
                  onPressed: controller.isChatLoading ? null : () => _submitMessage(_composerController.text),
                  child: const Icon(Icons.arrow_upward_rounded),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class _PromptSuggestionCard extends StatelessWidget {
  const _PromptSuggestionCard({required this.prompt, required this.onTap});

  final String prompt;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return InkWell(
      borderRadius: BorderRadius.circular(24),
      onTap: onTap,
      child: Ink(
        width: 240,
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(24),
          border: Border.all(color: const Color(0xFFE5E7EB)),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: <Widget>[
            Container(
              width: 34,
              height: 34,
              decoration: BoxDecoration(
                color: const Color(0xFFE7F7F1),
                borderRadius: BorderRadius.circular(12),
              ),
              child: const Icon(Icons.auto_awesome_rounded, color: Color(0xFF10A37F)),
            ),
            const Spacer(),
            Text(
              prompt,
              maxLines: 3,
              overflow: TextOverflow.ellipsis,
              style: Theme.of(context).textTheme.titleMedium,
            ),
          ],
        ),
      ),
    );
  }
}

class _ConversationCard extends StatefulWidget {
  const _ConversationCard({
    super.key,
    required this.message,
    required this.isSaved,
    required this.onOpenApp,
    required this.onToggleSaved,
    required this.onFeedback,
    required this.animateText,
    this.onContentProgress,
  });

  final ConversationMessage message;
  final bool Function(String appId) isSaved;
  final ValueChanged<CatalogApp> onOpenApp;
  final Future<void> Function(CatalogApp app) onToggleSaved;
  final Future<void> Function(String appId, String action) onFeedback;
  final bool animateText;
  final VoidCallback? onContentProgress;

  @override
  State<_ConversationCard> createState() => _ConversationCardState();
}

class _ConversationCardState extends State<_ConversationCard> {
  late bool _showRecommendations;

  @override
  void initState() {
    super.initState();
    _showRecommendations = !widget.animateText || widget.message.author == MessageAuthor.user || widget.message.isError;
  }

  @override
  void didUpdateWidget(covariant _ConversationCard oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.message.id != widget.message.id || oldWidget.animateText != widget.animateText) {
      _showRecommendations =
          !widget.animateText || widget.message.author == MessageAuthor.user || widget.message.isError;
    }
  }

  @override
  Widget build(BuildContext context) {
    final message = widget.message;
    final isUser = message.author == MessageAuthor.user;
    final bubbleColor = isUser
        ? const Color(0xFF111827)
        : message.isError
            ? const Color(0xFFFDECEC)
            : Colors.white;
    final textColor = isUser
        ? Colors.white
        : message.isError
            ? const Color(0xFF9F1239)
            : const Color(0xFF111827);

    return Column(
      crossAxisAlignment: isUser ? CrossAxisAlignment.end : CrossAxisAlignment.start,
      children: <Widget>[
        if (!isUser)
          Padding(
            padding: const EdgeInsets.only(bottom: 8),
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: <Widget>[
                Container(
                  width: 28,
                  height: 28,
                  decoration: BoxDecoration(
                    color: const Color(0xFFE7F7F1),
                    borderRadius: BorderRadius.circular(10),
                  ),
                  child: const Icon(Icons.auto_awesome_rounded, size: 16, color: Color(0xFF10A37F)),
                ),
                const SizedBox(width: 8),
                Text(
                  'HEDGE ExpertAI',
                  style: Theme.of(context).textTheme.titleMedium?.copyWith(fontSize: 15),
                ),
                if (message.responseTime != null) ...<Widget>[
                  const SizedBox(width: 8),
                  _ResponseTimeBadge(duration: message.responseTime!),
                ],
              ],
            ),
          ),
        Container(
          constraints: const BoxConstraints(maxWidth: 640),
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            color: bubbleColor,
            borderRadius: BorderRadius.circular(isUser ? 24 : 26),
            border: isUser || message.isError
                ? null
                : Border.all(color: const Color(0xFFE5E7EB)),
            boxShadow: isUser
                ? null
                : const <BoxShadow>[
                    BoxShadow(
                      color: Color(0x08111827),
                      blurRadius: 16,
                      offset: Offset(0, 8),
                    ),
                  ],
          ),
          child: message.author == MessageAuthor.assistant && !message.isError
              ? _AnimatedMarkdownMessage(
                  text: message.text,
                  animate: widget.animateText,
                  textColor: textColor,
                  onCompleted: () {
                    if (!_showRecommendations && mounted) {
                      setState(() {
                        _showRecommendations = true;
                      });
                    }
                  },
                  onProgress: widget.onContentProgress,
                )
              : Text(
                  message.text,
                  style: Theme.of(context).textTheme.bodyLarge?.copyWith(color: textColor),
                ),
        ),
        if (_showRecommendations && message.apps.isNotEmpty) ...<Widget>[
          const SizedBox(height: 12),
          _RecommendationCluster(
            apps: message.apps,
            isSaved: widget.isSaved,
            onOpenApp: widget.onOpenApp,
            onToggleSaved: widget.onToggleSaved,
            onFeedback: widget.onFeedback,
          ),
        ],
      ],
    );
  }
}

class _AnimatedMarkdownMessage extends StatefulWidget {
  const _AnimatedMarkdownMessage({
    required this.text,
    required this.animate,
    required this.textColor,
    this.onCompleted,
    this.onProgress,
  });

  final String text;
  final bool animate;
  final Color textColor;
  final VoidCallback? onCompleted;
  final VoidCallback? onProgress;

  @override
  State<_AnimatedMarkdownMessage> createState() => _AnimatedMarkdownMessageState();
}

class _AnimatedMarkdownMessageState extends State<_AnimatedMarkdownMessage> {
  Timer? _timer;
  List<String> _segments = <String>[];
  int _visibleSegments = 0;

  @override
  void initState() {
    super.initState();
    _configureAnimation();
  }

  @override
  void didUpdateWidget(covariant _AnimatedMarkdownMessage oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.text != widget.text || oldWidget.animate != widget.animate) {
      _configureAnimation();
    }
  }

  @override
  void dispose() {
    _timer?.cancel();
    super.dispose();
  }

  void _configureAnimation() {
    _timer?.cancel();
    _segments = RegExp(r'\S+\s*').allMatches(widget.text).map((Match match) => match.group(0)!).toList();
    if (_segments.isEmpty && widget.text.isNotEmpty) {
      _segments = <String>[widget.text];
    }

    if (!widget.animate || _segments.isEmpty) {
      _visibleSegments = _segments.length;
      WidgetsBinding.instance.addPostFrameCallback((_) => widget.onCompleted?.call());
      return;
    }

    final step = math.max(1, (_segments.length / 42).ceil());
    _visibleSegments = 0;
    _timer = Timer.periodic(
      Duration(milliseconds: _segments.length > 80 ? 24 : 34),
      (Timer timer) {
        if (!mounted) {
          timer.cancel();
          return;
        }
        setState(() {
          _visibleSegments = math.min(_segments.length, _visibleSegments + step);
        });
        widget.onProgress?.call();
        if (_visibleSegments >= _segments.length) {
          timer.cancel();
          widget.onCompleted?.call();
        }
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final styleSheet = MarkdownStyleSheet.fromTheme(theme).copyWith(
      p: theme.textTheme.bodyLarge?.copyWith(color: widget.textColor),
      strong: theme.textTheme.bodyLarge?.copyWith(
        color: widget.textColor,
        fontWeight: FontWeight.w800,
      ),
      listBullet: theme.textTheme.bodyLarge?.copyWith(color: widget.textColor),
      blockSpacing: 10,
    );

    return SelectionArea(
      child: MarkdownBody(
        data: _segments.take(_visibleSegments).join(),
        styleSheet: styleSheet,
      ),
    );
  }
}

class _RecommendationCluster extends StatelessWidget {
  const _RecommendationCluster({
    required this.apps,
    required this.isSaved,
    required this.onOpenApp,
    required this.onToggleSaved,
    required this.onFeedback,
  });

  final List<RecommendedApp> apps;
  final bool Function(String appId) isSaved;
  final ValueChanged<CatalogApp> onOpenApp;
  final Future<void> Function(CatalogApp app) onToggleSaved;
  final Future<void> Function(String appId, String action) onFeedback;

  @override
  Widget build(BuildContext context) {
    final topMatch = apps.first;
    final additionalMatches = apps.skip(1).take(3).toList();
    final hiddenCount = math.max(0, apps.length - 1 - additionalMatches.length);

    return Container(
      constraints: const BoxConstraints(maxWidth: 640),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: const Color(0xFFF9FAFB),
        borderRadius: BorderRadius.circular(24),
        border: Border.all(color: const Color(0xFFE5E7EB)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: <Widget>[
          Row(
            children: <Widget>[
              Text('Top matches', style: Theme.of(context).textTheme.titleMedium),
              const Spacer(),
              Text(
                '${apps.length} relevant ${apps.length == 1 ? 'app' : 'apps'}',
                style: Theme.of(context).textTheme.bodyMedium,
              ),
            ],
          ),
          const SizedBox(height: 12),
          _TopRecommendationCard(
            recommendation: topMatch,
            saved: isSaved(topMatch.app.id),
            onOpenApp: () => onOpenApp(topMatch.app),
            onToggleSaved: () => onToggleSaved(topMatch.app),
            onHelpful: () => onFeedback(topMatch.app.id, 'accept'),
            onDismiss: () => onFeedback(topMatch.app.id, 'dismiss'),
          ),
          if (additionalMatches.isNotEmpty) ...<Widget>[
            const SizedBox(height: 14),
            Text(
              'More relevant apps',
              style: Theme.of(context).textTheme.titleMedium?.copyWith(fontSize: 15),
            ),
            const SizedBox(height: 8),
            ...additionalMatches.map(
              (RecommendedApp recommendation) => Padding(
                padding: const EdgeInsets.only(bottom: 10),
                child: _CompactRecommendationTile(
                  recommendation: recommendation,
                  saved: isSaved(recommendation.app.id),
                  onOpenApp: () => onOpenApp(recommendation.app),
                  onToggleSaved: () => onToggleSaved(recommendation.app),
                ),
              ),
            ),
          ],
          if (hiddenCount > 0)
            Padding(
              padding: const EdgeInsets.only(top: 2),
              child: Text(
                '+ $hiddenCount more available in Browse.',
                style: Theme.of(context).textTheme.bodyMedium,
              ),
            ),
        ],
      ),
    );
  }
}

class _TopRecommendationCard extends StatelessWidget {
  const _TopRecommendationCard({
    required this.recommendation,
    required this.saved,
    required this.onOpenApp,
    required this.onToggleSaved,
    required this.onHelpful,
    required this.onDismiss,
  });

  final RecommendedApp recommendation;
  final bool saved;
  final VoidCallback onOpenApp;
  final VoidCallback onToggleSaved;
  final VoidCallback onHelpful;
  final VoidCallback onDismiss;

  @override
  Widget build(BuildContext context) {
    final app = recommendation.app;
    final explainer = recommendation.explanation?.trim();

    return Material(
      color: Colors.white,
      borderRadius: BorderRadius.circular(22),
      child: InkWell(
        borderRadius: BorderRadius.circular(22),
        onTap: onOpenApp,
        child: Container(
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(22),
            border: Border.all(color: const Color(0xFFD8E6E2)),
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: <Widget>[
              Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: <Widget>[
                  Expanded(
                    child: Wrap(
                      spacing: 8,
                      runSpacing: 8,
                      crossAxisAlignment: WrapCrossAlignment.center,
                      children: <Widget>[
                        Container(
                          padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
                          decoration: BoxDecoration(
                            color: const Color(0xFFE7F7F1),
                            borderRadius: BorderRadius.circular(999),
                          ),
                          child: Text(
                            'Top match',
                            style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                                  color: const Color(0xFF0F8B6D),
                                  fontWeight: FontWeight.w700,
                                ),
                          ),
                        ),
                        Text(
                          _scoreText(recommendation.score),
                          style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                                color: const Color(0xFF0F8B6D),
                                fontWeight: FontWeight.w700,
                              ),
                        ),
                      ],
                    ),
                  ),
                  IconButton.outlined(
                    onPressed: onToggleSaved,
                    icon: Icon(saved ? Icons.bookmark_rounded : Icons.bookmark_outline_rounded),
                  ),
                ],
              ),
              const SizedBox(height: 8),
              Text(app.title, style: Theme.of(context).textTheme.titleLarge),
              const SizedBox(height: 4),
              Text(app.publisher, style: Theme.of(context).textTheme.bodyMedium),
              const SizedBox(height: 12),
              Text(
                explainer == null || explainer.isEmpty ? app.summary : explainer,
                style: Theme.of(context).textTheme.bodyLarge,
              ),
              const SizedBox(height: 12),
              Wrap(
                spacing: 8,
                runSpacing: 8,
                children: <Widget>[
                  SarefTag(label: app.sarefType),
                  ...app.tags.take(2).map(
                    (String tag) => Container(
                      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
                      decoration: BoxDecoration(
                        color: const Color(0xFFF3F4F6),
                        borderRadius: BorderRadius.circular(999),
                      ),
                      child: Text(
                        tag,
                        style: Theme.of(context).textTheme.bodyMedium,
                      ),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 14),
              Wrap(
                spacing: 8,
                runSpacing: 8,
                children: <Widget>[
                  FilledButton.tonal(
                    onPressed: onOpenApp,
                    child: const Text('Open app'),
                  ),
                  TextButton.icon(
                    onPressed: onHelpful,
                    icon: const Icon(Icons.thumb_up_alt_outlined),
                    label: const Text('Helpful'),
                  ),
                  TextButton.icon(
                    onPressed: onDismiss,
                    icon: const Icon(Icons.thumb_down_alt_outlined),
                    label: const Text('Not now'),
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

class _CompactRecommendationTile extends StatelessWidget {
  const _CompactRecommendationTile({
    required this.recommendation,
    required this.saved,
    required this.onOpenApp,
    required this.onToggleSaved,
  });

  final RecommendedApp recommendation;
  final bool saved;
  final VoidCallback onOpenApp;
  final VoidCallback onToggleSaved;

  @override
  Widget build(BuildContext context) {
    final app = recommendation.app;

    return Material(
      color: Colors.white,
      borderRadius: BorderRadius.circular(20),
      child: InkWell(
        borderRadius: BorderRadius.circular(20),
        onTap: onOpenApp,
        child: Container(
          padding: const EdgeInsets.all(14),
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(20),
            border: Border.all(color: const Color(0xFFE5E7EB)),
          ),
          child: Row(
            children: <Widget>[
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: <Widget>[
                    Text(app.title, style: Theme.of(context).textTheme.titleMedium),
                    const SizedBox(height: 4),
                    Text(
                      '${app.publisher} • ${_scoreText(recommendation.score)}',
                      style: Theme.of(context).textTheme.bodyMedium,
                    ),
                    const SizedBox(height: 6),
                    Text(
                      app.summary,
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                      style: Theme.of(context).textTheme.bodyMedium,
                    ),
                  ],
                ),
              ),
              const SizedBox(width: 8),
              IconButton.outlined(
                onPressed: onToggleSaved,
                icon: Icon(saved ? Icons.bookmark_rounded : Icons.bookmark_outline_rounded),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _ResponseTimeBadge extends StatelessWidget {
  const _ResponseTimeBadge({required this.duration});

  final Duration duration;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
      decoration: BoxDecoration(
        color: const Color(0xFFF3F4F6),
        borderRadius: BorderRadius.circular(999),
      ),
      child: Text(
        _formatDuration(duration),
        style: Theme.of(context).textTheme.bodyMedium?.copyWith(
              fontWeight: FontWeight.w700,
            ),
      ),
    );
  }
}

class _PendingAssistantCard extends StatefulWidget {
  const _PendingAssistantCard({required this.startedAt, this.errorText});

  final DateTime? startedAt;

  final String? errorText;

  @override
  State<_PendingAssistantCard> createState() => _PendingAssistantCardState();
}

class _PendingAssistantCardState extends State<_PendingAssistantCard> {
  Timer? _timer;

  @override
  void initState() {
    super.initState();
    _timer = Timer.periodic(const Duration(milliseconds: 200), (_) {
      if (mounted) {
        setState(() {});
      }
    });
  }

  @override
  void dispose() {
    _timer?.cancel();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final startedAt = widget.startedAt;
    final duration = startedAt == null ? null : DateTime.now().difference(startedAt);

    return Container(
      padding: const EdgeInsets.all(18),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(24),
        border: Border.all(color: const Color(0xFFE5E7EB)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: <Widget>[
          Row(
            children: <Widget>[
              const SizedBox(
                width: 24,
                height: 24,
                child: CircularProgressIndicator(strokeWidth: 2.4),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Text(
                  widget.errorText == null
                      ? 'Searching HEDGE and ranking the best matches...'
                      : 'Last response failed. The assistant is ready when the gateway is reachable again.',
                  style: Theme.of(context).textTheme.bodyLarge,
                ),
              ),
              if (duration != null)
                _ResponseTimeBadge(duration: duration),
            ],
          ),
          const SizedBox(height: 12),
          ClipRRect(
            borderRadius: BorderRadius.circular(999),
            child: const LinearProgressIndicator(minHeight: 4),
          ),
        ],
      ),
    );
  }
}

String _scoreText(double value) => '${(value * 100).toStringAsFixed(0)}% match';

String _formatDuration(Duration duration) {
  final milliseconds = duration.inMilliseconds;
  if (milliseconds < 1000) {
    return '${milliseconds}ms';
  }
  return '${(milliseconds / 1000).toStringAsFixed(milliseconds < 10000 ? 1 : 0)}s';
}
