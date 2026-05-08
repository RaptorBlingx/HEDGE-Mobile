import 'package:flutter/material.dart';

class SarefTag extends StatelessWidget {
  const SarefTag({super.key, required this.label});

  final String label;

  @override
  Widget build(BuildContext context) {
    final palette = SarefPalette.fromLabel(label);
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
      decoration: BoxDecoration(
        color: palette.background,
        borderRadius: BorderRadius.circular(999),
      ),
      child: Text(
        label,
        style: Theme.of(context).textTheme.bodyMedium?.copyWith(
              color: palette.foreground,
              fontWeight: FontWeight.w700,
            ),
      ),
    );
  }
}

class SarefPalette {
  const SarefPalette({required this.background, required this.foreground});

  final Color background;
  final Color foreground;

  static SarefPalette fromLabel(String raw) {
    switch (raw.toLowerCase()) {
      case 'energy':
        return const SarefPalette(
          background: Color(0xFFD9F4F0),
          foreground: Color(0xFF0F766E),
        );
      case 'building':
        return const SarefPalette(
          background: Color(0xFFE2E8F6),
          foreground: Color(0xFF334155),
        );
      case 'environment':
        return const SarefPalette(
          background: Color(0xFFFDE7D2),
          foreground: Color(0xFFB45309),
        );
      case 'agriculture':
        return const SarefPalette(
          background: Color(0xFFE4F4DC),
          foreground: Color(0xFF3F7A18),
        );
      case 'water':
        return const SarefPalette(
          background: Color(0xFFDFF4FB),
          foreground: Color(0xFF0F5E8C),
        );
      case 'city':
        return const SarefPalette(
          background: Color(0xFFF2E7FF),
          foreground: Color(0xFF7C3AED),
        );
      case 'health':
        return const SarefPalette(
          background: Color(0xFFFCE2EB),
          foreground: Color(0xFFBE123C),
        );
      case 'manufacturing':
        return const SarefPalette(
          background: Color(0xFFFDECCB),
          foreground: Color(0xFFB45309),
        );
      default:
        return const SarefPalette(
          background: Color(0xFFE9EEF5),
          foreground: Color(0xFF475569),
        );
    }
  }
}
