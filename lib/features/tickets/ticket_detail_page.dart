import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../data/mock_repo.dart';
import '../../models/service_models.dart';
import '../../widgets/status_chip.dart';
import '../../widgets/sign_out_action.dart';

class TicketDetailPage extends ConsumerStatefulWidget {
  const TicketDetailPage({super.key, required this.ticketId});

  final String ticketId;

  @override
  ConsumerState<TicketDetailPage> createState() => _TicketDetailPageState();
}

class _TicketDetailPageState extends ConsumerState<TicketDetailPage> {
  final _noteCtrl = TextEditingController();
  final _signCtrl = TextEditingController();

  @override
  void dispose() {
    _noteCtrl.dispose();
    _signCtrl.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final ticket = ref.watch(ticketByIdProvider(widget.ticketId));
    final theme = Theme.of(context);
    final repo = ref.read(mockServiceRepoProvider);

    if (ticket == null) {
      return Scaffold(
        appBar: AppBar(
          title: const Text('Ticket'),
          actions: const [SignOutAction()],
        ),
        body: const Center(child: Text('Ticket not found')),
      );
    }

    return Scaffold(
      appBar: AppBar(
        title: Text(ticket.number),
        actions: [
          const SignOutAction(),
          Padding(
            padding: const EdgeInsets.only(right: 12),
            child: Center(child: TicketStatusChip(status: ticket.status)),
          ),
        ],
      ),
      body: ListView(
        padding: const EdgeInsets.fromLTRB(16, 8, 16, 32),
        children: [
          Text(ticket.customer, style: theme.textTheme.headlineSmall),
          const SizedBox(height: 4),
          Text(
            ticket.address,
            style: theme.textTheme.bodyMedium?.copyWith(
              color: theme.colorScheme.onSurfaceVariant,
            ),
          ),
          const SizedBox(height: 12),
          Card(
            child: Padding(
              padding: const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text('Issue', style: theme.textTheme.titleSmall),
                  const SizedBox(height: 6),
                  Text(ticket.issue),
                  const SizedBox(height: 12),
                  Row(
                    children: [
                      PriorityChip(priority: ticket.priority),
                      const Spacer(),
                      Text(
                        'Scheduled ${_fmt(ticket.scheduledAt)}',
                        style: theme.textTheme.bodySmall,
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ),
          const SizedBox(height: 16),
          Text('Workflow', style: theme.textTheme.titleMedium),
          const SizedBox(height: 8),
          Wrap(
            spacing: 8,
            runSpacing: 8,
            children: [
              if (ticket.status == TicketStatus.open ||
                  ticket.status == TicketStatus.scheduled)
                FilledButton(
                  onPressed: () {
                    repo.startJob(ticket.id);
                    bumpTickets(ref);
                  },
                  child: const Text('Start job'),
                ),
              if (ticket.status == TicketStatus.inProgress)
                FilledButton.tonal(
                  onPressed: () {
                    repo.requestSignature(ticket.id);
                    bumpTickets(ref);
                  },
                  child: const Text('Request signature'),
                ),
              if (ticket.status == TicketStatus.awaitingSignature)
                FilledButton(
                  onPressed: () => _showSignSheet(ticket),
                  child: const Text('Capture signature'),
                ),
            ],
          ),
          const SizedBox(height: 20),
          Text('Notes', style: theme.textTheme.titleMedium),
          const SizedBox(height: 8),
          if (ticket.notes.isEmpty)
            Text(
              'No notes yet.',
              style: theme.textTheme.bodySmall?.copyWith(
                color: theme.colorScheme.onSurfaceVariant,
              ),
            )
          else
            ...ticket.notes.map(
              (n) => Card(
                child: ListTile(
                  dense: true,
                  leading: const Icon(Icons.sticky_note_2_outlined),
                  title: Text(n),
                ),
              ),
            ),
          const SizedBox(height: 8),
          Row(
            children: [
              Expanded(
                child: TextField(
                  controller: _noteCtrl,
                  decoration: const InputDecoration(
                    hintText: 'Add a field note…',
                  ),
                ),
              ),
              const SizedBox(width: 8),
              IconButton.filled(
                onPressed: () {
                  final text = _noteCtrl.text.trim();
                  if (text.isEmpty) return;
                  repo.addNote(ticket.id, text);
                  _noteCtrl.clear();
                  bumpTickets(ref);
                },
                icon: const Icon(Icons.add),
              ),
            ],
          ),
          if (ticket.hasSignature) ...[
            const SizedBox(height: 20),
            Text('Customer signature', style: theme.textTheme.titleMedium),
            const SizedBox(height: 8),
            Card(
              child: ListTile(
                leading: Icon(Icons.verified, color: theme.colorScheme.primary),
                title: Text(ticket.signedBy!),
                subtitle: Text('Signed ${_fmt(ticket.signedAt!)}'),
              ),
            ),
          ],
        ],
      ),
    );
  }

  Future<void> _showSignSheet(ServiceTicket ticket) async {
    _signCtrl.text = ticket.customer;
    final repo = ref.read(mockServiceRepoProvider);
    final ok = await showModalBottomSheet<bool>(
      context: context,
      isScrollControlled: true,
      builder: (ctx) {
        return Padding(
          padding: EdgeInsets.fromLTRB(
            16,
            16,
            16,
            16 + MediaQuery.viewInsetsOf(ctx).bottom,
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              Text(
                'Customer sign-off',
                style: Theme.of(ctx).textTheme.titleLarge,
              ),
              const SizedBox(height: 8),
              Text(
                'Stub signature pad — capture printed name for now.',
                style: Theme.of(ctx).textTheme.bodySmall,
              ),
              const SizedBox(height: 12),
              Container(
                height: 120,
                alignment: Alignment.center,
                decoration: BoxDecoration(
                  border: Border.all(
                    color: Theme.of(ctx).colorScheme.outlineVariant,
                  ),
                  borderRadius: BorderRadius.circular(12),
                  color: const Color(0xFFF8FAF9),
                ),
                child: Text(
                  '✕  signature canvas stub',
                  style: TextStyle(
                    color: Theme.of(ctx).colorScheme.onSurfaceVariant,
                  ),
                ),
              ),
              const SizedBox(height: 12),
              TextField(
                controller: _signCtrl,
                decoration: const InputDecoration(labelText: 'Printed name'),
              ),
              const SizedBox(height: 12),
              FilledButton(
                onPressed: () => Navigator.pop(ctx, true),
                child: const Text('Confirm signature'),
              ),
            ],
          ),
        );
      },
    );
    if (ok == true) {
      repo.captureSignature(ticket.id, _signCtrl.text);
      bumpTickets(ref);
    }
  }

  static String _fmt(DateTime dt) {
    final h = dt.hour.toString().padLeft(2, '0');
    final m = dt.minute.toString().padLeft(2, '0');
    return '$h:$m';
  }
}
