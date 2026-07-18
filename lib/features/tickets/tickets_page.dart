import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../data/mock_repo.dart';
import '../../models/service_models.dart';
import '../../widgets/status_chip.dart';
import '../../widgets/sign_out_action.dart';

class TicketsPage extends ConsumerStatefulWidget {
  const TicketsPage({super.key});

  @override
  ConsumerState<TicketsPage> createState() => _TicketsPageState();
}

class _TicketsPageState extends ConsumerState<TicketsPage> {
  TicketStatus? _filter;

  @override
  Widget build(BuildContext context) {
    final all = ref.watch(ticketsProvider);
    final tickets = _filter == null
        ? all
        : all.where((t) => t.status == _filter).toList();
    final theme = Theme.of(context);

    return Scaffold(
      appBar: AppBar(
        title: const Text('Tickets'),
        actions: const [SignOutAction()],
      ),
      body: Column(
        children: [
          SizedBox(
            height: 48,
            child: ListView(
              scrollDirection: Axis.horizontal,
              padding: const EdgeInsets.symmetric(horizontal: 12),
              children: [
                _FilterChip(
                  label: 'All',
                  selected: _filter == null,
                  onTap: () => setState(() => _filter = null),
                ),
                ...TicketStatus.values.map(
                  (s) => _FilterChip(
                    label: _label(s),
                    selected: _filter == s,
                    onTap: () => setState(() => _filter = s),
                  ),
                ),
              ],
            ),
          ),
          Expanded(
            child: ListView.separated(
              padding: const EdgeInsets.fromLTRB(16, 8, 16, 24),
              itemCount: tickets.length,
              separatorBuilder: (_, _) => const SizedBox(height: 10),
              itemBuilder: (context, index) {
                final t = tickets[index];
                return Card(
                  child: InkWell(
                    borderRadius: BorderRadius.circular(14),
                    onTap: () => context.go('/tickets/${t.id}'),
                    child: Padding(
                      padding: const EdgeInsets.all(14),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Row(
                            children: [
                              Text(
                                t.number,
                                style: theme.textTheme.titleMedium,
                              ),
                              const Spacer(),
                              TicketStatusChip(status: t.status),
                            ],
                          ),
                          const SizedBox(height: 4),
                          Text(t.customer),
                          Text(
                            t.issue,
                            maxLines: 2,
                            overflow: TextOverflow.ellipsis,
                            style: theme.textTheme.bodySmall?.copyWith(
                              color: theme.colorScheme.onSurfaceVariant,
                            ),
                          ),
                          const SizedBox(height: 8),
                          Row(
                            children: [
                              PriorityChip(priority: t.priority),
                              const Spacer(),
                              Text(
                                t.address,
                                style: theme.textTheme.bodySmall?.copyWith(
                                  color: theme.colorScheme.onSurfaceVariant,
                                ),
                              ),
                            ],
                          ),
                        ],
                      ),
                    ),
                  ),
                );
              },
            ),
          ),
        ],
      ),
    );
  }

  static String _label(TicketStatus s) => switch (s) {
    TicketStatus.open => 'Open',
    TicketStatus.scheduled => 'Scheduled',
    TicketStatus.inProgress => 'Active',
    TicketStatus.awaitingSignature => 'Sign-off',
    TicketStatus.closed => 'Closed',
  };
}

class _FilterChip extends StatelessWidget {
  const _FilterChip({
    required this.label,
    required this.selected,
    required this.onTap,
  });

  final String label;
  final bool selected;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(right: 8),
      child: FilterChip(
        label: Text(label),
        selected: selected,
        onSelected: (_) => onTap(),
      ),
    );
  }
}
