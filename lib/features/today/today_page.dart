import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../data/mock_repo.dart';
import '../../models/service_models.dart';
import '../../widgets/status_chip.dart';
import '../../widgets/sign_out_action.dart';

class TodayPage extends ConsumerWidget {
  const TodayPage({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final day = ref.watch(daySummaryProvider);
    final tickets = ref.watch(ticketsProvider);
    final next = tickets.cast<ServiceTicket?>().firstWhere(
      (t) => t!.status != TicketStatus.closed,
      orElse: () => null,
    );
    final theme = Theme.of(context);

    return Scaffold(
      appBar: AppBar(
        title: const Text('ZatGo Field Service'),
        actions: [
          const SignOutAction(),
          IconButton(
            tooltip: 'API connection',
            onPressed: () => context.go('/connection'),
            icon: const Icon(Icons.cloud_outlined),
          ),
        ],
      ),
      body: ListView(
        padding: const EdgeInsets.fromLTRB(16, 8, 16, 28),
        children: [
          Text(
            'Field day',
            style: theme.textTheme.labelLarge?.copyWith(
              color: theme.colorScheme.onSurfaceVariant,
              letterSpacing: 0.4,
            ),
          ),
          const SizedBox(height: 4),
          Text(day.region, style: theme.textTheme.headlineSmall),
          const SizedBox(height: 4),
          Text(
            '${day.technicianName} · next ${day.nextWindow}',
            style: theme.textTheme.bodyMedium?.copyWith(
              color: theme.colorScheme.onSurfaceVariant,
            ),
          ),
          const SizedBox(height: 18),
          Row(
            children: [
              Expanded(
                child: _StatTile(label: 'Open', value: '${day.openCount}'),
              ),
              const SizedBox(width: 10),
              Expanded(
                child: _StatTile(
                  label: 'Active',
                  value: '${day.inProgressCount}',
                ),
              ),
              const SizedBox(width: 10),
              Expanded(
                child: _StatTile(label: 'Closed', value: '${day.closedCount}'),
              ),
            ],
          ),
          const SizedBox(height: 24),
          _SectionHeader('Up next'),
          const SizedBox(height: 10),
          if (next == null)
            const _EmptyCard(
              icon: Icons.task_alt_outlined,
              message: 'All tickets closed for today.',
            )
          else
            Card(
              child: InkWell(
                borderRadius: BorderRadius.circular(14),
                onTap: () => context.go('/tickets/${next.id}'),
                child: Padding(
                  padding: const EdgeInsets.all(16),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        children: [
                          Text(next.number, style: theme.textTheme.titleMedium),
                          const Spacer(),
                          TicketStatusChip(status: next.status),
                        ],
                      ),
                      const SizedBox(height: 6),
                      Text(next.customer),
                      Text(
                        next.issue,
                        style: theme.textTheme.bodySmall?.copyWith(
                          color: theme.colorScheme.onSurfaceVariant,
                        ),
                      ),
                      const SizedBox(height: 10),
                      Row(
                        children: [
                          PriorityChip(priority: next.priority),
                          const SizedBox(width: 12),
                          Icon(
                            Icons.schedule,
                            size: 16,
                            color: theme.colorScheme.onSurfaceVariant,
                          ),
                          const SizedBox(width: 4),
                          Text(
                            _fmt(next.scheduledAt),
                            style: theme.textTheme.bodySmall,
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
              ),
            ),
          const SizedBox(height: 24),
          _SectionHeader('Quick actions'),
          const SizedBox(height: 10),
          Wrap(
            spacing: 8,
            runSpacing: 8,
            children: [
              FilledButton.tonal(
                onPressed: () => context.go('/tickets'),
                child: const Text('All tickets'),
              ),
              FilledButton.tonal(
                onPressed: () => context.go('/schedule'),
                child: const Text('Schedule'),
              ),
              FilledButton.tonal(
                onPressed: () => context.go('/signoff'),
                child: const Text('Awaiting sign-off'),
              ),
            ],
          ),
        ],
      ),
    );
  }

  static String _fmt(DateTime dt) {
    final h = dt.hour.toString().padLeft(2, '0');
    final m = dt.minute.toString().padLeft(2, '0');
    return '$h:$m';
  }
}

class _SectionHeader extends StatelessWidget {
  const _SectionHeader(this.label);

  final String label;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Text(
      label,
      style: theme.textTheme.titleMedium?.copyWith(fontWeight: FontWeight.w700),
    );
  }
}

class _EmptyCard extends StatelessWidget {
  const _EmptyCard({required this.icon, required this.message});

  final IconData icon;
  final String message;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Card(
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 22),
        child: Row(
          children: [
            Icon(icon, color: theme.colorScheme.onSurfaceVariant),
            const SizedBox(width: 12),
            Expanded(
              child: Text(
                message,
                style: theme.textTheme.bodyMedium?.copyWith(
                  color: theme.colorScheme.onSurfaceVariant,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _StatTile extends StatelessWidget {
  const _StatTile({required this.label, required this.value});

  final String label;
  final String value;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Card(
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 14),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              label,
              style: theme.textTheme.labelMedium?.copyWith(
                color: theme.colorScheme.onSurfaceVariant,
              ),
            ),
            const SizedBox(height: 4),
            Text(
              value,
              style: theme.textTheme.titleLarge?.copyWith(
                fontWeight: FontWeight.w700,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
