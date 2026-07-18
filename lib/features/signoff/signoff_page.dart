import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../data/mock_repo.dart';
import '../../models/service_models.dart';
import '../../widgets/status_chip.dart';
import '../../widgets/sign_out_action.dart';

class SignOffPage extends ConsumerWidget {
  const SignOffPage({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final tickets = ref.watch(ticketsProvider);
    final awaiting = tickets
        .where((t) => t.status == TicketStatus.awaitingSignature)
        .toList();
    final signed = tickets.where((t) => t.hasSignature).toList();
    final theme = Theme.of(context);

    return Scaffold(
      appBar: AppBar(
        title: const Text('Customer sign-off'),
        actions: const [SignOutAction()],
      ),
      body: ListView(
        padding: const EdgeInsets.fromLTRB(16, 8, 16, 24),
        children: [
          Text('Awaiting signature', style: theme.textTheme.titleMedium),
          const SizedBox(height: 8),
          if (awaiting.isEmpty)
            Card(
              child: Padding(
                padding: const EdgeInsets.all(16),
                child: Text(
                  'No tickets waiting for customer signature.',
                  style: theme.textTheme.bodyMedium?.copyWith(
                    color: theme.colorScheme.onSurfaceVariant,
                  ),
                ),
              ),
            )
          else
            ...awaiting.map(
              (t) => Padding(
                padding: const EdgeInsets.only(bottom: 10),
                child: Card(
                  child: ListTile(
                    title: Text('${t.number} · ${t.customer}'),
                    subtitle: Text(t.issue),
                    trailing: const Icon(Icons.draw_outlined),
                    onTap: () => context.go('/tickets/${t.id}'),
                  ),
                ),
              ),
            ),
          const SizedBox(height: 16),
          Text('Completed sign-offs', style: theme.textTheme.titleMedium),
          const SizedBox(height: 8),
          if (signed.isEmpty)
            Text(
              'None yet today.',
              style: theme.textTheme.bodySmall?.copyWith(
                color: theme.colorScheme.onSurfaceVariant,
              ),
            )
          else
            ...signed.map(
              (t) => Padding(
                padding: const EdgeInsets.only(bottom: 10),
                child: Card(
                  child: ListTile(
                    leading: Icon(
                      Icons.verified,
                      color: theme.colorScheme.primary,
                    ),
                    title: Text('${t.number} · ${t.signedBy}'),
                    subtitle: Text('Closed · ${t.customer}'),
                    trailing: TicketStatusChip(status: t.status),
                    onTap: () => context.go('/tickets/${t.id}'),
                  ),
                ),
              ),
            ),
        ],
      ),
    );
  }
}
