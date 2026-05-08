import 'package:flutter/material.dart';

import '../models/catalog_app.dart';
import 'saref_tag.dart';

class AppSummaryCard extends StatelessWidget {
  const AppSummaryCard({
    super.key,
    required this.app,
    required this.saved,
    required this.onTap,
    required this.onToggleSaved,
    this.score,
    this.footer,
  });

  final CatalogApp app;
  final bool saved;
  final VoidCallback onTap;
  final VoidCallback onToggleSaved;
  final double? score;
  final Widget? footer;

  @override
  Widget build(BuildContext context) {
    final scoreText = score == null ? null : 'Score ${(score! * 100).toStringAsFixed(0)}';
    return Card(
      elevation: 0,
      margin: EdgeInsets.zero,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(24)),
      child: InkWell(
        borderRadius: BorderRadius.circular(24),
        onTap: onTap,
        child: Padding(
          padding: const EdgeInsets.all(18),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: <Widget>[
              Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: <Widget>[
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: <Widget>[
                        Text(
                          app.title,
                          style: Theme.of(context).textTheme.titleLarge,
                        ),
                        const SizedBox(height: 6),
                        Text(
                          app.id,
                          style: Theme.of(context).textTheme.bodyMedium,
                        ),
                      ],
                    ),
                  ),
                  IconButton.filledTonal(
                    onPressed: onToggleSaved,
                    icon: Icon(saved ? Icons.bookmark : Icons.bookmark_border),
                  ),
                ],
              ),
              const SizedBox(height: 14),
              Wrap(
                spacing: 8,
                runSpacing: 8,
                children: <Widget>[
                  SarefTag(label: app.sarefType),
                  if (scoreText != null)
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
                      decoration: BoxDecoration(
                        color: const Color(0xFFF8E7B8),
                        borderRadius: BorderRadius.circular(999),
                      ),
                      child: Text(
                        scoreText,
                        style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                              color: const Color(0xFF8A5A00),
                              fontWeight: FontWeight.w700,
                            ),
                      ),
                    ),
                ],
              ),
              const SizedBox(height: 14),
              Text(
                app.summary,
                style: Theme.of(context).textTheme.bodyLarge,
              ),
              const SizedBox(height: 14),
              Row(
                children: <Widget>[
                  Icon(Icons.apartment_rounded, size: 16, color: Theme.of(context).colorScheme.primary),
                  const SizedBox(width: 6),
                  Expanded(
                    child: Text(
                      app.publisher,
                      style: Theme.of(context).textTheme.bodyMedium,
                    ),
                  ),
                  const Icon(Icons.chevron_right_rounded),
                ],
              ),
              if (footer != null) ...<Widget>[
                const SizedBox(height: 14),
                footer!,
              ],
            ],
          ),
        ),
      ),
    );
  }
}
