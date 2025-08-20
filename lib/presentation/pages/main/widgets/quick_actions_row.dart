import 'package:flutter/material.dart';
import '../../../../core/theme/app_theme.dart';

class QuickActionsRow extends StatelessWidget {
  final VoidCallback onAddExpense;
  final VoidCallback onCreateGroup;
  final VoidCallback onSettleUp;

  const QuickActionsRow({
    super.key,
    required this.onAddExpense,
    required this.onCreateGroup,
    required this.onSettleUp,
  });

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Expanded(
          child: _QuickActionButton(
            icon: Icons.receipt_long,
            label: 'Add Expense',
            onTap: onAddExpense,
            color: AppTheme.peachDark1,
          ),
        ),
        const SizedBox(width: 12),
        Expanded(
          child: _QuickActionButton(
            icon: Icons.group_add,
            label: 'Create Group',
            onTap: onCreateGroup,
            color: AppTheme.mintDark1,
          ),
        ),
        const SizedBox(width: 12),
        Expanded(
          child: _QuickActionButton(
            icon: Icons.payment,
            label: 'Settle Up',
            onTap: onSettleUp,
            color: AppTheme.lavenderDark1,
          ),
        ),
      ],
    );
  }
}

class _QuickActionButton extends StatelessWidget {
  final IconData icon;
  final String label;
  final VoidCallback onTap;
  final Color color;

  const _QuickActionButton({
    required this.icon,
    required this.label,
    required this.onTap,
    required this.color,
  });

  @override
  Widget build(BuildContext context) {
    // Create gradient colors based on the main color
    final gradientStart = _getDarkerShade(color);
    final gradientEnd = _getLighterShade(color);
    
    return GestureDetector(
      onTap: onTap,
      child: Container(
        height: 140, // Fixed height for consistency
        padding: const EdgeInsets.symmetric(vertical: 16, horizontal: 12),
        decoration: BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
            colors: [gradientStart, gradientEnd],
          ),
          borderRadius: BorderRadius.circular(20),
          boxShadow: [
            BoxShadow(
              color: Colors.black,
              blurRadius: 0,
              offset: const Offset(4, 4),
            ),
          ],
        ),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                  colors: [
                    Colors.white.withValues(alpha: 0.3),
                    Colors.white.withValues(alpha: 0.1),
                  ],
                ),
                shape: BoxShape.circle,
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withValues(alpha: 0.1),
                    blurRadius: 8,
                    offset: const Offset(0, 4),
                  ),
                ],
              ),
              child: Icon(
                icon,
                color: AppTheme.darkGray,
                size: 24,
              ),
            ),
            const SizedBox(height: 12),
            Flexible(
              child: Text(
                label,
                style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                  fontWeight: FontWeight.w600,
                  color: AppTheme.darkGray,
                  fontSize: 12,
                ),
                textAlign: TextAlign.center,
                maxLines: 2,
                overflow: TextOverflow.ellipsis,
              ),
            ),
          ],
        ),
      ),
    );
  }

  // Helper method to get darker shade for gradient
  Color _getDarkerShade(Color color) {
    final hsl = HSLColor.fromColor(color);
    return hsl.withLightness((hsl.lightness - 0.1).clamp(0.0, 1.0)).toColor();
  }

  // Helper method to get lighter shade for gradient
  Color _getLighterShade(Color color) {
    final hsl = HSLColor.fromColor(color);
    return hsl.withLightness((hsl.lightness + 0.1).clamp(0.0, 1.0)).toColor();
  }
}