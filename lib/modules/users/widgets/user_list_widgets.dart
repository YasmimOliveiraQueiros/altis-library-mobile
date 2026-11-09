import 'package:flutter/material.dart';

import '../../../l10n/app_localizations.dart';
import '../models/user.dart';

class UserMetrics extends StatelessWidget {
  const UserMetrics({
    super.key,
    required this.totalResults,
    required this.activeOnPage,
    required this.inactiveOnPage,
  });

  final int totalResults;
  final int activeOnPage;
  final int inactiveOnPage;

  Widget _buildMetricCard(
    BuildContext context, {
    required String label,
    required int value,
  }) {
    final theme = Theme.of(context);

    return Card(
      child: Padding(
        padding: const EdgeInsets.all(8),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          mainAxisSize: MainAxisSize.min,
          children: [
            Text(
              label,
              maxLines: 2,
              overflow: TextOverflow.ellipsis,
              style: theme.textTheme.labelSmall?.copyWith(fontSize: 10),
            ),
            const SizedBox(height: 4),
            FittedBox(
              fit: BoxFit.scaleDown,
              alignment: Alignment.centerLeft,
              child: Text(
                '$value',
                style: theme.textTheme.titleLarge?.copyWith(
                  color: theme.colorScheme.primary,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;

    return Row(
      children: [
        Expanded(
          child: _buildMetricCard(
            context,
            label: l10n.totalUsers,
            value: totalResults,
          ),
        ),
        const SizedBox(width: 6),
        Expanded(
          child: _buildMetricCard(
            context,
            label: l10n.activeOnPage,
            value: activeOnPage,
          ),
        ),
        const SizedBox(width: 6),
        Expanded(
          child: _buildMetricCard(
            context,
            label: l10n.inactiveOnPage,
            value: inactiveOnPage,
          ),
        ),
      ],
    );
  }
}

class UserListItem extends StatelessWidget {
  const UserListItem({
    super.key,
    required this.user,
    required this.isUpdating,
    required this.onStatusChanged,
  });

  final User user;
  final bool isUpdating;
  final ValueChanged<bool>? onStatusChanged;

  Widget _buildStatusBadge(AppLocalizations l10n) {
    final color = user.active ? Colors.green.shade700 : Colors.grey.shade700;

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.1),
        borderRadius: BorderRadius.circular(20),
      ),
      child: Text(
        user.active ? l10n.active : l10n.inactive,
        style: TextStyle(color: color, fontWeight: FontWeight.w600),
      ),
    );
  }

  Widget _buildStatusToggle(AppLocalizations l10n) {
    if (isUpdating) {
      return const SizedBox(
        width: 18,
        height: 18,
        child: CircularProgressIndicator(strokeWidth: 2),
      );
    }

    return Tooltip(
      message: user.active ? l10n.deactivateUser : l10n.activateUser,
      child: Switch(value: user.active, onChanged: onStatusChanged),
    );
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    final profile = user.isAdmin ? l10n.administrator : l10n.standardUser;
    final details = Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          user.name,
          style: Theme.of(context).textTheme.titleMedium,
          maxLines: 1,
          overflow: TextOverflow.ellipsis,
        ),
        const SizedBox(height: 4),
        Text(user.email, maxLines: 1, overflow: TextOverflow.ellipsis),
      ],
    );

    return LayoutBuilder(
      builder: (context, constraints) {
        return Card(
          child: Padding(
            padding: const EdgeInsets.all(12),
            child: constraints.maxWidth < 600
                ? Column(
                    crossAxisAlignment: CrossAxisAlignment.stretch,
                    children: [
                      Row(
                        children: [
                          Expanded(child: details),
                          const SizedBox(width: 8),
                          _buildStatusBadge(l10n),
                        ],
                      ),
                      const SizedBox(height: 8),
                      Row(
                        children: [
                          Expanded(child: Text('${l10n.profile}: $profile')),
                          _buildStatusToggle(l10n),
                        ],
                      ),
                    ],
                  )
                : Row(
                    children: [
                      Expanded(flex: 4, child: details),
                      Expanded(
                        flex: 2,
                        child: Text('${l10n.profile}: $profile'),
                      ),
                      SizedBox(width: 115, child: _buildStatusBadge(l10n)),
                      _buildStatusToggle(l10n),
                    ],
                  ),
          ),
        );
      },
    );
  }
}
