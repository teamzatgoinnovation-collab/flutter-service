import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:zatgo_dart_sdk/zatgo_dart_sdk.dart';

import '../models/service_models.dart';
import '../services/session.dart';

/// ERPNext-backed service tickets via `zatgo_core.api.v1.service` (no seed data).
class MockServiceRepo {
  List<ServiceTicket> _tickets = [];

  DaySummary get daySummary {
    final open = _tickets
        .where(
          (t) =>
              t.status == TicketStatus.open ||
              t.status == TicketStatus.scheduled,
        )
        .length;
    final inProgress = _tickets
        .where(
          (t) =>
              t.status == TicketStatus.inProgress ||
              t.status == TicketStatus.awaitingSignature,
        )
        .length;
    final closed = _tickets
        .where((t) => t.status == TicketStatus.closed)
        .length;
    return DaySummary(
      technicianName: 'Technician',
      region: '—',
      openCount: open,
      inProgressCount: inProgress,
      closedCount: closed,
      nextWindow: _tickets.isEmpty ? 'No open jobs' : 'See schedule',
    );
  }

  Future<void> refreshFromErpnext(ServiceSession session) async {
    if (!session.connected) {
      _tickets = [];
      return;
    }
    await session.store.callMethod(ZatGoApiMethods.servicePing);
    final env = await session.store.callMethod(
      ZatGoApiMethods.serviceTicketsList,
      args: {'page': 1, 'page_size': 100},
    );
    final rows = env.data is List ? env.data as List : const [];
    _tickets = [
      for (var i = 0; i < rows.length; i++)
        if (rows[i] is Map)
          _mapTicket(Map<String, dynamic>.from(rows[i] as Map), i),
    ];
  }

  ServiceTicket _mapTicket(Map<String, dynamic> row, int i) {
    final scheduledRaw = row['scheduled_at']?.toString();
    final scheduledAt = scheduledRaw == null || scheduledRaw.isEmpty
        ? DateTime.now().add(Duration(hours: i))
        : (DateTime.tryParse(scheduledRaw) ??
            DateTime.now().add(Duration(hours: i)));
    return ServiceTicket(
      id: '${row['name'] ?? row['id'] ?? 'tkt-$i'}',
      number: '${row['number'] ?? row['name'] ?? 'TKT-$i'}',
      customer: '${row['customer'] ?? ''}',
      address: '${row['address'] ?? ''}',
      issue:
          '${row['subject'] ?? row['issue'] ?? row['title'] ?? 'Ticket ${i + 1}'}',
      status: _parseStatus(row['status']?.toString()),
      priority: _parsePriority(row['priority']?.toString()),
      scheduledAt: scheduledAt,
      notes: const [],
    );
  }

  TicketStatus _parseStatus(String? raw) {
    switch ((raw ?? '').trim().toLowerCase()) {
      case 'scheduled':
        return TicketStatus.scheduled;
      case 'in progress':
      case 'in_progress':
        return TicketStatus.inProgress;
      case 'awaiting signature':
      case 'awaiting_signature':
        return TicketStatus.awaitingSignature;
      case 'closed':
      case 'completed':
        return TicketStatus.closed;
      case 'open':
      default:
        return TicketStatus.open;
    }
  }

  TicketPriority _parsePriority(String? raw) {
    switch ((raw ?? '').trim().toLowerCase()) {
      case 'low':
        return TicketPriority.low;
      case 'high':
        return TicketPriority.high;
      case 'urgent':
        return TicketPriority.urgent;
      case 'normal':
      default:
        return TicketPriority.normal;
    }
  }

  List<ServiceTicket> listTickets({TicketStatus? status}) {
    final sorted = [..._tickets]
      ..sort((a, b) => a.scheduledAt.compareTo(b.scheduledAt));
    if (status == null) return sorted;
    return sorted.where((t) => t.status == status).toList();
  }

  ServiceTicket? getById(String id) {
    try {
      return _tickets.firstWhere((t) => t.id == id);
    } catch (_) {
      return null;
    }
  }

  void setStatus(String id, TicketStatus status) {
    _replace(id, (t) => t.copyWith(status: status));
  }

  void startJob(String id) {
    setStatus(id, TicketStatus.inProgress);
  }

  void requestSignature(String id) {
    setStatus(id, TicketStatus.awaitingSignature);
  }

  void addNote(String id, String note) {
    _replace(id, (t) => t.copyWith(notes: [...t.notes, note]));
  }

  void captureSignature(String id, String signedBy) {
    _replace(
      id,
      (t) => t.copyWith(
        status: TicketStatus.closed,
        signedBy: signedBy.trim().isEmpty ? t.customer : signedBy.trim(),
        signedAt: DateTime.now(),
      ),
    );
  }

  void _replace(String id, ServiceTicket Function(ServiceTicket) update) {
    final i = _tickets.indexWhere((t) => t.id == id);
    if (i < 0) return;
    _tickets = [..._tickets]..[i] = update(_tickets[i]);
  }
}

final mockServiceRepoProvider = Provider<MockServiceRepo>((ref) {
  final repo = MockServiceRepo();
  Future.microtask(() async {
    final session = ref.read(serviceSessionProvider);
    try {
      await repo.refreshFromErpnext(session);
      ref.read(ticketsRevisionProvider.notifier).state++;
    } catch (_) {}
  });
  return repo;
});

final daySummaryProvider = Provider<DaySummary>((ref) {
  ref.watch(ticketsRevisionProvider);
  return ref.watch(mockServiceRepoProvider).daySummary;
});

final ticketsProvider = Provider<List<ServiceTicket>>((ref) {
  ref.watch(ticketsRevisionProvider);
  return ref.watch(mockServiceRepoProvider).listTickets();
});

final ticketByIdProvider = Provider.family<ServiceTicket?, String>((ref, id) {
  ref.watch(ticketsRevisionProvider);
  return ref.watch(mockServiceRepoProvider).getById(id);
});

final ticketsRevisionProvider = StateProvider<int>((ref) => 0);

void bumpTickets(WidgetRef ref) {
  ref.read(ticketsRevisionProvider.notifier).state++;
}
