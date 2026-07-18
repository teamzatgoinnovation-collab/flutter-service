enum TicketStatus { open, scheduled, inProgress, awaitingSignature, closed }

enum TicketPriority { low, normal, high, urgent }

class DaySummary {
  const DaySummary({
    required this.technicianName,
    required this.region,
    required this.openCount,
    required this.inProgressCount,
    required this.closedCount,
    required this.nextWindow,
  });

  final String technicianName;
  final String region;
  final int openCount;
  final int inProgressCount;
  final int closedCount;
  final String nextWindow;
}

class ServiceTicket {
  const ServiceTicket({
    required this.id,
    required this.number,
    required this.customer,
    required this.address,
    required this.issue,
    required this.status,
    required this.priority,
    required this.scheduledAt,
    this.notes = const [],
    this.signedBy,
    this.signedAt,
  });

  final String id;
  final String number;
  final String customer;
  final String address;
  final String issue;
  final TicketStatus status;
  final TicketPriority priority;
  final DateTime scheduledAt;
  final List<String> notes;
  final String? signedBy;
  final DateTime? signedAt;

  bool get hasSignature => signedBy != null && signedAt != null;

  ServiceTicket copyWith({
    TicketStatus? status,
    List<String>? notes,
    String? signedBy,
    DateTime? signedAt,
    bool clearSignature = false,
  }) {
    return ServiceTicket(
      id: id,
      number: number,
      customer: customer,
      address: address,
      issue: issue,
      status: status ?? this.status,
      priority: priority,
      scheduledAt: scheduledAt,
      notes: notes ?? this.notes,
      signedBy: clearSignature ? null : (signedBy ?? this.signedBy),
      signedAt: clearSignature ? null : (signedAt ?? this.signedAt),
    );
  }
}
