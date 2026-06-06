import 'package:flutter/material.dart';

class ColorDebugPage extends StatelessWidget {
  const ColorDebugPage({super.key});

  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;
    final colors = {
      'primary': cs.primary,
      'onPrimary': cs.onPrimary,
      'surface': cs.surface,
      'surfaceContainerLow': cs.surfaceContainerLow,
      'surfaceContainer': cs.surfaceContainer,
      'surfaceContainerHigh': cs.surfaceContainerHigh,
      'surfaceContainerHighest': cs.surfaceContainerHighest,
      'secondary': cs.secondary,
      'error': cs.error,
      'onSurface' : cs.onSurface,
      'onSurfaceVariant' : cs.onSurfaceVariant,
    };

    return Scaffold(
      body: ListView(
        children: colors.entries.map((e) => Container(
          height: 60,
          color: e.value,
          child: Text(
            // ignore: deprecated_member_use
            '${e.key}: #${e.value.value.toRadixString(16).toUpperCase()}',
            style: TextStyle(color: cs.onSurface),
          ),
        )).toList(),
      ),
    );
  }
}