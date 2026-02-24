import 'package:flutter/material.dart';
import '../utils/theme.dart';
import '../utils/constants.dart';

class ModeSelector extends StatelessWidget {
  final String currentMode;
  final Function(String) onModeChanged;

  const ModeSelector({
    super.key,
    required this.currentMode,
    required this.onModeChanged,
  });

  @override
  Widget build(BuildContext context) {
    final isAskMode = currentMode == AppConstants.modeAsk;

    return Container(
      margin: const EdgeInsets.all(16),
      padding: const EdgeInsets.all(4),
      decoration: BoxDecoration(
        color: Theme.of(context).colorScheme.surface,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(
          color: Theme.of(context).dividerColor,
        ),
      ),
      child: Row(
        children: [
          // Mode ASK
          Expanded(
            child: _ModeButton(
              icon: Icons.chat_bubble_outline,
              activeIcon: Icons.chat_bubble,
              label: 'ASK',
              description: 'Questions & Réponses',
              isActive: isAskMode,
              gradient: AppTheme.askModeGradient,
              onTap: () => onModeChanged(AppConstants.modeAsk),
            ),
          ),

          // Séparateur
          Container(
            width: 1,
            height: 40,
            color: Theme.of(context).dividerColor,
          ),

          // Mode AGENT
          Expanded(
            child: _ModeButton(
              icon: Icons.code,
              activeIcon: Icons.code,
              label: 'AGENT',
              description: 'Code & Projets',
              isActive: !isAskMode,
              gradient: AppTheme.agentModeGradient,
              onTap: () => onModeChanged(AppConstants.modeAgent),
            ),
          ),
        ],
      ),
    );
  }
}

class _ModeButton extends StatelessWidget {
  final IconData icon;
  final IconData activeIcon;
  final String label;
  final String description;
  final bool isActive;
  final Gradient gradient;
  final VoidCallback onTap;

  const _ModeButton({
    required this.icon,
    required this.activeIcon,
    required this.label,
    required this.description,
    required this.isActive,
    required this.gradient,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(8),
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 200),
        padding: const EdgeInsets.symmetric(vertical: 12, horizontal: 16),
        decoration: BoxDecoration(
          gradient: isActive ? gradient : null,
          borderRadius: BorderRadius.circular(8),
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              isActive ? activeIcon : icon,
              size: 20,
              color: isActive ? Colors.white : null,
            ),
            const SizedBox(width: 8),
            Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  label,
                  style: TextStyle(
                    fontWeight: FontWeight.bold,
                    fontSize: 12,
                    color: isActive ? Colors.white : null,
                  ),
                ),
                Text(
                  description,
                  style: TextStyle(
                    fontSize: 10,
                    color: isActive
                        ? Colors.white.withOpacity(0.8)
                        : Theme.of(context)
                            .colorScheme
                            .onSurface
                            .withOpacity(0.6),
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}
